part of 'ui/just_form_builder.dart';

/// Abstract base class defining the contract for field validators.
///
/// This interface extends [JustFieldAbstract] and adds validator support,
/// defining the expected validators for a form field.
abstract class JustFieldValidatorAbstract<T> extends JustFieldAbstract<T> {
  /// The list of validators for this field.
  ///
  /// Each validator is a [FormFieldValidator<T>] that will be executed
  /// to validate the field's value. Multiple validators can be chained together.
  List<FormFieldValidator<T>> get validators;
}

/// Abstract base class defining the core contract for form fields.
///
/// This interface specifies the essential properties that all form fields
/// must implement to participate in form management.
abstract class JustFieldAbstract<T> {
  /// The unique name/identifier for this field in the form.
  ///
  /// This name is used to register the field with the form controller,
  /// retrieve values, and access field state.
  String get name;

  /// The initial value for this field.
  ///
  /// If not provided, the field starts with a null value.
  /// This value is used during field registration and can be overridden
  /// by the form's initial values.
  T? get initialValue;

  /// Whether to preserve the field value when it's destroyed.
  ///
  /// If true, the field value remains in form state after the widget is disposed.
  /// If false, the value is removed from the form when the widget is destroyed.
  bool get keepValueOnDestroy;

  /// Initial attributes for this field.
  ///
  /// Custom metadata attributes that can be stored and tracked separately
  /// from the field's value. Useful for storing UI state, validation metadata, etc.
  Map<String, dynamic> get initialAttributes;

  /// Callback triggered when the field value changes.
  ///
  /// Called with the new value whenever the field's value is updated.
  ValueChanged<T>? get onChanged;
}

/// A flexible form field widget that provides integrated form management and state tracking.
///
/// [JustField] is a generic widget that wraps field builders (like text inputs, dropdowns, etc.)
/// with automatic registration, validation, and state management through the form's controller.
///
/// Each field instance:
/// - Automatically registers itself with the parent [JustFormBuilder]'s controller
/// - Tracks its own value, validation errors, and custom attributes
/// - Notifies listeners when its state changes
/// - Can be configured to trigger rebuilds on specific state changes
/// - Handles cleanup and optionally preserves values on destruction
///
/// ## Usage
///
/// Basic text field:
/// ```dart
/// JustField<String>(
///   name: 'email',
///   initialValue: '',
///   validators: [
///     RequiredValidator(),
///     EmailValidator(),
///   ],
///   builder: (context, controller) {
///     return TextField(
///       value: controller.value ?? '',
///       onChanged: (value) => controller.value = value,
///       decoration: InputDecoration(
///         hintText: 'Enter email',
///         errorText: controller.error,
///       ),
///     );
///   },
/// )
/// ```
///
/// With custom callbacks:
/// ```dart
/// JustField<String>(
///   name: 'password',
///   onChanged: (value, isInternal) {
///     print('Password changed: $value');
///   },
///   onErrorChanged: (error, isInternal) {
///     if (error != null) print('Validation error: $error');
///   },
///   builder: (context, controller) => MyPasswordField(controller),
/// )
/// ```
///
/// ## Generic Type Parameter
/// - `T` - The type of value this field manages (String, int, bool, DateTime, etc.)
///
/// ## Properties
class JustField<T> extends StatefulWidget {
  /// The builder function that constructs the field's UI.
  ///
  /// This function is called with:
  /// - [BuildContext] - The widget's build context
  /// - [JustFieldController<T>] - The controller for managing this field's state
  ///
  /// The builder is responsible for creating the actual form input widget (TextField, Checkbox, etc.)
  /// and binding the controller to it. The controller provides access to:
  /// - `value` - The current field value
  /// - `error` - Current validation error message
  /// - `attributes` - Custom field attributes
  /// - `setValue()` - To update the field value
  /// - `setError()` - To set a custom error
  /// - `setAttribute()` - To update attributes
  final Widget Function(BuildContext context, JustFieldController<T> state)
  builder;

