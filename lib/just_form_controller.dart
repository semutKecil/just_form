part of 'just_form_builder.dart';

class JustFormController extends Cubit<Map<String, JustFieldData>> {
  final Map<String, dynamic>? initialValues;
  final List<JustValidator> validators;

  final List<ValueChanged<Map<String, dynamic>>> _valuesChangedListeners = [];
  final List<ValueChanged<Map<String, String?>>> _errorsChangedListeners = [];
  final ValueChanged<Map<String, dynamic>>? onFieldRegistered;

  final Debouncer<void> valuesChangedDebouncer = Debouncer(
    delay: Duration(milliseconds: 100),
  );
  final Debouncer<void> errorsChangedDebouncer = Debouncer(
    delay: Duration(milliseconds: 100),
  );

  JustFormController({
    this.initialValues = const {},
    this.validators = const [],
    this.onFieldRegistered,
  }) : super({});

  void _update(Map<String, JustFieldData> newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  JustFieldController<T>? _register<T>(
    String name, {
    T? initialValue,
    List<String? Function(T? value)> validators = const [],
    bool keepValueOnDestroy = true,
    Map<String, dynamic> initialAttributes = const {},
  }) {
    var newState = Map<String, JustFieldData>.from(state);
    var ctrl = newState[name];
    T? value = keepValueOnDestroy
        ? ((ctrl != null && ctrl.state.value is T)
              ? ctrl.state.value
              : initialValues?[name] ?? initialValue)
        : initialValues?[name] ?? initialValue;

    if (ctrl == null || ctrl is! JustFieldData<T>) {
      ctrl?.close();
      var cubit = JustFieldData<T>(
        initialValue: initialValues?[name],
        validators: validators,
        keepValueOnDestroy: keepValueOnDestroy,
        formController: this,
        initialState: JustFieldState<T>(
          name: name,
          internal: true,
          value: value,
          attributes: initialAttributes,
          active: true,
          updateTime: DateTime.now(),
        ),
      );

      newState[name] = cubit;
      _update(newState);

      Future(() {
        cubit.addListener((from, to) {
          if (from.value != to.value && _valuesChangedListeners.isNotEmpty) {
            valuesChangedDebouncer.run(() {
              for (var listener in _valuesChangedListeners) {
                listener(getValues());
              }
            });
          }
          if (from.error != to.error && _errorsChangedListeners.isNotEmpty) {
            errorsChangedDebouncer.run(() {
              for (var listener in _errorsChangedListeners) {
                listener(_getFieldErrors());
              }
            });
          }
        });
      });
    } else {
      ctrl._update(
        ctrl.state.copyWith(
          attributes: initialAttributes,
          value: value,
          internal: true,
          active: true,
        ),
      );
    }

    onFieldRegistered?.call(getValues());

    return _fieldInternal<T>(name);
  }

  void _unRegister(String name, {bool hard = false}) {
    if (hard) {
      state[name]?.clearListeners();
      state[name]?.close();
      _update(Map<String, JustFieldData>.from(state)..remove(name));
    } else {
      state[name]?._update(state[name]!.state.copyWith(active: false));
    }
  }

  void patchValues(Map<String, dynamic> values) {
    for (var key in values.keys) {
      if (state[key] != null) {
        state[key]?._setValue(values[key]);
      }
    }
  }

  Map<String, dynamic> getValues({bool withHiddenFields = false}) {
    return Map.fromEntries(
      state.entries.where(
        (element) => withHiddenFields || element.value.state.active == true,
      ),
    ).map((key, value) => MapEntry(key, value._getValue()));
  }

  Map<String, String?> getErrors({bool withHiddenFields = false}) {
    return _getFieldErrors(withHiddenFields: withHiddenFields)
      ..removeWhere((key, value) {
        return value == null;
      });
  }

  Map<String, String?> _getFieldErrors({bool withHiddenFields = false}) {
    return Map.fromEntries(
      state.entries.where(
        (element) => withHiddenFields || element.value.state.active == true,
      ),
    ).map((key, value) => MapEntry(key, value._getError()));
  }

  bool isValid({bool withHiddenFields = false}) {
    return state.entries
        .where(
          (element) => withHiddenFields || element.value.state.active == true,
        )
        .map((e) => e.value._getError())
        .whereType<String>()
        .isEmpty;
  }

  Map<String, MapEntry<int, String?>> _xValidate(List<String> fields) {
    var usedValidator = validators.where((element) {
      return element.triggers.any((element2) => fields.contains(element2));
    });
    var formErrors = _getFieldErrors();
    var fieldTarget = usedValidator
        .map((e) => e.targets.map((t) => t.field))
        .expand((e) => e)
        .toSet();

    Map<String, MapEntry<int, String?>> errors =
        Map.fromEntries(
          fieldTarget.map((e) {
            return MapEntry(e, MapEntry(-1, formErrors[e]));
          }),
        )..removeWhere((key, value) {
          return value.value != null;
        });

    usedValidator.toList().removeWhere((v) {
      return !(v.targets.any((t) => errors.containsKey(t.field)));
    });

    if (usedValidator.isEmpty) return {};

    var values = getValues();

    for (var i = 0; i < usedValidator.length; i++) {
      var validator = validators[i];
      var targetField = validator.targets.map((e) => e.field).toList();

      if (targetField.isEmpty) {
        targetField = validator.triggers;
      }

      /// remove targetField that already has an error or not active
      targetField.removeWhere((element) {
        return errors[element]?.value != null;
      });

      /// if targetField is empty nothing to do
      if (targetField.isEmpty) {
        continue;
      }

      for (var _ in validator.triggers) {
        var validatedTarget = targetField.where((element) {
          return errors[element]?.value == null;
        });
        if (validatedTarget.isEmpty) {
          break;
        }
        var error = validator.validator(values);
        for (var field in targetField) {
          var justTarget = validator.targets
              .where((element) => element.field == field)
              .firstOrNull;
          errors[field] = MapEntry(
            i,
            error == null
                ? null
                : justTarget != null
                ? justTarget.message(error)
                : error,
          );
        }
      }
    }
    return errors;
  }

  void validate({bool withHiddenFields = false}) {
    Map<String, MapEntry<int, String?>> errors = {
      for (var element in state.entries.where(
        (element) => withHiddenFields || element.value.state.active == true,
      ))
        element.key: MapEntry(-1, element.value._validate(forced: true)),
    };

    var stillValid = errors.keys.where((element) {
      return errors[element]?.value == null;
    });

    if (stillValid.isNotEmpty) {
      var errorForm = _xValidate(stillValid.toList());
      errors = {...errors, ...errorForm};
    }

    errors.forEach((key, value) {
      state[key]?._setError(
        value.value,
        errorId: value.key,
        internal: false,
        forced: true,
      );
    });
  }

  JustFieldController<T>? field<T>(String name) {
    return state[name] == null
        ? null
        : JustFieldController<T>(
            state[name]! as JustFieldData<T>,
            internal: false,
          );
  }

  Map<String, JustFieldController> fields() {
    return state.map((key, value) => MapEntry(key, field(key)!));
  }

  JustFieldController<T>? _fieldInternal<T>(String name) {
    return state[name] == null
        ? null
        : JustFieldController<T>(
            state[name]! as JustFieldData<T>,
            internal: true,
          );
  }

  void addValuesChangedListener(ValueChanged<Map<String, dynamic>> fn) {
    _valuesChangedListeners.add(fn);
  }

  void removeValuesChangedListener(ValueChanged<Map<String, dynamic>> fn) {
    _valuesChangedListeners.remove(fn);
  }

  void addErrorsChangedListener(ValueChanged<Map<String, String?>> fn) {
    _errorsChangedListeners.add(fn);
  }

  void removeErrorsChangedListener(ValueChanged<Map<String, String?>> fn) {
    _errorsChangedListeners.remove(fn);
  }

  @override
  Future<void> close() {
    valuesChangedDebouncer.cancel();
    errorsChangedDebouncer.cancel();
    _valuesChangedListeners.clear();
    _errorsChangedListeners.clear();
    state.forEach((key, value) {
      value.clearListeners();
      value.close();
    });
    return super.close();
  }

  void dispose() => close();
}

extension JustFOrmContextExtension on BuildContext {
  JustFormController get justForm => read<JustFormController>();
  JustFormController justForm2() => read<JustFormController>();
}
