part of 'just_form_builder.dart';

enum JustFieldStateMode {
  none,
  update,
  updateInternal,
  error,
  attribute,
  validateExternal,
  initialization,
}

class JustFieldState<T> {
  final String name;
  final T? value;
  final T? initialValue;
  final String? error;
  final bool Function(T a, T b)? isEqual;
  final List<FormFieldValidator<T>?> validators;
  final Map<String, dynamic> attributes;
  final List<JustFieldStateMode> mode;
  final bool touched;
  final FocusNode? focusNode;
  final int? errorId;

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
    this.errorId,
  }) {
    if (mode.isEmpty) throw ("Field state must have at least one mode");
  }

  JustFieldState<T> copyWith({
    String? name,
    T? value,
    T? initialValue,
    String? error,
    bool Function(T a, T b)? isEqual,
    List<FormFieldValidator<T>>? validators,
    Map<String, dynamic>? attributes,
    List<JustFieldStateMode>? mode,
    bool? touched,
    FocusNode? focusNode,
    int? errorId,
  }) {
    return JustFieldState<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      initialValue: initialValue ?? this.initialValue,
      error: error ?? this.error,
      isEqual: isEqual ?? this.isEqual,
      validators: validators ?? this.validators,
      attributes: attributes ?? this.attributes,
      mode: mode ?? this.mode,
      touched: touched ?? this.touched,
      focusNode: focusNode ?? this.focusNode,
      errorId: errorId ?? this.errorId,
    );
  }

  JustFieldState<T> _clearError({bool addMode = false}) {
    return JustFieldState<T>(
      name: name,
      value: value,
      initialValue: initialValue,
      error: null,
      isEqual: isEqual,
      validators: validators,
      attributes: attributes,
      mode: addMode
          ? (mode..add(JustFieldStateMode.error))
          : [JustFieldStateMode.error],
      touched: touched,
      focusNode: focusNode,
      errorId: null,
    );
  }

  bool get isDirty => !valueEqualWith(initialValue);

  bool _valueEqual(T? a, T? b) {
    if (isEqual == null) return a == b;
    return a != null && b != null ? isEqual!(a as T, b as T) : a == b;
  }

  bool valueEqualWith(T? comparator) => _valueEqual(value, comparator);
}