  /// The unique identifier for this field within the form.
  ///
  /// This name is used to:
  /// - Register/unregister the field with the form controller
  /// - Access the field's value via `controller.values['fieldName']`
  /// - Track validation errors via `controller.errors['fieldName']`
  ///
  /// Must be unique within a single form instance.
  final String name;

  /// The initial value for this field.
  ///
  /// If provided, this value is used when the field is first registered.
  /// Can be overridden by [JustFormBuilder.initialValues].
  final T? initialValue;

  /// List of validators to apply to this field's value.
  ///
  /// Validators are executed in order and the first error is returned.
  /// Examples: [RequiredValidator], [EmailValidator], custom validators
  ///
  /// See [FormFieldValidator] for the validator interface.
  final List<FormFieldValidator<T>> validators;

  /// Callback invoked when this field is registered with the form.
  ///
  /// Called after the field is registered and provides access to the field's
  /// initial state. Useful for initialization logic specific to this field.
  ///
  /// Parameters:
  /// - [JustFieldState<T>] - The field's state at registration time
  final void Function(JustFieldState<T> state)? onRegistered;

  /// Callback invoked when this field's value changes.
  ///
  /// Parameters:
  /// - `value` - The new field value
  /// - `isInternal` - true if the change was triggered programmatically via the controller,
  ///   false if triggered by external UI changes
  ///
  /// This allows distinguishing between user input and programmatic updates.
  final void Function(T? value, bool isInternal)? onChanged;

  /// Callback invoked when this field's validation error changes.
  ///
  /// Parameters:
  /// - `error` - The error message string (null if valid)
  /// - `isInternal` - true if the change was triggered programmatically,
  ///   false if by external/user actions
  final void Function(String? error, bool isInternal)? onErrorChanged;

  /// Callback invoked when this field's attributes change.
  ///
  /// Attributes are custom metadata stored alongside the field value.
  /// This callback receives the entire updated attributes map.
  ///
  /// Parameters:
  /// - `attributes` - The updated attributes map
  /// - `isInternal` - true if the change was triggered programmatically
  final void Function(Map<String, dynamic> attributes, bool isInternal)?
  onAttributeChanged;

  /// Whether to preserve this field's value when the widget is destroyed.
  ///
  /// If true (default):
  /// - The field value remains in the form's state after the widget is removed
  /// - Useful for preserving field data across navigation or conditional rendering
  ///
  /// If false:
  /// - The field value is removed from the form when the widget is destroyed
  /// - Useful for temporary fields that should not persist
  final bool keepValueOnDestroy;

  /// Whether to rebuild this field when its value changes externally.
  ///
  /// If true (default):
  /// - The field rebuilds whenever its value is updated from outside
  /// - Useful for fields that display data loaded from an external source
  ///
  /// If false:
  /// - External value changes don't trigger rebuilds
  /// - The builder can still access the latest value via the controller
  final bool rebuildOnValueChanged;

  /// Whether to rebuild this field when its value changes internally.
  ///
  /// Internal changes are updates triggered programmatically via the controller
  /// (e.g., `controller.value = newValue`).
  ///
  /// If true:
  /// - The field rebuilds on internal value changes
  /// - Default is false to optimize performance
  final bool rebuildOnValueChangedInternally;

  /// Whether to rebuild this field when its attributes change.
  ///
  /// Attributes are custom metadata. If true, any attribute change triggers a rebuild.
  /// Set to false if attributes are accessed but should not cause rebuilds.
  ///
  /// Default is true.
  final bool rebuildOnAttributeChanged;

  /// Whether to rebuild this field when its validation error changes.
  ///
  /// If true (default):
  /// - The field rebuilds whenever validation errors change
  /// - Useful for displaying error messages
  ///
  /// If false:
  /// - Error changes don't trigger rebuilds
  /// - The builder can still access errors via the controller
  final bool rebuildOnErrorChanged;

  /// List of attribute keys that should NOT trigger rebuilds.
  ///
  /// When [rebuildOnAttributeChanged] is true, changes to any attribute will
  /// normally trigger a rebuild. This list specifies attributes to exclude.
  ///
  /// Useful for tracking non-UI-relevant metadata without causing rebuilds.
  ///
  /// Example:
  /// ```dart
  /// dontRebuildOnAttributes: ['lastModified', 'internalFlag']
  /// ```
  final List<String> dontRebuildOnAttributes;

