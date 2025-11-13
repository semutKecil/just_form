import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_form/debouncer.dart';
import 'package:just_form/just_validator.dart';
part 'just_form_controller.dart';
part 'just_field_state.dart';
part 'just_field.dart';
part 'just_field_controller.dart';
part 'just_field_updater.dart';

/// A widget that provides form management and state to its child widgets.
///
/// [JustForm] is the root widget for using the just_form plugin. It manages
/// the overall form state, field registration, validation, and provides access
/// to a [JustFormController] that can be used to programmatically interact with
/// the form.
///
/// The form can either create its own [JustFormController] internally or use
/// a provided one. If no controller is provided, one will be created automatically
/// and disposed when the widget is removed.
///
/// Example:
/// ```dart
/// JustForm(
///   initialValues: {'email': '', 'password': ''},
///   child: Column(
///     children: [
///       JustField<String>(
///         name: 'email',
///         builder: (context, controller) {
///           return TextField(
///             onChanged: (value) => controller.updater.withValue(value).softUpdate(),
///           );
///         },
///       ),
///       ElevatedButton(
///         onPressed: () async {
///           final isValid = await context.read<JustFormController>().validate();
///           if (isValid) {
///             // Submit form
///           }
///         },
///         child: Text('Submit'),
///       ),
///     ],
///   ),
/// )
/// ```
class JustForm extends StatefulWidget {
  /// The child widget tree that contains form fields.
  ///
  /// This widget and all its descendants have access to the form's controller
  /// via [context.read<JustFormController>()].
  final Widget child;

  /// An optional [JustFormController] to manage the form's state.
  ///
  /// If not provided, a new controller will be created automatically.
  /// The automatically created controller will be disposed when the form is removed.
  final JustFormController? controller;

  /// Initial values for the form fields.
  ///
  /// A map where keys are field names and values are the initial values for those fields.
  /// These values are used when creating the form controller if no controller is provided.
  /// Example: `{'email': '', 'name': 'John'}`
  final Map<String, dynamic>? initialValues;

  /// Creates a [JustForm] widget.
  ///
  /// The [child] parameter is required. The [controller] and [initialValues]
  /// parameters are optional.
  const JustForm({
    super.key,
    required this.child,
    this.controller,
    this.initialValues,
  });

  /// Creates the state for this widget.
  @override
  State<JustForm> createState() => _JustFormState();
}

/// The state implementation for [JustForm].
///
/// This class manages the form's controller lifecycle:
/// - Creates a new [JustFormController] if one isn't provided
/// - Provides the controller to all child widgets via [BlocProvider]
/// - Disposes the controller when the form is removed (if it was created internally)
class _JustFormState extends State<JustForm> {
  /// The form controller that manages the form's state and fields.
  late JustFormController _controller;

  /// Whether this widget created the controller (and thus owns disposal responsibility).
  bool _ownController = false;

  /// Initializes the form controller.
  ///
  /// If no controller was provided via the [JustForm] widget, this method creates
  /// a new [JustFormController] and sets [_ownController] to true so it will be
  /// disposed when the form is removed.
  ///
  /// If a controller was provided, it is used directly without creating a new one.
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = true;
      _controller = JustFormController(initialValues: widget.initialValues);
    } else {
      _controller = widget.controller!;
    }
  }

  /// Cleans up resources when the form is removed.
  ///
  /// If this widget created its own controller (indicated by [_ownController] being true),
  /// the controller is disposed to free up resources. If a controller was provided externally,
  /// it is not disposed here as the external code is responsible for its lifecycle.
  @override
  void dispose() {
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  /// Builds the form widget.
  ///
  /// This method wraps the child widget with a [BlocProvider] that makes
  /// the [JustFormController] available to all descendants via
  /// `context.read<JustFormController>()` or `context.watch<JustFormController>()`.
  ///
  /// The controller manages the state of all form fields and provides methods
  /// for validation, getting values, and programmatic field updates.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<JustFormController>(
      create: (context) {
        return _controller;
      },
      child: widget.child,
    );
  }
}
