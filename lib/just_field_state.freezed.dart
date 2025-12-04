// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'just_field_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JustFieldState<T> {

 String get name; bool get internal; T? get value; String? get error; bool get active; Map<String, dynamic> get attributes;
/// Create a copy of JustFieldState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JustFieldStateCopyWith<T, JustFieldState<T>> get copyWith => _$JustFieldStateCopyWithImpl<T, JustFieldState<T>>(this as JustFieldState<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JustFieldState<T>&&(identical(other.name, name) || other.name == name)&&(identical(other.internal, internal) || other.internal == internal)&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.error, error) || other.error == error)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other.attributes, attributes));
}


@override
int get hashCode => Object.hash(runtimeType,name,internal,const DeepCollectionEquality().hash(value),error,active,const DeepCollectionEquality().hash(attributes));

@override
String toString() {
  return 'JustFieldState<$T>(name: $name, internal: $internal, value: $value, error: $error, active: $active, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class $JustFieldStateCopyWith<T,$Res>  {
  factory $JustFieldStateCopyWith(JustFieldState<T> value, $Res Function(JustFieldState<T>) _then) = _$JustFieldStateCopyWithImpl;
@useResult
$Res call({
 String name, bool internal, T? value, String? error, bool active, Map<String, dynamic> attributes
});




}
/// @nodoc
class _$JustFieldStateCopyWithImpl<T,$Res>
    implements $JustFieldStateCopyWith<T, $Res> {
  _$JustFieldStateCopyWithImpl(this._self, this._then);

  final JustFieldState<T> _self;
  final $Res Function(JustFieldState<T>) _then;

/// Create a copy of JustFieldState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? internal = null,Object? value = freezed,Object? error = freezed,Object? active = null,Object? attributes = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as bool,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [JustFieldState].
extension JustFieldStatePatterns<T> on JustFieldState<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JustFieldState<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JustFieldState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JustFieldState<T> value)  $default,){
final _that = this;
switch (_that) {
case _JustFieldState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JustFieldState<T> value)?  $default,){
final _that = this;
switch (_that) {
case _JustFieldState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool internal,  T? value,  String? error,  bool active,  Map<String, dynamic> attributes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JustFieldState() when $default != null:
return $default(_that.name,_that.internal,_that.value,_that.error,_that.active,_that.attributes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool internal,  T? value,  String? error,  bool active,  Map<String, dynamic> attributes)  $default,) {final _that = this;
switch (_that) {
case _JustFieldState():
return $default(_that.name,_that.internal,_that.value,_that.error,_that.active,_that.attributes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool internal,  T? value,  String? error,  bool active,  Map<String, dynamic> attributes)?  $default,) {final _that = this;
switch (_that) {
case _JustFieldState() when $default != null:
return $default(_that.name,_that.internal,_that.value,_that.error,_that.active,_that.attributes);case _:
  return null;

}
}

}

/// @nodoc


class _JustFieldState<T> implements JustFieldState<T> {
  const _JustFieldState({required this.name, required this.internal, this.value, this.error, this.active = true, final  Map<String, dynamic> attributes = const {}}): _attributes = attributes;
  

@override final  String name;
@override final  bool internal;
@override final  T? value;
@override final  String? error;
@override@JsonKey() final  bool active;
 final  Map<String, dynamic> _attributes;
@override@JsonKey() Map<String, dynamic> get attributes {
  if (_attributes is EqualUnmodifiableMapView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attributes);
}


/// Create a copy of JustFieldState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JustFieldStateCopyWith<T, _JustFieldState<T>> get copyWith => __$JustFieldStateCopyWithImpl<T, _JustFieldState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JustFieldState<T>&&(identical(other.name, name) || other.name == name)&&(identical(other.internal, internal) || other.internal == internal)&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.error, error) || other.error == error)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other._attributes, _attributes));
}


@override
int get hashCode => Object.hash(runtimeType,name,internal,const DeepCollectionEquality().hash(value),error,active,const DeepCollectionEquality().hash(_attributes));

@override
String toString() {
  return 'JustFieldState<$T>(name: $name, internal: $internal, value: $value, error: $error, active: $active, attributes: $attributes)';
}


}

/// @nodoc
abstract mixin class _$JustFieldStateCopyWith<T,$Res> implements $JustFieldStateCopyWith<T, $Res> {
  factory _$JustFieldStateCopyWith(_JustFieldState<T> value, $Res Function(_JustFieldState<T>) _then) = __$JustFieldStateCopyWithImpl;
@override @useResult
$Res call({
 String name, bool internal, T? value, String? error, bool active, Map<String, dynamic> attributes
});




}
/// @nodoc
class __$JustFieldStateCopyWithImpl<T,$Res>
    implements _$JustFieldStateCopyWith<T, $Res> {
  __$JustFieldStateCopyWithImpl(this._self, this._then);

  final _JustFieldState<T> _self;
  final $Res Function(_JustFieldState<T>) _then;

/// Create a copy of JustFieldState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? internal = null,Object? value = freezed,Object? error = freezed,Object? active = null,Object? attributes = null,}) {
  return _then(_JustFieldState<T>(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as bool,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
