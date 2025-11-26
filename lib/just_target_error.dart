class JustTargetError {
  final String field;
  final String? Function(String? error) message;
  const JustTargetError({required this.field, required this.message});
}
