// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_cut_text_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RemoteFrameBufferServerCutTextMessage {
  String get text => throw _privateConstructorUsedError;

  /// Create a copy of RemoteFrameBufferServerCutTextMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RemoteFrameBufferServerCutTextMessageCopyWith<
          RemoteFrameBufferServerCutTextMessage>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteFrameBufferServerCutTextMessageCopyWith<$Res> {
  factory $RemoteFrameBufferServerCutTextMessageCopyWith(
          RemoteFrameBufferServerCutTextMessage value,
          $Res Function(RemoteFrameBufferServerCutTextMessage) then) =
      _$RemoteFrameBufferServerCutTextMessageCopyWithImpl<$Res,
          RemoteFrameBufferServerCutTextMessage>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class _$RemoteFrameBufferServerCutTextMessageCopyWithImpl<$Res,
        $Val extends RemoteFrameBufferServerCutTextMessage>
    implements $RemoteFrameBufferServerCutTextMessageCopyWith<$Res> {
  _$RemoteFrameBufferServerCutTextMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RemoteFrameBufferServerCutTextMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RemoteFrameBufferServerCutTextMessageImplCopyWith<$Res>
    implements $RemoteFrameBufferServerCutTextMessageCopyWith<$Res> {
  factory _$$RemoteFrameBufferServerCutTextMessageImplCopyWith(
          _$RemoteFrameBufferServerCutTextMessageImpl value,
          $Res Function(_$RemoteFrameBufferServerCutTextMessageImpl) then) =
      __$$RemoteFrameBufferServerCutTextMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$RemoteFrameBufferServerCutTextMessageImplCopyWithImpl<$Res>
    extends _$RemoteFrameBufferServerCutTextMessageCopyWithImpl<$Res,
        _$RemoteFrameBufferServerCutTextMessageImpl>
    implements _$$RemoteFrameBufferServerCutTextMessageImplCopyWith<$Res> {
  __$$RemoteFrameBufferServerCutTextMessageImplCopyWithImpl(
      _$RemoteFrameBufferServerCutTextMessageImpl _value,
      $Res Function(_$RemoteFrameBufferServerCutTextMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of RemoteFrameBufferServerCutTextMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_$RemoteFrameBufferServerCutTextMessageImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RemoteFrameBufferServerCutTextMessageImpl
    extends _RemoteFrameBufferServerCutTextMessage {
  const _$RemoteFrameBufferServerCutTextMessageImpl({required this.text})
      : super._();

  @override
  final String text;

  @override
  String toString() {
    return 'RemoteFrameBufferServerCutTextMessage(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteFrameBufferServerCutTextMessageImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of RemoteFrameBufferServerCutTextMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteFrameBufferServerCutTextMessageImplCopyWith<
          _$RemoteFrameBufferServerCutTextMessageImpl>
      get copyWith => __$$RemoteFrameBufferServerCutTextMessageImplCopyWithImpl<
          _$RemoteFrameBufferServerCutTextMessageImpl>(this, _$identity);
}

abstract class _RemoteFrameBufferServerCutTextMessage
    extends RemoteFrameBufferServerCutTextMessage {
  const factory _RemoteFrameBufferServerCutTextMessage(
          {required final String text}) =
      _$RemoteFrameBufferServerCutTextMessageImpl;
  const _RemoteFrameBufferServerCutTextMessage._() : super._();

  @override
  String get text;

  /// Create a copy of RemoteFrameBufferServerCutTextMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RemoteFrameBufferServerCutTextMessageImplCopyWith<
          _$RemoteFrameBufferServerCutTextMessageImpl>
      get copyWith => throw _privateConstructorUsedError;
}
