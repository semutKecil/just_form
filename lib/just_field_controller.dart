part of 'just_form_builder.dart';

typedef JustFieldListener<T> =
    void Function(JustFieldState<T> from, JustFieldState<T> to);

class JustFieldController<T> {
  final JustFieldData<T> _cubit;
  final bool internal;

  const JustFieldController(this._cubit, {this.internal = false});

  JustFieldState<T> getState() => _cubit.state;

  T? getValue() => _cubit._getValue();
  void setValue(T? value) {
    _cubit._setValue(value, internal: internal, dontTouch: false);
  }

  String? getError() => _cubit._getError();

  void setError(String? error) {
    _cubit._setError(error, internal: internal, forced: true);
  }

  set value(T? value) => setValue(value);
  T? get value => getValue();
  String? get error => getError();
  set error(String? error) => setError(error);

  void _setErrorInternal(String? error, {int errorId = -1}) {
    _cubit._setError(error, internal: true, forced: false, errorId: errorId);
  }

  Map<String, dynamic> getAttributes() => _cubit._getAttributes();

  void patchAttributes(Map<String, dynamic> attributes) {
    _cubit._patchAtrributes(attributes, internal: internal);
  }

  X? getAttribute<X>(String name) => _cubit._getAttribute(name) as X?;

  void setAttribute(String name, dynamic value) {
    patchAttributes({name: value});
  }

  void touch() => _cubit._touch();

  void addListener(JustFieldListener<T> listener) =>
      _cubit.addListener(listener);

  void removeListener(JustFieldListener<T> listener) =>
      _cubit.removeListener(listener);

  void _setSubFormController(JustFormController? controller) =>
      _cubit._setSubFormController(controller);

  JustFormController? getSubForm() => _cubit._subFormController;
}
