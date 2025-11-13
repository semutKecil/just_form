import 'package:flutter/widgets.dart';
import 'package:just_form/just_field_error.dart';

typedef Validator<T> =
    String? Function(T? value, Map<String, dynamic> formValues);

/// This class `JustValidator<T>` has two main properties: `validator` and `targets`.
///
/// - [validator] is a generic type that represents a validation function for the given type `T`. This function takes a value and a map of form values and returns an error message if the value is invalid.
/// - [targets] is a list of `getFieldError` objects that represent the fields that this validator is associated with.
///
/// The `JustValidator` class also has a factory method `common` that creates a new instance of `JustValidator` with the given `validator` and `targets`. This factory method takes a `FormFieldValidator<T>` as input and wraps it in the `JustValidator` class. It uses the `validator` function to call the input `FormFieldValidator` with the given value and form values.
/// Overall, this class provides a way to create and manage validators for form fields in a generic way.
class JustValidator<T> {
  final Validator<T> validator;
  final List<JustFieldError> targets;

  /// Creates a new instance of `JustValidator` with the given `validator` and `targets`.
  ///
  /// The `JustValidator` constructor takes a `validator` and an optional `targets` list.
  /// The [validator] is a function that takes a value and a map of form values and returns an error message if the value is invalid. The `validator` is a generic type that represents a validation function for the given type `T`. This function takes a value and a map of form values and returns an error message if the value is invalid.
  /// The [targets] is a list of `getFieldError` objects that represent the fields that this validator is associated with. The `targets` is a list of `getFieldError` objects that represent the fields that this validator is associated with.
  ///
  /// The default value of `targets` is an empty list.
  const JustValidator({required this.validator, this.targets = const []});

  /// Creates a new instance of `JustValidator` with the given `validator` and `targets`.
  ///
  /// The `JustValidator.common` factory method takes a `FormFieldValidator<T>` as input and wraps it in the `JustValidator` class. It uses the `validator` function to call the input `FormFieldValidator` with the given value and form values.
  /// The `JustValidator.common` factory method is used to create validators that are associated with form fields. It provides a way to create and manage validators for form fields in a generic way.
  factory JustValidator.common(
    FormFieldValidator<T> validator, {
    List<JustFieldError> targets = const [],
  }) {
    return JustValidator<T>(
      validator: (value, formValues) {
        return validator(value);
      },
      targets: targets,
    );
  }
}
