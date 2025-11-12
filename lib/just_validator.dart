import 'package:just_form/just_error.dart';

typedef Validator<T> =
    String? Function(T? value, Map<String, dynamic> formValues);

class JustValidator<T> {
  final Validator<T> validator;
  final List<FieldError> targets;
  const JustValidator({required this.validator, this.targets = const []});
}
