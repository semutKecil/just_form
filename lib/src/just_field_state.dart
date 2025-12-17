import 'package:freezed_annotation/freezed_annotation.dart';
part 'just_field_state.freezed.dart';

@freezed
abstract class JustFieldState<T> with _$JustFieldState<T> {
  const factory JustFieldState({
    required String name,
    required bool internal,
    required DateTime updateTime,
    T? value,
    String? error,
    @Default(true) bool active,
    @Default({}) Map<String, dynamic> attributes,
  }) = _JustFieldState<T>;
}
