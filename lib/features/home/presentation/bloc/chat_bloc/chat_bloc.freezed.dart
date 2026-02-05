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
    required TResult Function() contactsLoading,
    required TResult Function(String mssg, String receiverId) sendMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? contactsLoading,
    TResult? Function(String mssg, String receiverId)? sendMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? contactsLoading,
    TResult Function(String mssg, String receiverId)? sendMssg,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_ContactsLoading value) contactsLoading,
    required TResult Function(_SendMssg value) sendMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_ContactsLoading value)? contactsLoading,
    TResult? Function(_SendMssg value)? sendMssg,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_ContactsLoading value)? contactsLoading,
    TResult Function(_SendMssg value)? sendMssg,
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
    required TResult Function() contactsLoading,
    required TResult Function(String mssg, String receiverId) sendMssg,
  }) {
    return init();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? contactsLoading,
    TResult? Function(String mssg, String receiverId)? sendMssg,
  }) {
    return init?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? contactsLoading,
    TResult Function(String mssg, String receiverId)? sendMssg,
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
    required TResult Function(_ContactsLoading value) contactsLoading,
    required TResult Function(_SendMssg value) sendMssg,
  }) {
    return init(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_ContactsLoading value)? contactsLoading,
    TResult? Function(_SendMssg value)? sendMssg,
  }) {
    return init?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_ContactsLoading value)? contactsLoading,
    TResult Function(_SendMssg value)? sendMssg,
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
abstract class _$$ContactsLoadingImplCopyWith<$Res> {
  factory _$$ContactsLoadingImplCopyWith(
    _$ContactsLoadingImpl value,
    $Res Function(_$ContactsLoadingImpl) then,
  ) = __$$ContactsLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ContactsLoadingImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$ContactsLoadingImpl>
    implements _$$ContactsLoadingImplCopyWith<$Res> {
  __$$ContactsLoadingImplCopyWithImpl(
    _$ContactsLoadingImpl _value,
    $Res Function(_$ContactsLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ContactsLoadingImpl implements _ContactsLoading {
  const _$ContactsLoadingImpl();

  @override
  String toString() {
    return 'ChatEvent.contactsLoading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ContactsLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() init,
    required TResult Function() contactsLoading,
    required TResult Function(String mssg, String receiverId) sendMssg,
  }) {
    return contactsLoading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? contactsLoading,
    TResult? Function(String mssg, String receiverId)? sendMssg,
  }) {
    return contactsLoading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? contactsLoading,
    TResult Function(String mssg, String receiverId)? sendMssg,
    required TResult orElse(),
  }) {
    if (contactsLoading != null) {
      return contactsLoading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_ContactsLoading value) contactsLoading,
    required TResult Function(_SendMssg value) sendMssg,
  }) {
    return contactsLoading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_ContactsLoading value)? contactsLoading,
    TResult? Function(_SendMssg value)? sendMssg,
  }) {
    return contactsLoading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_ContactsLoading value)? contactsLoading,
    TResult Function(_SendMssg value)? sendMssg,
    required TResult orElse(),
  }) {
    if (contactsLoading != null) {
      return contactsLoading(this);
    }
    return orElse();
  }
}

abstract class _ContactsLoading implements ChatEvent {
  const factory _ContactsLoading() = _$ContactsLoadingImpl;
}

/// @nodoc
abstract class _$$SendMssgImplCopyWith<$Res> {
  factory _$$SendMssgImplCopyWith(
    _$SendMssgImpl value,
    $Res Function(_$SendMssgImpl) then,
  ) = __$$SendMssgImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String mssg, String receiverId});
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
  $Res call({Object? mssg = null, Object? receiverId = null}) {
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
      ),
    );
  }
}

/// @nodoc

class _$SendMssgImpl implements _SendMssg {
  const _$SendMssgImpl({required this.mssg, required this.receiverId});

  @override
  final String mssg;
  // required String sendID,
  @override
  final String receiverId;

