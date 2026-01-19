class JustFieldState<T> {
  final String name;
  final bool internal;
  final DateTime updateTime;
  final T? value;
  final String? error;
  final bool active;
  final Map<String, dynamic> attributes;

  const JustFieldState({
    required this.name,
    required this.internal,
    required this.updateTime,
    this.value,
    this.error,
    this.active = true,
    this.attributes = const {},
  });

  JustFieldState<T> copyWith({
    String? name,
    bool? internal,
    DateTime? updateTime,
    T? value,
    String? error,
    bool? active,
    Map<String, dynamic>? attributes,
  }) {
    return JustFieldState<T>(
      name: name ?? this.name,
      internal: internal ?? this.internal,
      updateTime: updateTime ?? this.updateTime,
      value: value ?? this.value,
      error: error ?? this.error,
      active: active ?? this.active,
      attributes: attributes ?? this.attributes,
    );
  }
}
