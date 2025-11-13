part of 'just_form.dart';

const String justReservedFieldName = "_self";

/// This `JustFormController` class is a state management controller for a form. Here's a summary of what each method does:
///
/// - `JustFormController({Map<String, dynamic>? initialValues})`: This is the constructor for the class. It initializes the form controller with an optional `initialValues` map.
/// - `getValues()`: This method returns a map of field names to their current values.
/// - `setValues(Map<String, dynamic> values, {bool withValidation = false})`: This method sets multiple field values at the same time. If `withValidation` is true, it also calls the `validate` method after setting the values.
/// - `validate({exitOnFirstError = false})`: This method validates all the fields in the form. If `exitOnFirstError` is true, it returns false as soon as it encounters a field with an error. Otherwise, it returns false only if all the fields have errors.
/// - `getErrors()`: This method returns a map of field names to their current errors.
/// - `get isValid`: This getter returns true if all the fields in the form have no errors.
/// - `field(String name)`: This method returns a `JustFieldController` for the given field name. The returned controller can be used to get the value of the field, set the value of the field, and validate the field.
/// - `_commit()`: This method commits the current pending values to the state and clears the pending values map. It's used internally by the `JustFormController` to manage the state of the form.
/// - `_pendingPatch(String name, JustFieldState field)`: This method patches the given field into the `_pendingValues` map. If the `_pendingValues` map is empty, it initializes it with a copy of the current state. It's used internally by the `JustFormController` to manage the pending values of the form.
/// - `_patch(String name, JustFieldState field)`: This method patches the given field into the `_pendingValues` map and then commits the pending values to the state. It's used internally by the `JustFormController` to manage the state of the form.
/// - `_unReg(String name)`: This method unregisters the given field from the form controller and removes all its associated data from the state and the pending values map. It's used internally by the `JustFormController` to manage the state of the form.
/// - `_registerField(T initialValue, List<JustValidator<T>> validators, bool Function(T a, T b)? isEqual, FocusNode? focusnode)`: This method registers a field with the given name, initial value, validators, isEqual, and focusnode into the form controller. It's used internally by the `JustFormController` to manage the state of the form.
/// - `_field<T>(String name, {bool internal = false})`: This method returns a `JustFieldController` for the given field name. If `internal` is true, the controller will not notify the parent about changes to the value of the field.
/// - `close()`: This method cancels all the pending debounces of the fields and then calls the parent's close method. It overrides the parent's close method.
/// - `dispose()`: This method calls the parent's close method. It's equivalent to `close()`.
class JustFormController extends Cubit<Map<String, JustFieldState>> {
  /// Creates a new instance of [JustFormController].
  ///
  /// The [initialValues] can be used to set the initial values of the form.
  JustFormController({Map<String, dynamic>? initialValues}) : super({}) {
    if (initialValues != null && initialValues.isNotEmpty) {
      values = initialValues;
    }
  }

  final Map<String, Debouncer<bool>> _fieldsDebounce = {};
  final Set<String> _registeredFields = {};
  Map<String, JustFieldState> _pendingValues = {};

  /// Returns a map of field names to their current values.
  ///
  /// The returned map has the same keys as [state] and the values are
  /// the current values of the fields.
  ///
  Map<String, dynamic> getValues() {
    return state.map((key, value) => MapEntry(key, value.value));
  }

  /// alias for [getValues]
  Map<String, dynamic> get values {
    return getValues();
  }

  /// Sets multiple field values at the same time.
  ///
  /// [values] is a map of field names to their new values.
  ///
  /// If [withValidation] is true, then this function will also call
  /// [validate] after setting the values.
  ///
  void setValues(Map<String, dynamic> values, {bool withValidation = false}) {
    for (var entry in values.entries) {
      field(entry.key).updater.withValue(entry.value).softUpdate();
    }
    _commit();
    if (withValidation) {
      validate();
    }
  }

  /// alias for [setValues]
  set values(Map<String, dynamic> values) {
    setValues(values);
  }

