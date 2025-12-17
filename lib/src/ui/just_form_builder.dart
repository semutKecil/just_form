import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/src/debouncer.dart';
import 'package:just_form/src/just_field_state.dart';
import 'package:just_form/src/just_validator.dart';
part '../just_form_controller.dart';
part '../just_field.dart';
part '../just_field_controller.dart';
part 'field/just_nested_builder.dart';
part '../just_field_data.dart';

/// A stateful widget that provides form building capabilities with automatic field management and validation.
///
/// [JustFormBuilder] is a comprehensive form management widget that handles:
/// - Form field registration and lifecycle management
/// - Automatic validation with support for custom validators
/// - Real-time value and error tracking
/// - Integration with BLoC pattern for state management
///
/// The widget wraps its builder in a [BlocProvider] to expose a [JustFormController]
/// that can be accessed by child widgets via `context.read<JustFormController>()`.
///
/// ## Usage
///
/// Basic usage with a builder:
/// ```dart
/// JustFormBuilder(
///   builder: (context) {
///     return Column(
///       children: [
///         JustTextField(name: 'email'),
///         ElevatedButton(
///           onPressed: () {
///             final controller = context.read<JustFormController>();
///             print(controller.values);
///           },
///           child: Text('Submit'),
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// With a custom controller:
/// ```dart
/// final controller = JustFormController(
///   initialValues: {'name': 'John'},
/// );
///
/// JustFormBuilder(
///   controller: controller,
///   builder: (context) => YourForm(),
/// )
/// ```
///
/// ## Properties
class JustFormBuilder extends StatefulWidget {
  /// The builder function that constructs the form UI.
  ///
  /// This function is called with a [BuildContext] that has access to the
  /// [JustFormController] via [BlocProvider]. Child widgets can access the
  /// controller using `context.read<JustFormController>()` or watch changes
  /// using `context.watch<JustFormController>()`.
  final WidgetBuilder builder;

  /// Optional controller to manage form state externally.
  ///
  /// If not provided, [JustFormBuilder] will create its own controller internally.
  /// This allows external management of the form's validation state, values, and errors.
  ///
  /// When provided, the caller is responsible for disposing the controller
  /// when it's no longer needed.
  final JustFormController? controller;

  /// Initial values for form fields.
  ///
  /// A map where keys are field names and values are the initial values for those fields.
  /// These values will be used when the form is initialized if no controller is provided,
  /// or merged with the controller's initial values if one is provided.
  ///
  /// Example:
  /// ```dart
  /// initialValues: {
  ///   'email': 'user@example.com',
  ///   'age': 25,
  /// }
  /// ```
  final Map<String, dynamic>? initialValues;

  /// List of global form validators.
  ///
  /// These validators are applied to the entire form and can validate multiple fields
  /// or cross-field dependencies. They are passed to the [JustFormController] and
  /// executed during form validation.
  ///
  /// See [JustValidator] for creating custom validators.
  final List<JustValidator> validators;

  /// Callback fired whenever a new field is registered with the form.
  ///
  /// This callback receives a map of all current form values at the time
  /// the field is registered. Useful for reacting to dynamic field additions.
  ///
  /// Example:
  /// ```dart
  /// onFieldRegistered: (values) {
  ///   print('New field registered. Current values: $values');
  /// }
  /// ```
  final ValueChanged<Map<String, dynamic>>? onFieldRegistered;

  /// Callback fired whenever any field value changes.
  ///
  /// This callback is triggered after any field's value is updated and receives
  /// a map of all current form values. Use this to react to form changes or
  /// update UI based on field values.
  ///
  /// Example:
  /// ```dart
  /// onValuesChanged: (values) {
  ///   setState(() {
  ///     formIsDirty = true;
  ///   });
  /// }
  /// ```
  final ValueChanged<Map<String, dynamic>>? onValuesChanged;

  /// Callback fired whenever validation errors change.
  ///
  /// This callback receives a map where keys are field names and values are error messages
  /// (or null if the field is valid). Triggered after any validation operation.
  ///
  /// Example:
  /// ```dart
  /// onErrorsChanged: (errors) {
  ///   errors.forEach((fieldName, errorMessage) {
  ///     if (errorMessage != null) {
  ///       print('$fieldName has error: $errorMessage');
  ///     }
  ///   });
  /// }
  /// ```
  final ValueChanged<Map<String, String?>>? onErrorsChanged;

  /// Creates a [JustFormBuilder] widget.
  ///
  /// The [builder] and [key] parameters are required.
  /// All other parameters are optional and have sensible defaults.
  ///
  /// When [controller] is null, the widget will create and manage its own controller,
  /// disposing it automatically when the widget is disposed.
  const JustFormBuilder({
    super.key,
    required this.builder,
    this.controller,
    this.initialValues,
    this.onValuesChanged,
    this.onErrorsChanged,
    this.onFieldRegistered,
    this.validators = const [],
  });

  @override
  State<JustFormBuilder> createState() => _JustFormBuilderState();
}

class _JustFormBuilderState extends State<JustFormBuilder> {
  /// The form controller instance.
  ///
  /// This is either the external controller provided via [JustFormBuilder.controller]
  /// or a newly created internal controller if none was provided.
  late JustFormController _controller;

  /// Flag to track if this state created and should dispose its own controller.
  bool _ownController = false;

  /// Initializes the form state and sets up the controller.
  ///
  /// - Creates an internal controller if none was provided
  /// - Attaches value change listeners if [JustFormBuilder.onValuesChanged] is provided
  /// - Attaches error change listeners if [JustFormBuilder.onErrorsChanged] is provided
  ///
  /// The controller is initialized with:
  /// - [JustFormBuilder.initialValues] (defaults to empty map)
  /// - [JustFormBuilder.validators] (defaults to empty list)
  /// - [JustFormBuilder.onFieldRegistered] callback
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = true;
      _controller = JustFormController(
        initialValues: widget.initialValues ?? {},
        validators: widget.validators,
        onFieldRegistered: widget.onFieldRegistered,
      );
    } else {
      _controller = widget.controller!;
    }

    if (widget.onValuesChanged != null) {
      _controller.addValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.addErrorsChangedListener(widget.onErrorsChanged!);
    }
  }

  /// Cleans up resources and listeners when the widget is disposed.
  ///
  /// - Removes attached value and error change listeners
  /// - Disposes the internal controller if one was created
  /// - Does not dispose external controllers (caller's responsibility)
  @override
  void dispose() {
    if (widget.onValuesChanged != null) {
      _controller.removeValuesChangedListener(widget.onValuesChanged!);
    }

    if (widget.onErrorsChanged != null) {
      _controller.removeErrorsChangedListener(widget.onErrorsChanged!);
    }

    if (_ownController) {
      _controller.dispose();
    }

    super.dispose();
  }

  /// Called when a dependency of this State object changes.
  ///
  /// Currently unused but available for future extensions or dependency tracking.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Builds the widget tree with form management capabilities.
  ///
  /// Wraps the user's builder in a [BlocProvider] to expose the [JustFormController]
  /// to all descendant widgets. This enables any child widget to:
  /// - Access form state: `context.read<JustFormController>()`
  /// - Listen to form changes: `context.watch<JustFormController>()`
  /// - Register fields automatically
  /// - Trigger validation
  ///
  /// Returns a [BlocProvider] containing the form's controller and the user's builder.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<JustFormController>(
      create: (context) {
        return _controller;
      },
      child: Builder(
        builder: (context) {
          return widget.builder(context);
        },
      ),
    );
  }
}
