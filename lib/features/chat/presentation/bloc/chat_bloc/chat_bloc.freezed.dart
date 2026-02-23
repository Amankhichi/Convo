// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatEventCopyWith<$Res> {
  factory $ChatEventCopyWith(ChatEvent value, $Res Function(ChatEvent) then) =
      _$ChatEventCopyWithImpl<$Res, ChatEvent>;
}

/// @nodoc
class _$ChatEventCopyWithImpl<$Res, $Val extends ChatEvent>
    implements $ChatEventCopyWith<$Res> {
  _$ChatEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitImplCopyWith<$Res> {
  factory _$$InitImplCopyWith(
    _$InitImpl value,
    $Res Function(_$InitImpl) then,
  ) = __$$InitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$InitImpl>
    implements _$$InitImplCopyWith<$Res> {
  __$$InitImplCopyWithImpl(_$InitImpl _value, $Res Function(_$InitImpl) _then)
    : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitImpl implements _Init {
  const _$InitImpl();

  @override
  String toString() {
    return 'ChatEvent.init()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return init();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return init?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (init != null) {
      return init();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return init(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return init?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (init != null) {
      return init(this);
    }
    return orElse();
  }
}

abstract class _Init implements ChatEvent {
  const factory _Init() = _$InitImpl;
}

/// @nodoc
abstract class _$$SendMssgImplCopyWith<$Res> {
  factory _$$SendMssgImplCopyWith(
    _$SendMssgImpl value,
    $Res Function(_$SendMssgImpl) then,
  ) = __$$SendMssgImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String mssg, String receiverId, int? replyTo});
}

/// @nodoc
class __$$SendMssgImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$SendMssgImpl>
    implements _$$SendMssgImplCopyWith<$Res> {
  __$$SendMssgImplCopyWithImpl(
    _$SendMssgImpl _value,
    $Res Function(_$SendMssgImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mssg = null,
    Object? receiverId = null,
    Object? replyTo = freezed,
  }) {
    return _then(
      _$SendMssgImpl(
        mssg: null == mssg
            ? _value.mssg
            : mssg // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as String,
        replyTo: freezed == replyTo
            ? _value.replyTo
            : replyTo // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$SendMssgImpl implements _SendMssg {
  const _$SendMssgImpl({
    required this.mssg,
    required this.receiverId,
    required this.replyTo,
  });

  @override
  final String mssg;
  @override
  final String receiverId;
  @override
  final int? replyTo;

  @override
  String toString() {
    return 'ChatEvent.sendMssg(mssg: $mssg, receiverId: $receiverId, replyTo: $replyTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMssgImpl &&
            (identical(other.mssg, mssg) || other.mssg == mssg) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mssg, receiverId, replyTo);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMssgImplCopyWith<_$SendMssgImpl> get copyWith =>
      __$$SendMssgImplCopyWithImpl<_$SendMssgImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return sendMssg(mssg, receiverId, replyTo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return sendMssg?.call(mssg, receiverId, replyTo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (sendMssg != null) {
      return sendMssg(mssg, receiverId, replyTo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return sendMssg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return sendMssg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (sendMssg != null) {
      return sendMssg(this);
    }
    return orElse();
  }
}

abstract class _SendMssg implements ChatEvent {
  const factory _SendMssg({
    required final String mssg,
    required final String receiverId,
    required final int? replyTo,
  }) = _$SendMssgImpl;

  String get mssg;
  String get receiverId;
  int? get replyTo;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendMssgImplCopyWith<_$SendMssgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMssgImplCopyWith<$Res> {
  factory _$$GetMssgImplCopyWith(
    _$GetMssgImpl value,
    $Res Function(_$GetMssgImpl) then,
  ) = __$$GetMssgImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String receiverId});
}

/// @nodoc
class __$$GetMssgImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$GetMssgImpl>
    implements _$$GetMssgImplCopyWith<$Res> {
  __$$GetMssgImplCopyWithImpl(
    _$GetMssgImpl _value,
    $Res Function(_$GetMssgImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? receiverId = null}) {
    return _then(
      _$GetMssgImpl(
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GetMssgImpl implements _GetMssg {
  const _$GetMssgImpl({required this.receiverId});

  @override
  final String receiverId;

  @override
  String toString() {
    return 'ChatEvent.getMssg(receiverId: $receiverId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMssgImpl &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, receiverId);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMssgImplCopyWith<_$GetMssgImpl> get copyWith =>
      __$$GetMssgImplCopyWithImpl<_$GetMssgImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return getMssg(receiverId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return getMssg?.call(receiverId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (getMssg != null) {
      return getMssg(receiverId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return getMssg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return getMssg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (getMssg != null) {
      return getMssg(this);
    }
    return orElse();
  }
}

abstract class _GetMssg implements ChatEvent {
  const factory _GetMssg({required final String receiverId}) = _$GetMssgImpl;

  String get receiverId;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetMssgImplCopyWith<_$GetMssgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeletMssgImplCopyWith<$Res> {
  factory _$$DeletMssgImplCopyWith(
    _$DeletMssgImpl value,
    $Res Function(_$DeletMssgImpl) then,
  ) = __$$DeletMssgImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int mssId});
}

/// @nodoc
class __$$DeletMssgImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$DeletMssgImpl>
    implements _$$DeletMssgImplCopyWith<$Res> {
  __$$DeletMssgImplCopyWithImpl(
    _$DeletMssgImpl _value,
    $Res Function(_$DeletMssgImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mssId = null}) {
    return _then(
      _$DeletMssgImpl(
        mssId: null == mssId
            ? _value.mssId
            : mssId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DeletMssgImpl implements _DeletMssg {
  const _$DeletMssgImpl({required this.mssId});

  @override
  final int mssId;

  @override
  String toString() {
    return 'ChatEvent.deletMssg(mssId: $mssId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeletMssgImpl &&
            (identical(other.mssId, mssId) || other.mssId == mssId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mssId);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeletMssgImplCopyWith<_$DeletMssgImpl> get copyWith =>
      __$$DeletMssgImplCopyWithImpl<_$DeletMssgImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return deletMssg(mssId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return deletMssg?.call(mssId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (deletMssg != null) {
      return deletMssg(mssId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return deletMssg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return deletMssg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (deletMssg != null) {
      return deletMssg(this);
    }
    return orElse();
  }
}

abstract class _DeletMssg implements ChatEvent {
  const factory _DeletMssg({required final int mssId}) = _$DeletMssgImpl;

  int get mssId;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeletMssgImplCopyWith<_$DeletMssgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BlockButtonImplCopyWith<$Res> {
  factory _$$BlockButtonImplCopyWith(
    _$BlockButtonImpl value,
    $Res Function(_$BlockButtonImpl) then,
  ) = __$$BlockButtonImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool block});
}

/// @nodoc
class __$$BlockButtonImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$BlockButtonImpl>
    implements _$$BlockButtonImplCopyWith<$Res> {
  __$$BlockButtonImplCopyWithImpl(
    _$BlockButtonImpl _value,
    $Res Function(_$BlockButtonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? block = null}) {
    return _then(
      _$BlockButtonImpl(
        block: null == block
            ? _value.block
            : block // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$BlockButtonImpl implements _BlockButton {
  const _$BlockButtonImpl({required this.block});

  @override
  final bool block;

  @override
  String toString() {
    return 'ChatEvent.blockButton(block: $block)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockButtonImpl &&
            (identical(other.block, block) || other.block == block));
  }

  @override
  int get hashCode => Object.hash(runtimeType, block);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockButtonImplCopyWith<_$BlockButtonImpl> get copyWith =>
      __$$BlockButtonImplCopyWithImpl<_$BlockButtonImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return blockButton(block);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return blockButton?.call(block);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (blockButton != null) {
      return blockButton(block);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return blockButton(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return blockButton?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (blockButton != null) {
      return blockButton(this);
    }
    return orElse();
  }
}

abstract class _BlockButton implements ChatEvent {
  const factory _BlockButton({required final bool block}) = _$BlockButtonImpl;

  bool get block;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockButtonImplCopyWith<_$BlockButtonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EditMssgImplCopyWith<$Res> {
  factory _$$EditMssgImplCopyWith(
    _$EditMssgImpl value,
    $Res Function(_$EditMssgImpl) then,
  ) = __$$EditMssgImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int mssgId, String newMssg});
}

/// @nodoc
class __$$EditMssgImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$EditMssgImpl>
    implements _$$EditMssgImplCopyWith<$Res> {
  __$$EditMssgImplCopyWithImpl(
    _$EditMssgImpl _value,
    $Res Function(_$EditMssgImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mssgId = null, Object? newMssg = null}) {
    return _then(
      _$EditMssgImpl(
        mssgId: null == mssgId
            ? _value.mssgId
            : mssgId // ignore: cast_nullable_to_non_nullable
                  as int,
        newMssg: null == newMssg
            ? _value.newMssg
            : newMssg // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$EditMssgImpl implements _EditMssg {
  const _$EditMssgImpl({required this.mssgId, required this.newMssg});

  @override
  final int mssgId;
  @override
  final String newMssg;

  @override
  String toString() {
    return 'ChatEvent.editMssg(mssgId: $mssgId, newMssg: $newMssg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditMssgImpl &&
            (identical(other.mssgId, mssgId) || other.mssgId == mssgId) &&
            (identical(other.newMssg, newMssg) || other.newMssg == newMssg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mssgId, newMssg);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditMssgImplCopyWith<_$EditMssgImpl> get copyWith =>
      __$$EditMssgImplCopyWithImpl<_$EditMssgImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function(String mssg, String receiverId, int? replyTo)
    sendMssg,
    required TResult Function(String receiverId) getMssg,
    required TResult Function(int mssId) deletMssg,
    required TResult Function(bool block) blockButton,
    required TResult Function(int mssgId, String newMssg) editMssg,
  }) {
    return editMssg(mssgId, newMssg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult? Function(String receiverId)? getMssg,
    TResult? Function(int mssId)? deletMssg,
    TResult? Function(bool block)? blockButton,
    TResult? Function(int mssgId, String newMssg)? editMssg,
  }) {
    return editMssg?.call(mssgId, newMssg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function(String mssg, String receiverId, int? replyTo)? sendMssg,
    TResult Function(String receiverId)? getMssg,
    TResult Function(int mssId)? deletMssg,
    TResult Function(bool block)? blockButton,
    TResult Function(int mssgId, String newMssg)? editMssg,
    required TResult orElse(),
  }) {
    if (editMssg != null) {
      return editMssg(mssgId, newMssg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_SendMssg value) sendMssg,
    required TResult Function(_GetMssg value) getMssg,
    required TResult Function(_DeletMssg value) deletMssg,
    required TResult Function(_BlockButton value) blockButton,
    required TResult Function(_EditMssg value) editMssg,
  }) {
    return editMssg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_SendMssg value)? sendMssg,
    TResult? Function(_GetMssg value)? getMssg,
    TResult? Function(_DeletMssg value)? deletMssg,
    TResult? Function(_BlockButton value)? blockButton,
    TResult? Function(_EditMssg value)? editMssg,
  }) {
    return editMssg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_SendMssg value)? sendMssg,
    TResult Function(_GetMssg value)? getMssg,
    TResult Function(_DeletMssg value)? deletMssg,
    TResult Function(_BlockButton value)? blockButton,
    TResult Function(_EditMssg value)? editMssg,
    required TResult orElse(),
  }) {
    if (editMssg != null) {
      return editMssg(this);
    }
    return orElse();
  }
}

abstract class _EditMssg implements ChatEvent {
  const factory _EditMssg({
    required final int mssgId,
    required final String newMssg,
  }) = _$EditMssgImpl;

  int get mssgId;
  String get newMssg;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditMssgImplCopyWith<_$EditMssgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatState {
  List<UserModel> get contacts => throw _privateConstructorUsedError;
  Status get contactStatus => throw _privateConstructorUsedError;
  Status get SendMssgStatus => throw _privateConstructorUsedError;
  Status get GetMssgStatus => throw _privateConstructorUsedError;
  List<ChatModel> get messages => throw _privateConstructorUsedError;
  Status get DeleteMssgStatus => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({
    List<UserModel> contacts,
    Status contactStatus,
    Status SendMssgStatus,
    Status GetMssgStatus,
    List<ChatModel> messages,
    Status DeleteMssgStatus,
  });
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? contactStatus = null,
    Object? SendMssgStatus = null,
    Object? GetMssgStatus = null,
    Object? messages = null,
    Object? DeleteMssgStatus = null,
  }) {
    return _then(
      _value.copyWith(
            contacts: null == contacts
                ? _value.contacts
                : contacts // ignore: cast_nullable_to_non_nullable
                      as List<UserModel>,
            contactStatus: null == contactStatus
                ? _value.contactStatus
                : contactStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            SendMssgStatus: null == SendMssgStatus
                ? _value.SendMssgStatus
                : SendMssgStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            GetMssgStatus: null == GetMssgStatus
                ? _value.GetMssgStatus
                : GetMssgStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<ChatModel>,
            DeleteMssgStatus: null == DeleteMssgStatus
                ? _value.DeleteMssgStatus
                : DeleteMssgStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
    _$ChatStateImpl value,
    $Res Function(_$ChatStateImpl) then,
  ) = __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<UserModel> contacts,
    Status contactStatus,
    Status SendMssgStatus,
    Status GetMssgStatus,
    List<ChatModel> messages,
    Status DeleteMssgStatus,
  });
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
    _$ChatStateImpl _value,
    $Res Function(_$ChatStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? contactStatus = null,
    Object? SendMssgStatus = null,
    Object? GetMssgStatus = null,
    Object? messages = null,
    Object? DeleteMssgStatus = null,
  }) {
    return _then(
      _$ChatStateImpl(
        contacts: null == contacts
            ? _value._contacts
            : contacts // ignore: cast_nullable_to_non_nullable
                  as List<UserModel>,
        contactStatus: null == contactStatus
            ? _value.contactStatus
            : contactStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        SendMssgStatus: null == SendMssgStatus
            ? _value.SendMssgStatus
            : SendMssgStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        GetMssgStatus: null == GetMssgStatus
            ? _value.GetMssgStatus
            : GetMssgStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<ChatModel>,
        DeleteMssgStatus: null == DeleteMssgStatus
            ? _value.DeleteMssgStatus
            : DeleteMssgStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl implements _ChatState {
  const _$ChatStateImpl({
    final List<UserModel> contacts = const [],
    this.contactStatus = Status.init,
    this.SendMssgStatus = Status.init,
    this.GetMssgStatus = Status.init,
    final List<ChatModel> messages = const [],
    this.DeleteMssgStatus = Status.init,
  }) : _contacts = contacts,
       _messages = messages;

  final List<UserModel> _contacts;
  @override
  @JsonKey()
  List<UserModel> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  @JsonKey()
  final Status contactStatus;
  @override
  @JsonKey()
  final Status SendMssgStatus;
  @override
  @JsonKey()
  final Status GetMssgStatus;
  final List<ChatModel> _messages;
  @override
  @JsonKey()
  List<ChatModel> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final Status DeleteMssgStatus;

  @override
  String toString() {
    return 'ChatState(contacts: $contacts, contactStatus: $contactStatus, SendMssgStatus: $SendMssgStatus, GetMssgStatus: $GetMssgStatus, messages: $messages, DeleteMssgStatus: $DeleteMssgStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.contactStatus, contactStatus) ||
                other.contactStatus == contactStatus) &&
            (identical(other.SendMssgStatus, SendMssgStatus) ||
                other.SendMssgStatus == SendMssgStatus) &&
            (identical(other.GetMssgStatus, GetMssgStatus) ||
                other.GetMssgStatus == GetMssgStatus) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.DeleteMssgStatus, DeleteMssgStatus) ||
                other.DeleteMssgStatus == DeleteMssgStatus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_contacts),
    contactStatus,
    SendMssgStatus,
    GetMssgStatus,
    const DeepCollectionEquality().hash(_messages),
    DeleteMssgStatus,
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState implements ChatState {
  const factory _ChatState({
    final List<UserModel> contacts,
    final Status contactStatus,
    final Status SendMssgStatus,
    final Status GetMssgStatus,
    final List<ChatModel> messages,
    final Status DeleteMssgStatus,
  }) = _$ChatStateImpl;

  @override
  List<UserModel> get contacts;
  @override
  Status get contactStatus;
  @override
  Status get SendMssgStatus;
  @override
  Status get GetMssgStatus;
  @override
  List<ChatModel> get messages;
  @override
  Status get DeleteMssgStatus;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
