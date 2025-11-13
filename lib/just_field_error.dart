/// A class that represents a field error in a form.
///
/// This class is used to represent an error of a field in a form.
/// It contains the name of the field and a function that takes an error message and returns a new error message.
///
/// The [field] parameter is the name of the field that the error is associated with.
///
/// The [message] parameter is a function that takes an error message and returns a new error message.
/// This function is used to format the error message of the field.
class JustFieldError {
  final String field;
  final String? Function(String? error) message;
  const JustFieldError({required this.field, required this.message});
}
