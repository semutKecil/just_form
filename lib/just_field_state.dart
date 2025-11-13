part of 'just_form.dart';

enum JustFieldStateMode { none, update, updateInternal, error, attribute }

class JustFieldState<T> {
  final String name;
  final T? value;
  final T? initialValue;
  final String? error;
  final bool Function(T a, T b)? isEqual;
  final List<JustValidator<T>> validators;
  final Map<String, dynamic> attributes;
  final List<JustFieldStateMode> mode;
  final bool touched;
  final FocusNode? focusNode;

  const JustFieldState({
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
  });

  bool get isDirty => !valueEqualWith(initialValue);

  bool _valueEqual(T? a, T? b) {
    if (isEqual == null) return a == b;
    return a != null && b != null ? isEqual!(a as T, b as T) : a == b;
  }

  bool valueEqualWith(T? comparator) => _valueEqual(value, comparator);

  JustFieldState<T> _updateField({
    required List<JustFieldStateMode> mode,
    required T? value,
    required String? error,
    required Map<String, dynamic> attributes,
    required bool touched,
    required FocusNode? focusNode,
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
    );
  }

  JustFieldState<T> _clean() {
    return _updateField(
      mode: [JustFieldStateMode.none],
      value: value,
      error: error,
      attributes: attributes,
      touched: touched,
      focusNode: focusNode,
    );
  }

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