  /// Initial custom attributes for this field.
  ///
  /// A map of arbitrary key-value pairs for storing field metadata.
  /// These attributes can be updated via `controller.setAttribute()` and
  /// retrieved via `controller.attributes`.
  ///
  /// Useful for tracking:
  /// - Custom UI state
  /// - Validation metadata
  /// - Field-specific configuration
  final Map<String, dynamic> initialAttributes;

  /// Creates a [JustField] widget.
  ///
  /// The [name] and [builder] parameters are required.
  /// All other parameters have sensible defaults optimized for common use cases.
  ///
  /// Defaults:
  /// - `keepValueOnDestroy`: true - preserves field value on destruction
  /// - `rebuildOnValueChanged`: true - rebuilds on external value changes
  /// - `rebuildOnValueChangedInternally`: false - doesn't rebuild on programmatic changes
  /// - `rebuildOnAttributeChanged`: true - rebuilds when attributes change
  /// - `rebuildOnErrorChanged`: true - rebuilds when validation errors change
  /// - `validators`: empty list - no validators by default
  /// - `initialAttributes`: empty map - no initial attributes
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

/// Internal state class for managing [JustField] lifecycle and state.
///
/// Handles:
/// - Field registration with the form controller
/// - Listener attachment for state change notifications
/// - Rebuild condition evaluation
/// - Resource cleanup
class _JustFieldState<T> extends State<JustField<T>> {
  /// The controller for this specific field.
  ///
  /// Provides access to the field's value, errors, attributes, and methods
  /// to update them. May be null if registration fails.
  JustFieldController<T>? _fieldController;

  /// Reference to the parent form's controller.
  ///
  /// Used for registering/unregistering this field and accessing form-level state.
  late final JustFormController _formController;

  /// Initializes the field state and registers the field with the form.
  ///
  /// - Gets the form controller from the widget context
  /// - Registers this field with the form using [_formController._register]
  /// - Calls the [JustField.onRegistered] callback if provided
  /// - Attaches listeners for value, error, and attribute changes if callbacks are provided
  ///
  /// If registration fails, [_fieldController] remains null and the field renders empty.
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

  /// Handles state changes in the field and invokes appropriate callbacks.
  ///
  /// Called whenever the field's state changes. This method compares the previous
  /// and current states and invokes the corresponding callbacks:
  /// - [JustField.onChanged] if the value changed
  /// - [JustField.onErrorChanged] if the error changed
  /// - [JustField.onAttributeChanged] if attributes changed
  ///
  /// Parameters:
  /// - `from` - The previous field state
  /// - `to` - The new field state (includes the `internal` flag for change origin)
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

  /// Cleans up resources when the field is destroyed.
  ///
  /// - Removes the state change listener
  /// - Unregisters the field from the form controller
  /// - Optionally removes the field's value based on [JustField.keepValueOnDestroy]
  ///
  /// If [keepValueOnDestroy] is true, the value is preserved (soft unregister).
  /// If false, the value is removed (hard unregister).
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

  /// Builds the field widget with BLoC-based state management.
  ///
  /// Returns [SizedBox.shrink] if the field failed to register with the form.
  ///
  /// Otherwise, wraps the builder in a [BlocBuilder] that:
  /// - Listens to the field's [JustFieldData] bloc for state changes
  /// - Determines whether to rebuild based on [buildWhen] conditions
  /// - Passes the field controller to the builder function
  /// - Catches any builder exceptions and re-throws them with field name context
  ///
  /// The [buildWhen] function evaluates rebuild conditions:
  /// - [JustField.rebuildOnAttributeChanged] - changes to non-excluded attributes
  /// - [JustField.rebuildOnValueChanged] - external value changes
  /// - [JustField.rebuildOnValueChangedInternally] - internal value changes
  /// - [JustField.rebuildOnErrorChanged] - validation error changes
  ///
  /// Rebuild optimization excludes:
  /// - Attributes in [JustField.dontRebuildOnAttributes]
  /// - Internal vs. external changes based on field configuration
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
