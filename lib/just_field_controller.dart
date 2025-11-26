part of 'just_form_builder.dart';

class JustFieldController<T> extends Cubit<JustFieldState<T>>
    implements JustFieldInternalControllerInterface<T> {
  JustFormController? _formController;
  JustFieldController(super.initialState);

  void update(JustFieldState<T> newState) {
    // print("emit ${newState.name} ${newState.mode}");
    emit(newState);
  }

  final Debouncer _validationDebouncer = Debouncer(
    delay: Duration(milliseconds: 200),
  );

  @override
  T? getValue() => state.value;

  @override
  T? get value => getValue();

  @override
  String? getError() => state.error;

  @override
  String? get error => getError();

  @override
  X? getAttribute<X>(String attributeName) =>
      state.attributes[attributeName] as X?;

  void setAttribute(String key, value) {
    patchAttribute(key, value);
  }

  JustFieldInternalController<T> get _internal =>
      JustFieldInternalController(this);

  void _changeValue(
    T? value, {
    JustFieldStateMode mode = JustFieldStateMode.update,
    bool validateForm = true,
    bool triggerChangeListeners = true,
  }) {
    var newState = state.copyWith(
      value: value,
      mode: [mode],
      initialValue: mode == JustFieldStateMode.initialization
          ? value
          : state.initialValue,
    );
    if (mode == JustFieldStateMode.updateInternal) {
      update(newState);
      _validationDebouncer.run(() {
        setError(_innerValidate(newState));
        _formController?._validateForm([state.name]);
      });
    } else if (mode == JustFieldStateMode.update) {
      var error = _innerValidate(newState);
      if (error == null) {
        update(newState._clearError(addMode: true));
      } else {
        update(
          newState.copyWith(
            mode: newState.mode..add(JustFieldStateMode.error),
            error: error,
          ),
        );
      }
      if (validateForm) {
        _formController?._validateForm([state.name]);
      }
    } else {
      update(newState);
    }

    if (triggerChangeListeners && mode != JustFieldStateMode.initialization) {
      _formController?._notifyValuesChangedListeners();
    }
  }

  void setValue(T? value) =>
      _changeValue(value, mode: JustFieldStateMode.update);

  set value(T? value) => setValue(value);

  /// Set the error of the field to [error]. If [error] is null, clear the error.
  /// If the error is the same as the current error, do nothing.
  ///
  /// [errorId] is an optional parameter to specify an error id. If not provided, it defaults to -1.
  ///
  /// Call this function to notify the form of an error change.
  void setError(String? error, {int errorId = -1}) {
    if (error == state.error) return;
    update(
      error == null
          ? state._clearError()
          : state.copyWith(
              error: error,
              mode: [JustFieldStateMode.error],
              errorId: errorId,
            ),
    );

    _formController?._notifyErrorChangedListeners();
  }

  set error(String? error) => setError(error);

  void patchAttribute<X>(String attributeName, X? Function(X? value) builder) {
    patchAttributes({attributeName: builder(state.attributes[attributeName])});
  }

  void patchAttributes(Map<String, dynamic> attributes) {
    state.focusNode?.unfocus();
    update(
      state.copyWith(
        attributes: {...state.attributes, ...attributes},
        mode: [JustFieldStateMode.attribute],
      ),
    );
  }

  @override
  Map<String, dynamic> getAttributes() {
    return state.attributes;
  }

  @override
  Map<String, dynamic> get attributes => getAttributes();

  @override
  Future<void> close() {
    _validationDebouncer.cancel();
    return super.close();
  }

  void dispose() {
    close();
  }

  void validate() {
    setError(_innerValidate(state, external: true));
    _formController?._validateForm([state.name]);
  }

  String? _innerValidate(JustFieldState<T> state, {bool external = false}) {
    if (external) {
      update(state.copyWith(mode: [JustFieldStateMode.validateExternal]));
    }

    String? valid;
    for (var validator in state.validators) {
      valid = validator?.call(state.value);
      if (valid != null) break;
    }
    return valid;
  }
}

abstract class JustFieldInternalControllerInterface<T> {
  T? getValue();
  T? get value;

  String? getError();
  String? get error;

  Map<String, dynamic> getAttributes();
  Map<String, dynamic> get attributes;

  X? getAttribute<X>(String key);
}

class JustFieldInternalController<T>
    implements JustFieldInternalControllerInterface<T> {
  final JustFieldController<T> _controller;
  JustFieldInternalController(this._controller);

  @override
  T? getValue() => _controller.state.value;
  @override
  T? get value => getValue();

  @override
  String? getError() => _controller.state.error;
  @override
  String? get error => getError();

  @override
  Map<String, dynamic> getAttributes() => _controller.state.attributes;
  @override
  Map<String, dynamic> get attributes => getAttributes();

  @override
  X? getAttribute<X>(String key) => _controller.state.attributes[key];

  void setValue(T? value) {
    _controller._changeValue(value, mode: JustFieldStateMode.updateInternal);
  }

  set value(T? value) => setValue(value);
}
