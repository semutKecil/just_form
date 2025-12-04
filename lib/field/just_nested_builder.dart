part of '../just_form_builder.dart';

class JustNestedBuilder extends StatefulWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  final String name;
  final List<JustValidator> validators;
  final WidgetBuilder builder;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  final Map<String, dynamic> initialValue;

  const JustNestedBuilder({
    super.key,
    this.initialValue = const {},
    this.validators = const [],
    required this.name,
    required this.builder,
  });

  @override
  State<JustNestedBuilder> createState() => _JustNestedBuilderState();
}

class _JustNestedBuilderState extends State<JustNestedBuilder> {
  JustFormController? _parentController;
  StreamSubscription? _sub;

  JustFieldController<Map<String, dynamic>>? _field;

  JustFormController? _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _parentController = context.justForm;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentController = context.justForm;
  }

  @override
  void dispose() {
    _parentController?._fieldInternal(widget.name)?._setSubFormController(null);
    _controller?.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JustField<Map<String, dynamic>>(
      name: widget.name,
      rebuildOnValueChangedInternally: false,
      rebuildOnErrorChanged: false,
      rebuildOnAttributeChanged: false,
      initialValue: widget.initialValue,
      validators: [
        (value) {
          var formController = _parentController
              ?._fieldInternal(widget.name)
              ?.getSubForm();
          if (_field?.getState().internal != true) {
            formController?.validate();
          }
          var error = formController?.getErrors();
          return error == null || error.isEmpty ? null : jsonEncode(error);
        },
      ],
      onRegistered: (state) {
        if (state.value != null) {
          _controller = JustFormController(
            initialValues: {...widget.initialValue, ...(state.value ?? {})},
            validators: [],
          );

          _parentController
              ?._fieldInternal(widget.name)
              ?._setSubFormController(_controller);
        }
      },
      builder: (context, state) {
        _field ??= state;
        return JustFormBuilder(
          controller: _controller,
          validators: widget.validators,
          onValuesChanged: (value) {
            state.setValue(value);
          },
          builder: (context) {
            return widget.builder(context);
          },
        );
      },
    );
  }
}
