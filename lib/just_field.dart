part of 'just_form.dart';

/// A generic form field widget that represents a single field in a [JustForm].
///
/// [JustField] is a stateless widget that wraps a form field and provides
/// access to a [JustFieldController] through a builder function. It manages
/// the field's state, validation, and change notifications automatically.
///
/// The field must have a unique [name] within the form, and a [builder]
/// function that constructs the actual form field widget (e.g., TextField, Checkbox).
///
/// Example:
/// ```dart
/// JustField<String>(
///   name: 'email',
///   initialValue: '',
///   validators: [
///     JustValidator<String>(
///       validate: (value, formValues) => value?.isEmpty ?? true ? 'Email is required' : null,
///     ),
///   ],
///   builder: (context, controller) {
///     return TextField(
///       decoration: InputDecoration(
///         labelText: 'Email',
///         errorText: controller.error,
///       ),
///       onChanged: (value) => controller.updater.withValue(value).softUpdate(),
///     );
///   },
/// )
/// ```
class JustField<T> extends StatelessWidget {
  /// The unique name identifier for this field within the form.
  ///
  /// This name is used to access the field's controller and state.
  /// Must be unique among all fields in the form.
  final String name;

  /// The initial value of the field.
  ///
  /// If null, the field starts with no value. Used for setting the field's
  /// initial state and for dirty checking.
  final T? initialValue;

  /// A builder function that constructs the form field widget.
  ///
  /// The builder receives the current [BuildContext] and a [JustFieldController]
  /// that can be used to get/set the field's value, validate it, and listen to changes.
  /// The builder is called whenever the field needs to rebuild based on [buildWhen] logic.
  final Widget Function(BuildContext context, JustFieldController<T> state)
  builder;

  /// Whether to rebuild the field when an error changes.
  ///
  /// Defaults to true. Set to false to prevent rebuilds on validation errors.
  /// You can still display errors manually by accessing [controller.error].
  final bool notifyError;

  /// Whether to rebuild the field when internal updates occur.
  ///
  /// Defaults to false. Set to true to rebuild the field for internal value updates
  /// (e.g., updates triggered by the form controller itself rather than user input).
  final bool notifyInternalUpdate;

  /// A list of validators to validate this field's value.
  ///
  /// Validators are called in order during form validation. The first validator
  /// that returns an error message stops the validation process for this field.
  /// Defaults to an empty list (no validation).
  final List<JustValidator<T>> validators;

  /// An optional custom equality function for comparing field values.
  ///
  /// If provided, this function is used instead of the default equality check
  /// to determine if the field's value has changed. This is useful for complex types
  /// (e.g., Lists, custom objects) where the default == operator doesn't work as expected.
  final bool Function(T a, T b)? isEqual;

  /// An optional callback that is called when the field's value changes.
  ///
  /// The callback receives the new value and a boolean indicating whether the
  /// change is an internal update (true) or an external update from user input (false).
  /// This is useful for triggering side effects like auto-save or search.
  final void Function(T? value, bool isInternalUpdate)? onChanged;

  /// An optional [FocusNode] to manage focus for this field.
  ///
  /// This is useful for controlling focus programmatically or detecting when
  /// the field gains or loses focus. The focus node is managed by the form controller.
  final FocusNode? focusNode;

  /// Creates a new [JustField] widget.
  ///
  /// All parameters are required except [initialValue], [validators], [isEqual],
  /// [onChanged], and [focusNode].
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

  /// Builds the field widget.
  ///
  /// This method retrieves the [JustFormController] from the context and passes
  /// it to a [_JustFieldInner] widget that handles the field's state management
  /// and lifecycle.
  @override
  Widget build(BuildContext context) {
    return _JustFieldInner<T>(
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

/// Internal [StatefulWidget] that manages the lifecycle and state of a form field.
///
/// [_JustFieldInner] wraps a form field and connects it to a [JustFormController].
/// It creates a [JustFieldController] for this specific field and handles:
/// - Initialization of the field state
/// - Subscribing to field changes
/// - Building the field using the provided builder
/// - Disposing of resources when the field is removed
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

  /// Creates the state for this widget.
  @override
  State<_JustFieldInner<T>> createState() => _JustFieldInnerState<T>();
}

/// The state implementation for [_JustFieldInner].
///
/// This class manages the field's lifecycle, including:
/// - Setting up the field controller with validators and initial value
/// - Listening to changes from the form controller
/// - Calling the [onChanged] callback when the field's value changes
/// - Cleaning up subscriptions when the field is removed
class _JustFieldInnerState<T> extends State<_JustFieldInner<T>> {
  /// A subscription to the form controller's field changes stream.
  StreamSubscription? _sub;

  /// Initializes the field controller and sets up event listeners.
  ///
  /// This method:
  /// 1. Subscribes to the form controller's stream to listen for field changes
  /// 2. Calls [onChanged] callback when the field value changes
  /// 3. Registers the field with the form controller with validators and initial value
  /// 4. Sets the equality function for value comparison
  /// 5. Associates the focus node with the field controller
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

  /// Cleans up resources when the field is removed.
  ///
  /// This method:
  /// 1. Cancels the subscription to the form controller's stream
  /// 2. Unregisters the field from the form controller
  @override
  void dispose() {
    _sub?.cancel();
    widget.controller._unReg(widget.name);
    super.dispose();
  }

  /// Builds the field widget using the provided builder function.
  ///
  /// This method uses a [BlocBuilder] to intelligently rebuild the field based on
  /// which properties changed (value, error, or internal updates). The [buildWhen]
  /// function determines whether a rebuild is necessary based on:
  /// - [JustFieldStateMode.update]: External value changes
  /// - [JustFieldStateMode.updateInternal]: Internal value updates (if [notifyInternalUpdate] is true)
  /// - [JustFieldStateMode.error]: Error state changes (if [notifyError] is true)
  /// - [JustFieldStateMode.validate]: Validation state changes
  ///
  /// The field builder is called with the current [JustFieldController] so the UI
  /// can access the field's value, error, and other state.
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

          if (field == null) throw ();
          return widget.builder(
            context,
            widget.controller._field<T>(widget.name, internal: true),
          );
        } catch (e) {
          throw ("${widget.name} : Field builder error", e);
        }
      },
    );
  }
}
