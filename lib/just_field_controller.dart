part of 'just_form_builder.dart';

/// The `JustFieldController` class is a state management controller for a field in a form.
/// - `JustFieldController` is a constructor that initializes the `name`, `internal`, and `_controller` fields.
/// - `getValue` and `value` getters return the current value of the field.
/// - `setValue` and `value` setter update the value of the field.
/// - `getError` and `error` getters return the current error of the field.
/// - `setError` and `error` setter set the error of the field.
/// - `isDirty` getter checks if the field's value has changed from its initial value.
/// - `isValid` getter checks if the field's error is null, indicating it's valid.
/// - `state` getter returns the current state of the field.
/// - `initialValue` getter returns the initial value of the field.
/// - `validate` method validates the field and returns a `Future<bool>` indicating if it's valid or not.
/// - `getAttribute` getter returns the value of a specific attribute of the field.
/// - `setAttribute` method sets the value of a specific attribute of the field.
/// - `patchAttribute` method updates a specific attribute of the field using a function that takes the old value and returns the new value.
/// - `updater` getter returns a `JustFieldUpdater` object that can be used to update the field's state.
class JustFieldController<T> {
  late final JustFormController _controller;
  final String name;
  final bool internal;

  /// Constructor for the `JustFieldController` class.
  ///
  /// It initializes the `name`, `internal`, and `_controller` fields.
  JustFieldController({
    required this.name,
    required JustFormController controller,
    required this.internal,
  }) {
    _controller = controller;
  }

  /// Returns the current value of the field. If the field has not been registered yet, it returns null.
  T? getValue() => state?.value;

  /// alias for [getValue]
  T? get value => getValue();

  /// Updates the value of the field with the given value.
  ///
  /// If [internal] is true, the parent form will not be notified about the change.
  /// The method returns immediately and does not block the execution of the calling code.
  /// The actual update of the field is done using a debouncer, which is set to a duration of 300 milliseconds.
  /// This means that the field will only be updated if the value has not changed within the last 300 milliseconds.
  void setValue(T? value) {
    updater.withValue(value, internal: internal).update();
    validate();
  }

  /// alias for [setValue]
  set value(T? value) => setValue(value);

  /// Returns the current error of the field. If the field has not been registered yet, it returns null.
  String? getError() => state?.error;

  /// alias for [getError]
  String? get error => getError();

  /// Sets the error of the field.
  setError(String? error) => updater.withError(error, force: true).update();

  /// alias for [setError]
  set error(String? error) => setError(error);

  /// Checks if the field's value has changed from its initial value.
  bool get isDirty => state?.valueEqualWith(state?.initialValue) ?? false;

  /// Checks if the field's error is null, indicating it's valid.
  bool get isValid => error == null;

  /// Returns the current state of the field. If the field has not been registered yet, it returns null.
  JustFieldState<T>? getState() {
    return _controller
            .state[name] //.where((element) => element.name == name).firstOrNull
        as JustFieldState<T>?;
  }

  /// alias for [getState]
  JustFieldState<T>? get state => getState();

  /// Returns the initial value of the field.
  T? getInitialValue() => state?.initialValue;

  /// alias for [getInitialValue]
  T? get initialValue => getInitialValue();

  /// Validates the field.
  ///
  /// If [force] is true, then the error of the field will be updated even field is untouched.
  /// If the field has not been registered yet, it returns true.
  /// If the validation result is true, then the error of the field will be set to null.
  /// If the validation result is false, then the error of the field will be set to the error returned by the validator.
  Future<bool> validate({bool force = true, noDebounce = false}) async {
    var fieldState = state;
    if (fieldState == null ||
        !fieldState.hasField ||
        fieldState.validators.isNotEmpty) {
      return true;
    }
    var debouncer = _controller._fieldsDebounce[name];
    if (debouncer != null) {
      bool doValidate() {
        return fieldState._validateInner(
          values: _controller.values,
          onFieldError: (name, error, isSelf, msgCheck) {
            if (name == justReservedFieldName) {
              name = this.name;
              isSelf = true;
            }
            if (isSelf) {
              updater.withError(error, force: force).softUpdate();
            } else {
              var target = _controller.field(name);
              var targetUpdater = JustFieldUpdater(
                target.name,
                _controller,
                _controller.field(name).state,
              );
              if (error == null) {
                if (target.error == msgCheck) {
                  targetUpdater.withError(null, force: force).softUpdate();
                }
              } else {
                if (target.error == null) {
                  targetUpdater.withError(error, force: force).softUpdate();
                }
              }
            }
          },
        );
      }

      // print("bounce");

      var validDebounce = noDebounce
          ? doValidate()
          : await debouncer.run(() async {
              return doValidate();
            });

      if (validDebounce) {
        print("whis");
        updater.withError(null).softUpdate();
      }
      // print("here");
      updater.update();
      return validDebounce;
    }
    return false;
  }

  /// Returns the value of the attribute with the given [key].
  /// If the attribute with the given [key] does not exist, it returns null.
  /// The returned value is cast to [X].
  /// If the field has not been registered yet, it returns null.
  X? getAttribute<X>(String key) {
    var fieldState = state;
    if (fieldState?.attributes[key] == null) return null;
    return fieldState?.attributes[key] as X?;
  }

  /// Sets the value of the attribute with the given [key].
  /// If the attribute with the given [key] does not exist, it will be created.
  /// If the field has not been registered yet, it does nothing.
  /// If the field has focus, it will first unfocus the field.
  void setAttribute<X>(String key, X? value) {
    var fieldState = state;
    if (fieldState == null) return;
    var hasFocus = fieldState.focusNode?.hasFocus;
    if (hasFocus == true) {
      fieldState.focusNode?.unfocus();
    }
    updater.withAttributes({key: value}).update();
  }

  /// Patches the attribute with the given [key] by calling the given [patch] function
  /// with the current value of the attribute as the argument.
  /// The result of the [patch] function is then set as the new value of the attribute.
  /// If the attribute with the given [key] does not exist, it will be created.
  void patchAttribute<X>(String key, X? Function(X? oldValue) patch) {
    setAttribute(key, patch(getAttribute(key)));
  }

  /// Returns a [JustFieldUpdater] object that can be used to update the field's state.
  JustFieldUpdater get updater => JustFieldUpdater(name, _controller, state);
}
