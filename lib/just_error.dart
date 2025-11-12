class JustError {
  final String? message;
  final List<FieldError> otherFields;
  const JustError({this.message, this.otherFields = const []});
}

class FieldError {
  final String field;
  final String? Function(String? error) message;
  const FieldError({required this.field, required this.message});
}
