part of 'just_form_builder.dart';

/// An enumeration of the different state modes that a field can be in.
///
/// These modes are used to determine what kind of update occurred to a field
/// and help optimize rebuilds by only updating relevant widgets.
enum JustFieldStateMode {
  /// The field is in its default state with no active updates.
  none,

  /// The field's value was updated externally (e.g., by user input).
  update,

  /// The field's value was updated internally (e.g., by the form controller).
  updateInternal,

  /// The field has a validation error.
  error,

  /// A field attribute (other than value or error) was changed.
  attribute,
}

/// Represents the immutable state of a form field at a point in time.
///
/// [JustFieldState] encapsulates all the information about a single form field,
/// including its value, validation state, error messages, and lifecycle state.
/// It also handles value comparison using a custom equality function if provided.
///
/// This class is used internally by the form controller to track field state
/// changes and determine when widgets need to rebuild.
class JustFieldState<T> {
  /// The unique name identifier of this field within the form.
  final String name;

  /// The current value of the field.
  final T? value;

  /// The initial value of the field (used for dirty checking).
  final T? initialValue;

  /// The current validation error message, or null if no error.
  final String? error;

  /// An optional custom equality function for comparing field values.
  ///
  /// If provided, this is used instead of the default == operator to determine
  /// if the field's value has changed. Useful for complex types like Lists.
  final bool Function(T a, T b)? isEqual;

  /// A list of validators that this field should use for validation.
  final List<JustValidator<T>> validators;

  /// A map of custom attributes stored on this field.
  ///
  /// This can be used to attach arbitrary metadata to a field that doesn't fit
  /// into the standard field properties.
  final Map<String, dynamic> attributes;

  /// A list of state mode flags indicating what type of update occurred.
  ///
  /// Multiple modes can be present simultaneously if multiple updates occurred
  /// at the same time. For example, both a value change and an error could be set.
  final List<JustFieldStateMode> mode;

  /// Whether the field has been interacted with by the user.
  ///
  /// Used to determine when to show validation errors (typically only after
  /// the field has been touched).
  final bool touched;

  /// An optional [FocusNode] associated with this field.
  ///
  /// Allows programmatic control and monitoring of focus state.
  final FocusNode? focusNode;

  final bool hasField;

  /// Creates a new [JustFieldState] instance.
  JustFieldState({
    required this.name,
    required this.mode,
    this.validators = const [],
    this.value,
    this.initialValue,
    this.error,
    this.isEqual,
    this.attributes = const {},
    this.touched = false,
    this.focusNode,
    required this.hasField,
  }) {
    if (mode.isEmpty) throw ("Field state must have at least one mode");
  }

  /// Whether the field's current value differs from its initial value.
  ///
  /// Returns true if the field has been modified by the user or programmatically.
  /// This is useful for detecting unsaved changes.
  bool get isDirty => !valueEqualWith(initialValue);

  /// Internal helper method for comparing two values using the custom equality function.
  ///
  /// If [isEqual] is provided, it's used for comparison. Otherwise, the default
  /// == operator is used. Handles null values correctly in both cases.
  bool _valueEqual(T? a, T? b) {
    if (isEqual == null) return a == b;
    return a != null && b != null ? isEqual!(a as T, b as T) : a == b;
  }

  /// Checks if the field's current value equals the provided comparator value.
  ///
  /// Uses the custom [isEqual] function if available, otherwise uses the == operator.
  /// This is used throughout the field state management to determine if rebuilds are needed.
  bool valueEqualWith(T? comparator) => _valueEqual(value, comparator);

  /// Creates a new [JustFieldState] with updated values.
  ///
  /// This is an internal helper method that creates a copy of the field state
  /// with new values while preserving immutable properties like [name], [initialValue],
  /// [validators], and [isEqual].
  ///
  /// All parameters are required to ensure every field state property is explicitly set.
  JustFieldState<T> _updateField({
    required List<JustFieldStateMode> mode,
    required T? value,
    required String? error,
    required Map<String, dynamic> attributes,
    required bool touched,
    required FocusNode? focusNode,
    required bool hasFiled,
  }) {
    return JustFieldState<T>(
      name: name,
      initialValue: initialValue,
      validators: validators,
      isEqual: isEqual,
      mode: mode,
      value: value,
      error: error,
      attributes: attributes,
      touched: touched,
      focusNode: focusNode,
      hasField: hasFiled,
    );
  }

  /// Creates a clean copy of the field state with all mode flags reset to [JustFieldStateMode.none].
  ///
  /// This is used after a field state has been processed to reset the state flags
  /// so that the same field doesn't trigger multiple rebuilds on subsequent updates.
  /// All other properties (value, error, attributes, etc.) are preserved.
  JustFieldState<T> _clean() {
    return _updateField(
      mode: [JustFieldStateMode.none],
      value: value,
      error: error,
      attributes: attributes,
      touched: touched,
      focusNode: focusNode,
      hasFiled: hasField,
    );
  }

  /// Validates this field using its list of validators.
  ///
  /// This method handles complex validation scenarios including:
  /// - Simple validators that only validate this field's value
  /// - Cross-field validators that validate this field against other fields
  /// - Validators with custom error messages for different fields
  ///
  /// The method calls [onFieldError] for each field affected by validation,
  /// passing the field name, error message (if any), whether the error applies
  /// to this field, and optional message checks.
  ///
  /// Returns true if all validators pass, false if any validator fails.
  ///
  /// Parameters:
  ///   - [values]: A map of all form field values used for cross-field validation
  ///   - [onFieldError]: A callback invoked for each field that has a validation result.
  ///     The callback parameters are:
  ///     - field: The name of the field with the error
  ///     - error: The error message, or null if valid
  ///     - isSelf: Whether this error applies to the current field
  ///     - msgCheck: Optional message check string
  bool _validateInner({
    required Map<String, dynamic> values,
    required void Function(
      String field,
      String? error,
      bool isSelf,
      String? msgCheck,
    )
    onFieldError,
    // bool withOnValidateTrigger = false,
  }) {
    var valid = true;
    for (var validator in validators.where((e) => e.targets.isEmpty)) {
      var error = validator.validator(value, values);
      if (valid && error != null) {
        onFieldError(name, error, true, null);
        valid = false;
        break;
      }
    }

    Map<String, bool> targetsValid = {};
    validators.where((e) => e.targets.isNotEmpty).forEach((v) {
      for (var t in v.targets) {
        targetsValid.putIfAbsent(
          t.field,
          () => (t.field == name || t.field == justReservedFieldName)
              ? valid
              : true,
        );
      }
    });

    for (var validator in validators.where((e) => e.targets.isNotEmpty)) {
      if (validator.targets.every((t) => targetsValid[t.field] != true)) {
        continue;
      }
      var error = validator.validator(value, values);
      for (var target in validator.targets.where(
        (t) => targetsValid[t.field] == true,
      )) {
        if (error != null) {
          targetsValid[target.field] = false;
          if (target.field == name || target.field == justReservedFieldName) {
            valid = false;
          }
          onFieldError(
            target.field,
            target.message(error),
            target.field == name,
            null,
          );
        } else {
          onFieldError(
            target.field,
            null,
            target.field == name,
            target.message.call(error),
          );
        }
      }
    }
    if (valid) {
      onFieldError(name, null, true, null);
    }
    return valid;
  }
}
