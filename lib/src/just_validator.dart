import 'package:flutter/widgets.dart';
import 'package:just_form/src/just_target_error.dart';

class JustValidator {
  final List<String> triggers;
  final FormFieldValidator<Map<String, dynamic>> validator;
  final List<JustTargetError> targets;

  const JustValidator({
    required this.triggers,
    required this.validator,
    this.targets = const [],
  });
}
