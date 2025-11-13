part of 'just_form.dart';

/// This `JustFieldUpdater` class is used to update the state of a field in a form. Here's a summary of what each method does:
/// - `JustFieldUpdater.withValue`: Updates the value of the field with the given value. If `internal` is true, the parent form will not be notified about the change.
/// - `JustFieldUpdater.withError`: Updates the error of the field with the given error. If `force` is true, the error will be updated even if the field has no validators.
/// - `JustFieldUpdater.withAttributes`: Updates the attributes of the field with the given map.
/// - `JustFieldUpdater.softUpdate`: Soft updates the field with the given values. If the field has not been registered yet, it does nothing. If the field has been registered, it updates the field with the given values. If `internal` is true, the parent form will not be notified about the change. If `force` is true, the error will be updated even if the field has no validators. If `updateAttributes` is true, it updates the attributes of the field with the given map. The method updates the pending values map with the current field state and then commits the current pending values to the state and clears the pending values map.
/// - `JustFieldUpdater.update`: Commits the current pending values to the state and clears the pending values map. This method first calls `softUpdate` to update the pending values map with the current field state. Then it calls `_commit` to commit the current pending values to the state and clear the pending values map. This method is used to commit the current state of the form to the `JustFormController.state` after a validation or a value update. This method is not intended to be used directly by the user of the `JustFormController`. It is used internally by the `JustFormController` to manage the state of the form.
class JustFieldUpdater<T> {
  bool _updateValue = false;
  bool _updateError = false;
  bool _updateAttributes = false;
  bool _internal = false;
  T? _value;
  String? _error;
  bool _forceError = false;
  Map<String, dynamic> _attributes = {};
  final String _name;
  final JustFieldState<T>? _field;
  final JustFormController _controller;
  JustFieldUpdater(this._name, this._controller, this._field);

  /// Updates the value of the field with the given value.
  /// If [internal] is true, the parent form will not be notified about the change.
  /// The returned [JustFieldUpdater] can be used to chain multiple updates together.
  /// The actual update of the field is done using a debouncer, which is set to a duration of 300 milliseconds.
  JustFieldUpdater withValue(T? value, {bool internal = false}) {
    _updateValue = true;
    _internal = internal;
    _value = value;
    return this;
  }

  /// Updates the error of the field with the given error.
  /// If [force] is true, the error will be updated even if the field has no validators.
  /// The returned `JustFieldUpdater` can be used to chain multiple updates together.
  /// The actual update of the field is done using a debouncer, which is set to a duration of 300 milliseconds.
  JustFieldUpdater withError(String? error, {bool force = false}) {
    _updateError = true;
    _forceError = force;
    _error = error;
    return this;
  }

  /// Updates the attributes of the field with the given map.
  /// The returned `JustFieldUpdater` can be used to chain multiple updates together.
  JustFieldUpdater withAttributes(Map<String, dynamic> attributes) {
    _updateAttributes = true;
    _attributes = attributes;
    return this;
  }

  /// Soft updates the field with the given values.
  /// If the field has not been registered yet, it does nothing.
  /// If the field has been registered, it updates the field with the given values.
  /// If [internal] is true, the parent form will not be notified about the change.
  /// If [force] is true, the error will be updated even if the field has no validators.
  /// If [updateAttributes] is true, it updates the attributes of the field with the given map.
  void softUpdate() {
    if (_field == null) {
      if (_updateValue) {
        if (_name == justReservedFieldName) {
          throw Exception(
            "Reserved Field name. Field name cannot be $justReservedFieldName",
          );
        }

        _controller._pendingPatch(
          _name,
          JustFieldState<T>(
            name: _name,
            value: _value,
            initialValue: _value,
            mode: [JustFieldStateMode.update],
          ),
        );
      }
      return;
    }
    if (_updateValue == false &&
        _updateError == false &&
        _updateAttributes == false) {
      return;
    }
    List<JustFieldStateMode> mode = [];
    if (_updateValue) {
      if (_internal) {
        mode.add(JustFieldStateMode.updateInternal);
      } else {
        mode.add(JustFieldStateMode.update);
      }
    }

    if (_updateError && (_field.touched == true || _forceError)) {
      mode.add(JustFieldStateMode.error);
    }

    if (_updateAttributes) {
      mode.add(JustFieldStateMode.attribute);
      var hasFocus = _field.focusNode?.hasFocus;
      if (hasFocus == true) {
        _field.focusNode?.unfocus();
      }
    }

    _controller._pendingPatch(
      _name,
      _field._updateField(
        mode: mode,
        value: _updateValue ? _value : _field.value,
        error: _updateError ? _error : _field.error,
        attributes: _updateAttributes
            ? {..._field.attributes, ..._attributes}
            : (_field.attributes),
        touched: _updateValue || _updateError ? true : _field.touched,
        focusNode: _field.focusNode,
      ),
    );
  }

  /// Commits the current pending values to the state and clears the pending values map.
  ///
  /// This method first calls [softUpdate] to update the pending values map with the
  /// current field state. Then it calls [_commit] to commit the current pending values
  /// to the state and clear the pending values map.
  ///
  /// This method is used to commit the current state of the form to the [JustFormController.state]
  /// after a validation or a value update.
  ///
  /// This method is not intended to be used directly by the user of the [JustFormController].
  /// It is used internally by the [JustFormController] to manage the state of the form.
  void update() {
    softUpdate();
    _controller._commit();
  }
}
