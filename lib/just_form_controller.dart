part of 'just_form_builder.dart';

const String justReservedFieldName = "_self";

class JustRegisteredField<T> {
  final String name;
  final T? initialValue;
  final T? savedValue;
  final JustFieldController<T>? controller;
  const JustRegisteredField({
    required this.name,
    this.initialValue,
    this.savedValue,
    this.controller,
  });
}

class JustFormController extends Cubit<Map<String, JustRegisteredField>> {
  final List<JustValidator> validators = [];

  JustFormController({Map<String, dynamic> initialValues = const {}})
    : super(
        initialValues.map(
          (key, value) => MapEntry(
            key,
            JustRegisteredField(name: key, initialValue: value),
          ),
        ),
      );

  Map<String, dynamic> getValues({withHiddenFields = false}) {
    var usedState = withHiddenFields
        ? Map.from(state)
        : (Map.from(state)
            ..removeWhere((key, value) => value.controller == null));
    return usedState.map(
      (key, value) =>
          MapEntry(key, value.controller?.state.value ?? value.savedValue),
    );
  }

  final List<ValueChanged<Map<String, dynamic>>> _valuesChangedListeners = [];
  final List<ValueChanged<Map<String, String?>>> _errorChangedListeners = [];

  void addValuesChangedListener(ValueChanged<Map<String, dynamic>> listener) {
    _valuesChangedListeners.add(listener);
  }

  void removeValuesChangedListener(
    ValueChanged<Map<String, dynamic>> listener,
  ) {
    _valuesChangedListeners.remove(listener);
  }

  void _notifyValuesChangedListeners() {
    print("outer lustner");
    if (_valuesChangedListeners.isEmpty) return;
    var value = getValues(withHiddenFields: true);
    for (var listener in _valuesChangedListeners) {
      Future(() {
        listener(value);
      });
    }
  }

  void addErrorChangedListener(ValueChanged<Map<String, String?>> listener) {
    _errorChangedListeners.add(listener);
  }

  void removeErrorChangedListener(ValueChanged<Map<String, String?>> listener) {
    _errorChangedListeners.remove(listener);
  }

  void _notifyErrorChangedListeners() {
    if (_errorChangedListeners.isEmpty) return;
    var value = getErrors();
    for (var listener in _errorChangedListeners) {
      Future(() {
        listener(value);
      });
    }
  }

  Map<String, dynamic> get values => getValues();

  void patchValues(Map<String, dynamic> patch) {
    Map<String, JustRegisteredField> noController = {};
    patch.forEach((key, value) {
      if (state[key]?.controller == null) {
        var registered = state[key];
        if (state[key] == null) {
          noController[key] = JustRegisteredField(
            name: key,
            initialValue: value,
            savedValue: value,
          );
        } else {
          noController[key] = JustRegisteredField(
            name: key,
            initialValue: registered!.initialValue,
            savedValue: value,
          );
        }
      } else {
        state[key]?.controller?._changeValue(
          value,
          validateForm: false,
          triggerChangeListeners: false,
        );
      }
    });

    if (noController.isNotEmpty) emit({...state, ...noController});

    _notifyValuesChangedListeners();
    _validateForm(patch.keys.toList());
  }

  bool validate() {
    state.values.where((registered) => registered.controller != null).forEach((
      registered,
    ) {
      registered.controller!.setError(
        registered.controller!._innerValidate(
          registered.controller!.state,
          external: true,
        ),
      );
    });

    _validateForm(state.keys.toList());

    return isValid;
  }

  get isValid => getErrors().isEmpty;

  Map<String, String?> getErrors() {
    var error = Map<String, JustRegisteredField>.from(state).map((key, value) {
      return MapEntry(key, value.controller?.getError());
    })..removeWhere((key, value) => value == null);

    return error;
  }

  Map<String, String?> get errors => getErrors();

  Map<String, JustFieldController?> get fields =>
      state.map((key, value) => MapEntry(key, value.controller));
  JustFieldController<T>? field<T>(String name) =>
      state[name]?.controller as JustFieldController<T>?;

  void _remove(String fieldName, bool saveValueOnRemove) {
    var registeredField = state[fieldName];
    if (registeredField == null) return;

    emit({
      ...state,
      ...{
        fieldName: JustRegisteredField(
          name: fieldName,
          initialValue: registeredField.initialValue,
          savedValue: saveValueOnRemove
              ? (registeredField.controller?.state.value)
              : registeredField.initialValue,
          controller: registeredField.controller,
        ),
      },
    });
  }

  JustFieldController<T> _register<T>(JustFieldState<T> initialState) {
    var registeredField = state[initialState.name];
    JustFieldController<T> fieldController =
        (registeredField?.controller as JustFieldController<T>?) ??
        JustFieldController<T>(initialState);
    fieldController._formController = this;

    if (registeredField != null) {
      fieldController._changeValue(
        registeredField.savedValue ?? registeredField.initialValue,
        mode: JustFieldStateMode.initialization,
      );
    }

    emit({
      ...state,
      ...{
        fieldController.state.name: JustRegisteredField(
          name: fieldController.state.name,
          controller: fieldController,
          initialValue:
              registeredField?.initialValue ?? fieldController.state.value,
          savedValue:
              registeredField?.savedValue ??
              registeredField?.initialValue ??
              fieldController.state.value,
        ),
      },
    });
    // if (registeredField == null) {
    //   emit({
    //     ...state,
    //     ...{
    //       fieldController.state.name: JustRegisteredField(
    //         name: fieldController.state.name,
    //         controller: fieldController,
    //         initialValue: fieldController.state.value,
    //         savedValue: fieldController.state.value,
    //       ),
    //     },
    //   });
    //   return fieldController;
    // } else {
    //   fieldController._changeValue(
    //     registeredField.savedValue ?? registeredField.initialValue,
    //     mode: JustFieldStateMode.initialization,
    //   );
    //   emit({
    //     ...state,
    //     ...{
    //       fieldController.state.name: JustRegisteredField(
    //         name: fieldController.state.name,
    //         controller: fieldController,
    //         initialValue: registeredField.initialValue,
    //         savedValue:
    //             registeredField.savedValue ?? registeredField.initialValue,
    //       ),
    //     },
    //   });
    // fieldController.close();
    return fieldController;
    // }
  }

  void _validateForm(List<String> fields) {
    if (validators.isEmpty) return;

    for (var f in fields) {
      var triggerValidators = validators
          .where((e) => e.triggers.contains(f))
          .toList();

      for (int i = 0; i < triggerValidators.length; i++) {
        var validator = triggerValidators[i];
        if (validator.targets.isEmpty && field(f)?.state.error != null) {
          continue;
        }
        if (validator.targets.isEmpty) {
          field(f)?.setError(validator.validator(values));
        } else {
          for (var target in validator.targets) {
            var targetField = field(target.field);
            if (targetField == null) continue;

            var error = validator.validator(values);
            if (error != null && targetField.state.error == null) {
              targetField.setError(target.message(error), errorId: i);
            } else if (error == null && targetField.state.errorId == i) {
              targetField.setError(null);
            }
          }
        }
      }
    }
  }

  void dispose() {
    _valuesChangedListeners.clear();
    _errorChangedListeners.clear();
    state.values.map((e) => e.controller).forEach((element) {
      element?.dispose();
    });
    Future.wait(state.values.map((e) async => e.controller?.close()));
    close();
  }
}

extension JustFOrmContextExtension on BuildContext {
  JustFormController get justForm => read<JustFormController>();
  JustFormController justForm2() => read<JustFormController>();
}
