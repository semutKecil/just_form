part of 'just_form.dart';

class JustField<T> extends StatelessWidget {
  final String name;
  final T? initialValue;
  final Widget Function(BuildContext context, JustFieldController<T> state)
  builder;
  final bool notifyError;
  final bool notifyInternalUpdate;
  final List<JustValidator<T>> validators;
  final bool Function(T a, T b)? isEqual;
  final void Function(T? value, bool isInternalUpdate)? onChanged;
  final FocusNode? focusNode;
  const JustField({
    super.key,
    required this.name,
    required this.builder,
    this.initialValue,
    this.notifyError = true,
    this.notifyInternalUpdate = false,
    this.validators = const [],
    this.isEqual,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return _JustFieldInner(
      name: name,
      controller: context.read<JustFormController>(),
      builder: builder,
      initialValue: initialValue,
      notifyError: notifyError,
      notifyInternalUpdate: notifyInternalUpdate,
      validators: validators,
      isEqual: isEqual,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }
}

class _JustFieldInner<T> extends StatefulWidget {
  final JustFormController controller;
  final String name;
  final T? initialValue;
  final Widget Function(BuildContext context, JustFieldController<T> state)
  builder;
  final bool notifyError;
  final bool notifyInternalUpdate;
  final List<JustValidator<T>> validators;
  final bool Function(T a, T b)? isEqual;
  final void Function(T? value, bool isInternalUpdate)? onChanged;
  final FocusNode? focusNode;
  const _JustFieldInner({
    super.key,
    required this.controller,
    required this.name,
    required this.builder,
    this.initialValue,
    this.notifyError = true,
    this.notifyInternalUpdate = false,
    this.validators = const [],
    this.isEqual,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<_JustFieldInner<T>> createState() => _JustFieldInnerState<T>();
}

class _JustFieldInnerState<T> extends State<_JustFieldInner<T>> {
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      _sub = widget.controller.stream.listen((event) {
        var field = event[widget.name];
        if (field == null) return;
        if (field.mode.contains(JustFieldStateMode.update)) {
          widget.onChanged?.call(field.value, false);
        } else if (field.mode.contains(JustFieldStateMode.updateInternal)) {
          widget.onChanged?.call(field.value, true);
        }
      });
    }

    widget.controller._registerField<T>(
      widget.name,
      widget.initialValue,
      widget.validators,
      widget.isEqual,
      widget.focusNode,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    widget.controller._unReg(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustFormController, Map<String, JustFieldState>>(
      buildWhen: (previous, current) {
        var previousField = previous[widget.name];

        var currentField = current[widget.name];

        if (currentField == null) return false;

        for (var mode in currentField.mode) {
          switch (mode) {
            case JustFieldStateMode.update:
              if (!currentField.valueEqualWith(previousField?.value)) {
                debugPrint("build ${widget.name} when update external");
                return true;
              }
              break;
            case JustFieldStateMode.updateInternal:
              if (widget.notifyInternalUpdate &&
                  !currentField.valueEqualWith(previousField?.value)) {
                debugPrint("build ${widget.name} when update internal");
                return true;
              }
              break;
            case JustFieldStateMode.error:
              if (widget.notifyError &&
                  previousField?.error != currentField.error) {
                debugPrint("build ${widget.name} when error");
                return true;
              }
              break;
            case JustFieldStateMode.attribute:
              debugPrint("build ${widget.name} when attribute");
              return true;
            case JustFieldStateMode.none:
              break;
          }
        }
        return false;
      },
      builder: (context, state) {
        try {
          var field = state[widget.name] as JustFieldState<T>?;
          // (state.where((element) => element.name == widget.name).first)
          //     as JustFieldState<T>?;

          if (field == null) throw ();
          return widget.builder(
            context,
            widget.controller._internalField<T>(widget.name),
          );
        } catch (e) {
          throw ("${widget.name} : Field builder error", e);
        }
      },
    );
  }
}
