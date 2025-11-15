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

/// A widget that provides form management and state using the builder pattern.
///
/// [JustFormBuilder] is the root widget for using the just_form plugin with a builder
/// pattern. It manages the overall form state, field registration, validation, and provides
/// access to a [JustFormController] that can be used to programmatically interact with the form.
///
/// Unlike a traditional wrapper widget, [JustFormBuilder] uses the builder pattern to provide
/// the form controller directly to the builder function. This allows cleaner widget trees and
/// better control over what widgets have access to the form.
///
/// The form can either create its own [JustFormController] internally or use a provided one.
/// If no controller is provided, one will be created automatically and disposed when the widget
/// is removed.
///
/// Example:
/// ```dart
/// JustFormBuilder(
///   initialValues: {'email': '', 'password': ''},
///   builder: (context) {
///     return Column(
///       children: [
///         JustField<String>(
///           name: 'email',
///           builder: (context, controller) {
///             return TextField(
///               onChanged: (value) => controller.updater.withValue(value).softUpdate(),
///             );
///           },
///         ),
///         ElevatedButton(
///           onPressed: () async {
///             final isValid = await context.read<JustFormController>().validate();
///             if (isValid) {
///               // Submit form
///             }
///           },
///           child: Text('Submit'),
///         ),
///       ],
///     );
///   },
/// )
/// ```
class JustFormBuilder extends StatefulWidget {
  /// A builder function that constructs the form's widget tree.
  ///
  /// The builder receives the [BuildContext] and has access to the form's controller
  /// via [context.read<JustFormController>()] or the [justForm] extension.
  /// This widget and all its descendants have access to the form's controller.
  final WidgetBuilder builder;

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

  /// Called when the form's state changes.
  ///
  final ValueChanged<Map<String, dynamic>>? onChanged;

  /// Creates a [JustFormBuilder] widget.
  ///
  /// The [builder] parameter is required. The [controller] and [initialValues]
  /// parameters are optional.
  ///
  /// The builder function will be called with a context that has access to the
  /// [JustFormController] via [context.read<JustFormController>()] or the
  /// [justForm] extension: `context.justForm`.
  const JustFormBuilder({
    super.key,
    required this.builder,
    this.controller,
    this.initialValues,
    this.onChanged,
  });

  /// Creates the state for this widget.
  @override
  State<JustFormBuilder> createState() => _JustFormBuilderState();
}

/// The state implementation for [JustFormBuilder].
///
/// This class manages the form's controller lifecycle:
/// - Creates a new [JustFormController] if one isn't provided
/// - Provides the controller to all child widgets via [BlocProvider]
/// - Disposes the controller when the form is removed (if it was created internally)
class _JustFormBuilderState extends State<JustFormBuilder> {
  /// The form controller that manages the form's state and fields.
  late JustFormController _controller;

  /// Whether this widget created the controller (and thus owns disposal responsibility).
  bool _ownController = false;
  StreamSubscription? _subscription;

  /// Initializes the form controller.
  ///
  /// If no controller was provided via the [JustFormBuilder] widget, this method creates
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

    if (widget.onChanged != null) {
      _subscription = _controller.stream.listen((event) {
        if (event.values.any((element) {
          return element.mode.contains(JustFieldStateMode.update) ||
              element.mode.contains(JustFieldStateMode.updateInternal);
        })) {
          widget.onChanged?.call(
            event.map((key, value) => MapEntry(key, value.value)),
          );
        }
      });
    }
  }

  /// Cleans up resources when the form is removed.
  ///
  /// If this widget created its own controller (indicated by [_ownController] being true),
  /// the controller is disposed to free up resources. If a controller was provided externally,
  /// it is not disposed here as the external code is responsible for its lifecycle.
  @override
  void dispose() {
    _subscription?.cancel();
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  /// Builds the form widget using the builder pattern.
  ///
  /// This method wraps the builder result with a [BlocProvider] that makes
  /// the [JustFormController] available to all descendants via
  /// `context.read<JustFormController>()` or the convenient extension `context.justForm`.
  ///
  /// The controller manages the state of all form fields and provides methods
  /// for validation, getting values, and programmatic field updates.
  ///
  /// The builder function is called within the BlocProvider context, ensuring
  /// the controller is available throughout the widget tree.
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

extension JustFormContextExtension on BuildContext {
  JustFormController get justForm => read<JustFormController>();
}
