import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:just_form/just_form_builder.dart';
import 'package:just_form/just_validator.dart';

class JustNestedBuilder extends StatefulWidget {
  /// The name of the field. This is used to identify the field in the
  /// [JustFormController].
  ///
  /// This is required to validate the form.
  ///
  /// The name of the field should be a single word (e.g. "name", "email",
  /// "password").
  final String name;

  /// The initial value of the field. This value is ignored when the initial value
  /// is already set on the [JustFormController] or [JustForm].
  final Map<String, dynamic>? initialValue;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox tile with the
  /// new value.
  ///
  /// If null, the checkbox will be displayed as disabled.
  ///
  /// {@tool snippet}
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// CheckboxListTile(
  ///   value: _throwShotAway,
  ///   onChanged: (bool? newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue;
  ///     });
  ///   },
  ///   title: const Text('Throw away your shot'),
  /// )
  /// ```
  /// {@end-tool}
  final ValueChanged<Map<String, dynamic>?>? onChanged;

  /// A builder function that constructs the form's widget tree.
  ///
  /// The builder receives the [BuildContext] and has access to the form's controller
  /// via [context.read<JustFormController>()] or the [justForm] extension.
  /// This widget and all its descendants have access to the form's controller.
  final WidgetBuilder builder;

  /// Whether to rebuild the field when an error changes.
  ///
  /// Defaults to true. Set to false to prevent rebuilds on validation errors.
  /// You can still display errors manually by accessing [controller.error].
  final bool notifyError;

  const JustNestedBuilder({
    super.key,
    required this.name,
    this.initialValue,
    this.onChanged,
    required this.builder,
    this.notifyError = false,
  });

  @override
  State<JustNestedBuilder> createState() => _JustNestedBuilderState();
}

class _JustNestedBuilderState extends State<JustNestedBuilder> {
  late JustFormController _controller;
  late StreamSubscription _subscription;

  @override
  void initState() {
    _controller = JustFormController(
      initialValues: context.justForm.field(widget.name).initialValue ?? {},
    );
    _subscription = _controller.stream.listen((event) {
      if (event.values.any(
        (element) => element.mode.contains(JustFieldStateMode.error),
      )) {
        if (mounted) {
          var error = _controller.errors;
          if (error.isEmpty) {
            if (context.justForm.field(widget.name).error != null) {
              context.justForm.field(widget.name).setError(null);
            }
          } else {
            if (context.justForm.field(widget.name).error == null) {
              context.justForm.field(widget.name).setError(jsonEncode(error));
            }
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JustField<Map<String, dynamic>>(
      name: widget.name,
      notifyInternalUpdate: false,
      notifyError: false,
      validators: [
        JustValidator(
          validator: (value, formValues) {
            var mode = context.justForm.field(widget.name).state?.mode;
            if (!(mode?.contains(JustFieldStateMode.error) == true ||
                mode?.contains(JustFieldStateMode.updateInternal) == true)) {
              // print(
              //   "${widget.name} ${context.justForm.field(widget.name).state?.mode}",
              // );
              _controller.validate();
            }
            return null;
          },
        ),
      ],
      onChanged: (value, isInternalUpdate) {
        // on update form parent form here
        if (!isInternalUpdate) {
          // should be updated as external parent
          // print("set parent value $value");
          _controller.setValues(value ?? {});
        }
      },
      builder: (context, state) {
        return JustFormBuilder(
          controller: _controller,
          builder: (context) => widget.builder(context),
          onChanged: (value) {
            // on sub field change will be trigered here
            // print(value);
            state.setValue(value);
            // print("justform ${context.justForm.values}");
          },
        );
      },
    );
  }
}
