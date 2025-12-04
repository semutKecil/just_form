part of 'just_form_builder.dart';

class JustFieldData<T> extends Cubit<JustFieldState<T>> {
  final T? initialValue;
  final bool keepValueOnDestroy;
  final List<String? Function(T? value)> validators;
  final Debouncer<String?> validationDebouncer = Debouncer(
    delay: Duration(milliseconds: 200),
  );
  final List<JustFieldListener<T>> onStateChangedListeners = [];
  final JustFormController _formController;
  bool _touched = false;

  JustFormController? _subFormController;

  int _errorId = -1;
  JustFieldData({
    this.initialValue,
    this.keepValueOnDestroy = true,
    this.validators = const [],
    required JustFormController formController,
    required JustFieldState<T> initialState,
  }) : _formController = formController,
       super(initialState);

  void _setSubFormController(JustFormController? controller) =>
      _subFormController = controller;

  void _update(JustFieldState<T> newState) => emit(newState);

  T? _getValue() => state.value;

  void _setValue(T? value, {bool dontTouch = false, bool internal = false}) {
    if (state.value == value) return;
    if (!dontTouch && !_touched) {
      _touch();
    }
    _update(state.copyWith(value: value, internal: internal));

    if (internal) {
      _validateWithDebounce().then((value) {
        _setError(value, internal: true);
        var error = _formController._xValidate([state.name]);
        error.forEach((key, value) {
          _formController
              ._fieldInternal(key)
              ?._setErrorInternal(value.value, errorId: value.key);
        });
      });
    }
  }

  String? _getError() => state.error;

  void _touch() => _touched = true;

  void _setError(
    String? error, {
    int errorId = -1,
    bool forced = false,
    bool internal = false,
  }) {
    if (state.error == error) return;

    if (!(forced || (errorId == -1 && _touched))) {
      if (!_touched) return;
      if (state.error != null && error != null) return;
      if ((state.error != null && error == null && errorId != _errorId)) return;
    }

    _errorId = errorId;
    _update(state.copyWith(error: error, internal: internal));
  }

  Map<String, dynamic> _getAttributes() => state.attributes;
  void _patchAtrributes(
    Map<String, dynamic> attributes, {
    bool internal = false,
  }) {
    _update(
      state.copyWith(
        attributes: {...state.attributes, ...attributes},
        internal: internal,
      ),
    );
  }

  dynamic _getAttribute(String key) => state.attributes[key];

  Future<String?> _validateWithDebounce() =>
      validationDebouncer.run(() => _validate());

  String? _validate({bool forced = false}) {
    if (forced) {
      if (_subFormController != null) {
        _update(state.copyWith(internal: false));
      }
    }
    if (forced || _touched) {
      for (var validator in validators) {
        var error = validator(state.value);
        if (error != null) return error;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    validationDebouncer.cancel();
    return super.close();
  }

  void addListener(JustFieldListener<T> listener) {
    onStateChangedListeners.add(listener);
  }

  void removeListener(JustFieldListener<T> listener) {
    onStateChangedListeners.remove(listener);
  }

  void clearListeners() {
    onStateChangedListeners.clear();
  }

  @override
  void onChange(Change<JustFieldState<T>> change) {
    super.onChange(change);
    for (var listener in onStateChangedListeners) {
      listener(change.currentState, change.nextState);
    }
  }
}