  /// Validates all the fields in the form.
  ///
  /// If [exitOnFirstError] is true, then this function will return false
  /// as soon as it encounters a field with an error. Otherwise, it will
  /// return false only if all the fields have errors.
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

  /// Returns a map of field names to their current errors. If a field has
  /// no error, then the value associated with that field name is null.
  ///
  /// Map&lt;String, String?&gt; errors = form.getErrors();
  /// print(errors); // prints {field1: null, field2: 'error message'}
  Map<String, String?> getErrors() {
    return Map.fromEntries(state.values.map((e) => MapEntry(e.name, e.error)));
  }

  /// alias for [getErrors]
  Map<String, String?> get errors => getErrors();

  /// Returns true if all the fields in the form have no errors.
  bool get isValid => state.values.every((element) => element.error == null);

  /// Returns a [JustFieldController] for the given field name.
  ///
  /// The returned [JustFieldController] can be used to get the value
  /// of the field, set the value of the field, and validate the field.
  JustFieldController<T> field<T>(String name) => _field(name);

  /// Commits the current pending values to the state and clears the pending values map.
  /// This function is used internally by the [JustFormController] to commit the
  /// current state of the form to the [JustFormController.state] after a
  /// validation or a value update.
  /// This function is not intended to be used directly by the user of the
  /// [JustFormController]. It is used internally by the [JustFormController] to
  /// manage the state of the form.
  void _commit() {
    var clean = Map<String, JustFieldState>.from(state).map((key, value) {
      return MapEntry(key, value._clean());
    });

    emit({...clean, ..._pendingValues});
    _pendingValues = Map.from(state);
  }

  /// Patches the given field into the [_pendingValues] map.
  /// If the [_pendingValues] map is empty, then it is initialized with a copy of the current state.
  /// This function is used internally by the [JustFormController] to manage the pending values of the form.
  void _pendingPatch(String name, JustFieldState field) {
    if (_pendingValues.isEmpty) {
      _pendingValues = Map.from(state);
    }
    _pendingValues[name] = field;
  }

  /// Patches the given field into the [_pendingValues] map and then commits the pending values to the state.
  ///
  /// This function is used internally by the [JustFormController] to manage the state of the form.
  /// It is not intended to be
  void _patch(String name, JustFieldState field) {
    _pendingPatch(name, field);
    _commit();
  }

  /// Unregisters the given field from the form controller and removes all its associated data from the state and the pending values map.
  /// This function is used internally by the [JustFormController] to manage the state of the form.
  /// It is not intended to be used directly by the user of the [JustFormController].
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

  /// Registers a field with the given [name], [initialValue], [validators], [isEqual] and [focusnode] into the form controller.
  ///
  /// This function is used internally by the [JustFormController] to manage the state of the form.
  /// It is not intended to be used directly by the user of the [JustFormController].
  /// If a field with the same [name] is already registered, an exception is thrown.
  /// If the given [name] is the reserved field name "$justReservedFieldName", an exception is thrown.
  /// The given [initialValue] is used to initialize the field's value in the form controller's state.
  /// The given [validators] are used to validate the field's value.
  /// The given [isEqual] is used to compare the field's value for equality.
  /// The given [focusnode] is used to associate the field with a focus node in the form controller's state.
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

  /// Returns a [JustFieldController] for the given field name.
  ///
  /// If [internal] is true, the controller will not notify the
  /// parent about changes to the value of the field.
  ///
  /// The returned [JustFieldController] can be used to get the value
  /// of the field, set the value of the field, and validate the field.
  JustFieldController<T> _field<T>(String name, {bool internal = false}) =>
      JustFieldController<T>(controller: this, name: name, internal: internal);

  /// Cancels all the pending debounces of the fields and then calls the parent's close method.
  @override
  Future<void> close() {
    for (var element in _fieldsDebounce.values) {
      element.cancel();
    }
    return super.close();
  }

  void dispose() => close();
}
