part of 'just_form_builder.dart';

class JustField<T> extends StatefulWidget {
  final String name;
  final T? initialValue;
  final Widget Function(
    BuildContext context,
    JustFieldInternalController<T> state,
  )
  builder;
  final VoidCallback? onInitialized;
  final bool notifyError;
  final bool notifyInternalUpdate;
  final List<FormFieldValidator<T>> validators;
  final bool Function(T a, T b)? isEqual;
  final void Function(T? value, bool isInternalUpdate)? onChanged;
  final FocusNode? focusNode;
  final bool saveValueOnDestroy;

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
    this.onInitialized,
    this.focusNode,
    this.saveValueOnDestroy = true,
  });

  @override
  State<JustField<T>> createState() => _JustFieldState<T>();
}

class _JustFieldState<T> extends State<JustField<T>> {
  late final JustFieldController<T> _fieldController;
  late final JustFormController _formController;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _formController = context.justForm;
    _fieldController = _formController._register(
      JustFieldState<T>(
        name: widget.name,
        value: widget.initialValue,
        validators: widget.validators,
        isEqual: widget.isEqual,
        focusNode: widget.focusNode,
        attributes: {},
        touched: false,
        mode: [JustFieldStateMode.none],
        initialValue: widget.initialValue,
        error: null,
      ),
    );
    widget.onInitialized?.call();

    if (widget.onChanged != null) {
      _sub = _fieldController.stream.listen((event) {
        if (event.mode.contains(JustFieldStateMode.update)) {
          widget.onChanged?.call(event.value, false);
        } else if (event.mode.contains(JustFieldStateMode.updateInternal)) {
          widget.onChanged?.call(event.value, true);
        }
      });
    }
  }

  @override
  void dispose() {
    _formController._remove(widget.name, widget.saveValueOnDestroy);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustFormController, Map<String, JustRegisteredField>>(
      buildWhen: (previous, current) {
        current.entries
                .where((e) => e.value.controller != null)
                .map((e) => e.key)
                .contains(widget.name) !=
            previous.entries
                .where((e) => e.value.controller != null)
                .map((e) => e.key)
                .contains(widget.name);
        return false;
      },
      builder: (context, state) {
        if (!state.entries
            .where((e) => e.value.controller != null)
            .map((e) => e.key)
            .contains(widget.name)) {
          return SizedBox.shrink();
        }

        return BlocBuilder<JustFieldController<T>, JustFieldState<T>>(
          bloc: _fieldController,
          buildWhen: (previous, current) {
            for (var mode in current.mode) {
              switch (mode) {
                case JustFieldStateMode.update:
                  if (!current.valueEqualWith(previous.value)) {
                    return true;
                  }
                  break;
                case JustFieldStateMode.updateInternal:
                  if (widget.notifyInternalUpdate &&
                      !current.valueEqualWith(previous.value)) {
                    return true;
                  }
                  break;
                case JustFieldStateMode.error:
                  if (widget.notifyError && current.error != previous.error) {
                    return true;
                  }
                  break;
                case JustFieldStateMode.attribute:
                  return true;
                case JustFieldStateMode.none:
                case JustFieldStateMode.initialization:
                case JustFieldStateMode.validateExternal:
                  break;
              }
            }
            return false;
          },
          builder: (context, state) {
            try {
              return widget.builder(context, _fieldController._internal);
            } catch (e) {
              throw ("${widget.name} : Field builder error", e);
            }
          },
        );
      },
    );
  }
}
