part of 'just_form_builder.dart';

abstract class JustFieldValidatorAbstract<T> extends JustFieldAbstract<T> {
  List<FormFieldValidator<T>> get validators;
}

abstract class JustFieldAbstract<T> {
  String get name;
  T? get initialValue;
  bool get keepValueOnDestroy;
  Map<String, dynamic> get initialAttributes;
  ValueChanged<T>? get onChanged;
}

class JustField<T> extends StatefulWidget {
  final Widget Function(BuildContext context, JustFieldController<T> state)
  builder;
  final String name;
  final T? initialValue;
  final List<FormFieldValidator<T>> validators;
  final void Function(JustFieldState<T> state)? onRegistered;
  final void Function(T? value, bool isInternal)? onChanged;
  final void Function(String? error, bool isInternal)? onErrorChanged;
  final void Function(Map<String, dynamic> attributes, bool isInternal)?
  onAttributeChanged;
  final bool keepValueOnDestroy;
  final bool rebuildOnValueChanged;
  final bool rebuildOnValueChangedInternally;
  final bool rebuildOnAttributeChanged;
  final bool rebuildOnErrorChanged;
  final List<String> dontRebuildOnAttributes;
  final Map<String, dynamic> initialAttributes;

  const JustField({
    super.key,
    required this.name,
    required this.builder,
    this.initialValue,
    this.validators = const [],
    this.onChanged,
    this.onErrorChanged,
    this.onAttributeChanged,
    this.onRegistered,
    this.keepValueOnDestroy = true,
    this.rebuildOnValueChanged = true,
    this.rebuildOnValueChangedInternally = false,
    this.rebuildOnAttributeChanged = true,
    this.rebuildOnErrorChanged = true,
    this.dontRebuildOnAttributes = const [],
    this.initialAttributes = const {},
  });

  @override
  State<JustField<T>> createState() => _JustFieldState<T>();
}

class _JustFieldState<T> extends State<JustField<T>> {
  JustFieldController<T>? _fieldController;
  late final JustFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = context.justForm;

    _fieldController = _formController._register<T>(
      widget.name,
      initialValue: widget.initialValue,
      validators: widget.validators,
      keepValueOnDestroy: widget.keepValueOnDestroy,
      initialAttributes: widget.initialAttributes,
    );

    if (_fieldController != null) {
      widget.onRegistered?.call(_fieldController!.getState());
      if (widget.onChanged != null ||
          widget.onAttributeChanged != null ||
          widget.onErrorChanged != null) {
        _fieldController!.addListener(_onStateChange);
      }
    }
  }

  void _onStateChange(JustFieldState<T> from, JustFieldState<T> to) {
    if (widget.onChanged != null && from.value != to.value) {
      widget.onChanged?.call(to.value, to.internal);
    }

    if (widget.onErrorChanged != null && from.error != to.error) {
      widget.onErrorChanged?.call(to.error, to.internal);
    }

    if (widget.onAttributeChanged != null &&
        !mapEquals(from.attributes, to.attributes)) {
      widget.onAttributeChanged?.call(to.attributes, to.internal);
    }
  }

  @override
  void dispose() {
    if (widget.onChanged != null ||
        widget.onAttributeChanged != null ||
        widget.onErrorChanged != null) {
      _fieldController?.removeListener(_onStateChange);
    }

    _formController._unRegister(widget.name, hard: !widget.keepValueOnDestroy);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fieldController == null
        ? const SizedBox.shrink()
        : BlocBuilder<JustFieldData<T>, JustFieldState<T>>(
            bloc:
                context.read<JustFormController>().state[widget.name]
                    as JustFieldData<T>,
            buildWhen: (previous, current) {
              if (widget.rebuildOnAttributeChanged) {
                if (!mapEquals(
                  (Map.from(previous.attributes)..removeWhere((key, value) {
                    return widget.dontRebuildOnAttributes.contains(key);
                  })),
                  (Map.from(current.attributes)..removeWhere((key, value) {
                    return widget.dontRebuildOnAttributes.contains(key);
                  })),
                )) {
                  return true;
                }
              }

              if (widget.rebuildOnValueChanged &&
                  (previous.value != current.value ||
                      current.value is List ||
                      current.value is Iterable ||
                      current.value is Map ||
                      current.value is Set) &&
                  !current.internal) {
                return true;
              }

              if (widget.rebuildOnValueChangedInternally &&
                  (previous.value != current.value ||
                      current.value is List ||
                      current.value is Iterable ||
                      current.value is Map ||
                      current.value is Set) &&
                  current.internal) {
                return true;
              }

              if (widget.rebuildOnErrorChanged &&
                  previous.error != current.error) {
                return true;
              }
              return false;
            },
            builder: (context, state) {
              try {
                return widget.builder(context, _fieldController!);
              } catch (e) {
                throw ("${widget.name} : Field builder error", e);
              }
            },
          );
  }
}
