part of 'just_form.dart';

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

  JustFieldUpdater withValue(T? value, {bool internal = false}) {
    _updateValue = true;
    _internal = internal;
    _value = value;
    return this;
  }

  JustFieldUpdater withError(String? error, {bool force = false}) {
    _updateError = true;
    _forceError = force;
    _error = error;
    return this;
  }

  JustFieldUpdater withAttributes(Map<String, dynamic> attributes) {
    _updateAttributes = true;
    _attributes = attributes;
    return this;
  }

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
        // return JustFieldState<T>(
        //   name: _name,
        //   value: _value,
        //   initialValue: _value,
        //   mode: [JustFieldStateMode.update],
        // );
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

    // return _field._updateField(
    //   mode: mode,
    //   value: _updateValue ? _value : _field.value,
    //   error: _updateError ? _error : _field.error,
    //   attributes: _updateAttributes
    //       ? {..._field.attributes, ..._attributes}
    //       : (_field.attributes),
    //   touched: _updateValue || _updateError ? true : _field.touched,
    //   focusNode: _field.focusNode,
    // );
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

  void update() {
    softUpdate();
    _controller._commit();
  }
}
