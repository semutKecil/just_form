part of 'just_form.dart';

class JustFieldController<T> {
  late final JustFormController _controller;
  final String name;
  final bool internal;

  JustFieldController({
    required this.name,
    required JustFormController controller,
    required this.internal,
  }) {
    _controller = controller;
  }

  T? getValue() => state?.value;
  T? get value => getValue();

  void setValue(T? value) {
    updater.withValue(value, internal: internal).update();
  }

  set value(T? value) => setValue(value);

  String? getError() => state?.error;
  String? get error => getError();

  setError(String? error) => updater.withError(error, force: true).update();
  set error(String? error) => setError(error);

  bool get isDirty => state?.valueEqualWith(state?.initialValue) ?? false;

  bool get isValid => error == null;

  JustFieldState<T>? get state =>
      _controller
              .state[name] //.where((element) => element.name == name).firstOrNull
          as JustFieldState<T>?;

  T? get initialValue => state?.initialValue;

  Future<bool> validate({bool force = true}) async {
    var fieldState = state;
    if (fieldState == null) return true;

    var debouncer = _controller._fieldsDebounce[name];
    if (debouncer != null) {
      var validDebounce = await debouncer.run(() async {
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
      });

      if (validDebounce) {
        updater.withError(null).softUpdate();
      }
      updater.update();
      return validDebounce;
    }
    return false;
  }

  X? getAttribute<X>(String key) {
    var fieldState = state;
    if (fieldState?.attributes[key] == null) return null;
    return fieldState?.attributes[key] as X?;
  }

  void setAttribute<X>(String key, X? value) {
    var fieldState = state;
    if (fieldState == null) return;
    var hasFocus = fieldState.focusNode?.hasFocus;
    if (hasFocus == true) {
      fieldState.focusNode?.unfocus();
    }
    updater.withAttributes({key: value}).update();
  }

  void patchAttribute<X>(String key, X? Function(X? oldValue) patch) {
    setAttribute(key, patch(getAttribute(key)));
  }

  JustFieldUpdater get updater => JustFieldUpdater(name, _controller, state);
}
