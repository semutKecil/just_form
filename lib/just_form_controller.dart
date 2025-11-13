part of 'just_form.dart';

const String justReservedFieldName = "_self";

class JustFormController extends Cubit<Map<String, JustFieldState>> {
  JustFormController({Map<String, dynamic>? initialValues}) : super({}) {
    if (initialValues != null && initialValues.isNotEmpty) {
      values = initialValues;
    }
  }

  final Map<String, Debouncer<bool>> _fieldsDebounce = {};
  final Set<String> _registeredFields = {};
  Map<String, JustFieldState> _pendingValues = {};

  Map<String, dynamic> getValues() =>
      state.map((key, value) => MapEntry(key, value.value));

  Map<String, dynamic> get values {
    return getValues();
  }

  void setValues(Map<String, dynamic> values, {bool withValidation = false}) {
    for (var entry in values.entries) {
      field(entry.key).updater.withValue(entry.value).softUpdate();
    }
    _commit();
    if (withValidation) {
      validate();
    }
  }

  set values(Map<String, dynamic> values) {
    setValues(values);
  }

  Future<bool> validate({exitOnFirstError = false}) async {
    var valid = true;
    for (var fieldState in state.values) {
      if (!await field(fieldState.name).validate()) {
        if (exitOnFirstError) {
          return false;
        }

        if (valid == true) {
          valid = false;
        }
      }
    }
    return valid;
  }

  Map<String, String?> get errors {
    return Map.fromEntries(state.values.map((e) => MapEntry(e.name, e.error)));
  }

  bool get isValid => state.values.every((element) => element.error == null);

  JustFieldController<T> field<T>(String name) => _field(name);

  void _commit() {
    var clean = Map<String, JustFieldState>.from(state).map((key, value) {
      return MapEntry(key, value._clean());
    });

    emit({...clean, ..._pendingValues});
    _pendingValues = Map.from(state);
  }

  void _pendingPatch(String name, JustFieldState field) {
    if (_pendingValues.isEmpty) {
      _pendingValues = Map.from(state);
    }
    _pendingValues[name] = field;
  }

  void _patch(String name, JustFieldState field) {
    _pendingPatch(name, field);
    _commit();
  }

  void _unReg(String name) {
    var fieldController = field(name);
    var fState = fieldController.state;
    if (fState == null) return;
    _patch(
      name,
      fState._updateField(
        mode: [JustFieldStateMode.none],
        value: fState.value,
        error: fState.error,
        attributes: fState.attributes,
        touched: false,
        focusNode: null,
      ),
    );
    _registeredFields.remove(name);
  }

  void _registerField<T>(
    String name,
    T? initialValue,
    List<JustValidator<T>> validators,
    bool Function(T a, T b)? isEqual,
    FocusNode? focusnode,
  ) {
    if (_registeredFields.contains(name)) {
      throw Exception("Field $name already registered");
    }

    if (name == justReservedFieldName) {
      throw Exception(
        "Reserved Field name. Field name cannot be $justReservedFieldName",
      );
    }
    _registeredFields.add(name);
    var fieldController = field(name);
    var fieldState = fieldController.state;

    if (!_fieldsDebounce.containsKey(name)) {
      _fieldsDebounce[name] = Debouncer(delay: Duration(milliseconds: 200));
    }

    if (fieldState != null) {
      _patch(
        name,
        JustFieldState<T>(
          name: name,
          mode: [JustFieldStateMode.update],
          initialValue: fieldState.initialValue as T?,
          validators: validators,
          isEqual: isEqual,
          attributes: fieldState.attributes,
          value: fieldState.value as T?,
          focusNode: focusnode,
        ),
      );
    } else {
      _patch(
        name,
        JustFieldState<T>(
          name: name,
          validators: validators,
          isEqual: isEqual,
          mode: [JustFieldStateMode.update],
          value: initialValue,
          initialValue: initialValue,
          focusNode: focusnode,
        ),
      );
    }
  }

  JustFieldController<T> _field<T>(String name, {bool internal = false}) =>
      JustFieldController<T>(controller: this, name: name, internal: internal);

  @override
  Future<void> close() {
    for (var element in _fieldsDebounce.values) {
      element.cancel();
    }
    return super.close();
  }

  void dispose() => close();
}
