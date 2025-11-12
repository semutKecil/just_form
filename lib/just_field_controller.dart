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

  JustFieldState<T>? get field =>
      _controller
              .state[name] //.where((element) => element.name == name).firstOrNull
          as JustFieldState<T>?;

  T? get value => field?.value;

  set value(T? value) {
    updater.withValue(value, internal: internal).update();
    // var fieldState = field;
    // if (fieldState != null) {
    //   _controller._patch(
    //     name,
    //     fieldState._setValue(value: value, isInternalUpdate: internal),
    //   );
    // } else {
    //   if (name == justReservedFieldName) {
    //     throw Exception(
    //       "Reserved Field name. Field name cannot be $justReservedFieldName",
    //     );
    //   }
    //   _controller._add(
    //     name,
    //     JustFieldState<T>(
    //       name: name,
    //       value: value,
    //       initialValue: value,
    //       mode: [JustFieldStateMode.update],
    //     ),
    //   );
    // }

    validate(force: false);
  }

  String? get error => field?.error;

  bool get isValid => error == null;

  set error(String? error) => updater.withError(error, force: true).update();
  // _controller._patch(name, field?._setError(error: error, force: true));

  bool isDirty() => field?.valueEqualWith(field?.initialValue) ?? false;

  T? get initialValue => field?.initialValue;

  Future<bool> validate({bool force = true}) async {
    var fieldState = field;
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
              updater.withError(error, force: force).update();
              // _controller._patch(
              //   name,
              //   fieldState._setError(error: error, force: force),
              // );
            } else {
              var target = _controller.field(name);
              var targetUpdater = JustFieldUpdater(
                target.name,
                _controller,
                _controller.field(name).field,
              );
              if (error == null) {
                if (target.error == msgCheck) {
                  targetUpdater.withError(null, force: force).update();
                  // _controller._patch(
                  //   name,
                  //   target.field?._setError(error: null, force: force),
                  // );
                }
              } else {
                targetUpdater.withError(error, force: force).update();
                // _controller._patch(
                //   name,
                //   target.field?._setError(error: error, force: force),
                // );
              }
            }
          },
        );
      });
      if (validDebounce) {
        updater.withError(null).update();
      }
      return validDebounce;
    }
    return false;
  }

  X? getAttribute<X>(String key) {
    var fieldState = field;
    if (fieldState?.attributes[key] == null) return null;
    return fieldState?.attributes[key] as X?;
  }

  void setAttribute<X>(String key, X? value) {
    var fieldState = field;
    if (fieldState == null) return;
    var hasFocus = fieldState.focusNode?.hasFocus;
    if (hasFocus == true) {
      fieldState.focusNode?.unfocus();
    }
    updater.withAttributes({key: value}).update();
    // _controller._patch(name, fieldState._setAttribute(key: key, value: value));
  }

  void patchAttribute<X>(String key, X? Function(X? oldValue) patch) {
    setAttribute(key, patch(getAttribute(key)));
  }

  JustFieldUpdater get updater => JustFieldUpdater(name, _controller, field);
}