  @override
  String toString() {
    return 'ChatEvent.sendMssg(mssg: $mssg, receiverId: $receiverId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMssgImpl &&
            (identical(other.mssg, mssg) || other.mssg == mssg) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mssg, receiverId);

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
    required TResult Function() contactsLoading,
    required TResult Function(String mssg, String receiverId) sendMssg,
  }) {
    return sendMssg(mssg, receiverId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? init,
    TResult? Function()? contactsLoading,
    TResult? Function(String mssg, String receiverId)? sendMssg,
  }) {
    return sendMssg?.call(mssg, receiverId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? init,
    TResult Function()? contactsLoading,
    TResult Function(String mssg, String receiverId)? sendMssg,
    required TResult orElse(),
  }) {
    if (sendMssg != null) {
      return sendMssg(mssg, receiverId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Init value) init,
    required TResult Function(_ContactsLoading value) contactsLoading,
    required TResult Function(_SendMssg value) sendMssg,
  }) {
    return sendMssg(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Init value)? init,
    TResult? Function(_ContactsLoading value)? contactsLoading,
    TResult? Function(_SendMssg value)? sendMssg,
  }) {
    return sendMssg?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Init value)? init,
    TResult Function(_ContactsLoading value)? contactsLoading,
    TResult Function(_SendMssg value)? sendMssg,
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
  }) = _$SendMssgImpl;

  String get mssg; // required String sendID,
  String get receiverId;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendMssgImplCopyWith<_$SendMssgImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatState {
  Status get contactStatus => throw _privateConstructorUsedError;
  Status get mssgStatus => throw _privateConstructorUsedError;
  List<UserModel> get contacts => throw _privateConstructorUsedError;

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
    Status contactStatus,
    Status mssgStatus,
    List<UserModel> contacts,
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
    Object? contactStatus = null,
    Object? mssgStatus = null,
    Object? contacts = null,
  }) {
    return _then(
      _value.copyWith(
            contactStatus: null == contactStatus
                ? _value.contactStatus
                : contactStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            mssgStatus: null == mssgStatus
                ? _value.mssgStatus
                : mssgStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            contacts: null == contacts
                ? _value.contacts
                : contacts // ignore: cast_nullable_to_non_nullable
                      as List<UserModel>,
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
    Status contactStatus,
    Status mssgStatus,
    List<UserModel> contacts,
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
    Object? contactStatus = null,
    Object? mssgStatus = null,
    Object? contacts = null,
  }) {
    return _then(
      _$ChatStateImpl(
        contactStatus: null == contactStatus
            ? _value.contactStatus
            : contactStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        mssgStatus: null == mssgStatus
            ? _value.mssgStatus
            : mssgStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        contacts: null == contacts
            ? _value._contacts
            : contacts // ignore: cast_nullable_to_non_nullable
                  as List<UserModel>,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl implements _ChatState {
  const _$ChatStateImpl({
    this.contactStatus = Status.init,
    this.mssgStatus = Status.init,
    final List<UserModel> contacts = const [],
  }) : _contacts = contacts;

  @override
  @JsonKey()
  final Status contactStatus;
  @override
  @JsonKey()
  final Status mssgStatus;
  final List<UserModel> _contacts;
  @override
  @JsonKey()
  List<UserModel> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  String toString() {
    return 'ChatState(contactStatus: $contactStatus, mssgStatus: $mssgStatus, contacts: $contacts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            (identical(other.contactStatus, contactStatus) ||
                other.contactStatus == contactStatus) &&
            (identical(other.mssgStatus, mssgStatus) ||
                other.mssgStatus == mssgStatus) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    contactStatus,
    mssgStatus,
    const DeepCollectionEquality().hash(_contacts),
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
    final Status contactStatus,
    final Status mssgStatus,
    final List<UserModel> contacts,
  }) = _$ChatStateImpl;

  @override
  Status get contactStatus;
  @override
  Status get mssgStatus;
  @override
  List<UserModel> get contacts;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
