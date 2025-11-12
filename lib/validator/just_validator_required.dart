import 'dart:collection';
import 'dart:typed_data';
import 'package:just_form/just_validator.dart';

class JustValidatorRequired<T> extends JustValidator<T> {
  final String message;
  JustValidatorRequired({this.message = "error-required", super.targets})
    : super(
        validator: (value, formValues) {
          if (value == null) return message;
          if (value is String && value.isEmpty) return message;
          if (value is List && value.isEmpty) return message;
          if (value is Iterable && value.isEmpty) return message;
          if (value is Map && value.isEmpty) return message;
          if (value is Set && value.isEmpty) return message;
          if (value is Queue && value.isEmpty) return message;
          if (value is Uint8List && value.isEmpty) return message;
          return null;
        },
      );
}
