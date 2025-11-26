import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:just_form/just_form_builder.dart';

class JustNestedBuilder extends StatefulWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  final String name;

  final WidgetBuilder builder;

  const JustNestedBuilder({
    super.key,
    required this.name,
    required this.builder,
  });

  @override
  State<JustNestedBuilder> createState() => _JustNestedBuilderState();
}

class _JustNestedBuilderState extends State<JustNestedBuilder> {
  JustFormController? _controller;

  @override
  Widget build(BuildContext context) {
    return JustField<Map<String, dynamic>>(
      name: widget.name,
      notifyInternalUpdate: false,
      notifyError: false,
      validators: [
        (value) {
          if (context.justForm
                  .field(widget.name)
                  ?.state
                  .mode
                  .contains(JustFieldStateMode.validateExternal) ==
              true) {
            _controller?.validate();
          }

          var error = _controller?.errors;
          if (error == null || error.isEmpty) {
            return null;
          }
          return jsonEncode(error);
        },
      ],

      onInitialized: () {
        _controller = JustFormController(
          initialValues: context.justForm.field(widget.name)?.state.value ?? {},
        );
      },
      builder: (context, state) {
        return JustFormBuilder(
          controller: _controller,
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
