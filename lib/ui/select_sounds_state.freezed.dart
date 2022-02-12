// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'select_sounds_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$SelectSoundsStateTearOff {
  const _$SelectSoundsStateTearOff();

  _SelectSoundsState call(
      {required Template template,
      required List<SelectedSound?> sounds,
      bool isProcessing = false}) {
    return _SelectSoundsState(
      template: template,
      sounds: sounds,
      isProcessing: isProcessing,
    );
  }
}

/// @nodoc
const $SelectSoundsState = _$SelectSoundsStateTearOff();

/// @nodoc
mixin _$SelectSoundsState {
  Template get template => throw _privateConstructorUsedError;
  List<SelectedSound?> get sounds => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SelectSoundsStateCopyWith<SelectSoundsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectSoundsStateCopyWith<$Res> {
  factory $SelectSoundsStateCopyWith(
          SelectSoundsState value, $Res Function(SelectSoundsState) then) =
      _$SelectSoundsStateCopyWithImpl<$Res>;
  $Res call(
      {Template template, List<SelectedSound?> sounds, bool isProcessing});

  $TemplateCopyWith<$Res> get template;
}

/// @nodoc
class _$SelectSoundsStateCopyWithImpl<$Res>
    implements $SelectSoundsStateCopyWith<$Res> {
  _$SelectSoundsStateCopyWithImpl(this._value, this._then);

  final SelectSoundsState _value;
  // ignore: unused_field
  final $Res Function(SelectSoundsState) _then;

  @override
  $Res call({
    Object? template = freezed,
    Object? sounds = freezed,
    Object? isProcessing = freezed,
  }) {
    return _then(_value.copyWith(
      template: template == freezed
          ? _value.template
          : template // ignore: cast_nullable_to_non_nullable
              as Template,
      sounds: sounds == freezed
          ? _value.sounds
          : sounds // ignore: cast_nullable_to_non_nullable
              as List<SelectedSound?>,
      isProcessing: isProcessing == freezed
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  @override
  $TemplateCopyWith<$Res> get template {
    return $TemplateCopyWith<$Res>(_value.template, (value) {
      return _then(_value.copyWith(template: value));
    });
  }
}

/// @nodoc
abstract class _$SelectSoundsStateCopyWith<$Res>
    implements $SelectSoundsStateCopyWith<$Res> {
  factory _$SelectSoundsStateCopyWith(
          _SelectSoundsState value, $Res Function(_SelectSoundsState) then) =
      __$SelectSoundsStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {Template template, List<SelectedSound?> sounds, bool isProcessing});

  @override
  $TemplateCopyWith<$Res> get template;
}

/// @nodoc
class __$SelectSoundsStateCopyWithImpl<$Res>
    extends _$SelectSoundsStateCopyWithImpl<$Res>
    implements _$SelectSoundsStateCopyWith<$Res> {
  __$SelectSoundsStateCopyWithImpl(
      _SelectSoundsState _value, $Res Function(_SelectSoundsState) _then)
      : super(_value, (v) => _then(v as _SelectSoundsState));

  @override
  _SelectSoundsState get _value => super._value as _SelectSoundsState;

  @override
  $Res call({
    Object? template = freezed,
    Object? sounds = freezed,
    Object? isProcessing = freezed,
  }) {
    return _then(_SelectSoundsState(
      template: template == freezed
          ? _value.template
          : template // ignore: cast_nullable_to_non_nullable
              as Template,
      sounds: sounds == freezed
          ? _value.sounds
          : sounds // ignore: cast_nullable_to_non_nullable
              as List<SelectedSound?>,
      isProcessing: isProcessing == freezed
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_SelectSoundsState implements _SelectSoundsState {
  const _$_SelectSoundsState(
      {required this.template,
      required this.sounds,
      this.isProcessing = false});

  @override
  final Template template;
  @override
  final List<SelectedSound?> sounds;
  @JsonKey()
  @override
  final bool isProcessing;

  @override
  String toString() {
    return 'SelectSoundsState(template: $template, sounds: $sounds, isProcessing: $isProcessing)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SelectSoundsState &&
            const DeepCollectionEquality().equals(other.template, template) &&
            const DeepCollectionEquality().equals(other.sounds, sounds) &&
            const DeepCollectionEquality()
                .equals(other.isProcessing, isProcessing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(template),
      const DeepCollectionEquality().hash(sounds),
      const DeepCollectionEquality().hash(isProcessing));

  @JsonKey(ignore: true)
  @override
  _$SelectSoundsStateCopyWith<_SelectSoundsState> get copyWith =>
      __$SelectSoundsStateCopyWithImpl<_SelectSoundsState>(this, _$identity);
}

abstract class _SelectSoundsState implements SelectSoundsState {
  const factory _SelectSoundsState(
      {required Template template,
      required List<SelectedSound?> sounds,
      bool isProcessing}) = _$_SelectSoundsState;

  @override
  Template get template;
  @override
  List<SelectedSound?> get sounds;
  @override
  bool get isProcessing;
  @override
  @JsonKey(ignore: true)
  _$SelectSoundsStateCopyWith<_SelectSoundsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
class _$SelectedSoundTearOff {
  const _$SelectedSoundTearOff();

  _SelectedSoundUploading uploading({required String localFileName}) {
    return _SelectedSoundUploading(
      localFileName: localFileName,
    );
  }

  _SelectedSoundUploaded uploaded(
      {required String localFileName, required String remoteFileName}) {
    return _SelectedSoundUploaded(
      localFileName: localFileName,
      remoteFileName: remoteFileName,
    );
  }
}

/// @nodoc
const $SelectedSound = _$SelectedSoundTearOff();

/// @nodoc
mixin _$SelectedSound {
  String get localFileName => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String localFileName) uploading,
    required TResult Function(String localFileName, String remoteFileName)
        uploaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectedSoundUploading value) uploading,
    required TResult Function(_SelectedSoundUploaded value) uploaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SelectedSoundCopyWith<SelectedSound> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedSoundCopyWith<$Res> {
  factory $SelectedSoundCopyWith(
          SelectedSound value, $Res Function(SelectedSound) then) =
      _$SelectedSoundCopyWithImpl<$Res>;
  $Res call({String localFileName});
}

/// @nodoc
class _$SelectedSoundCopyWithImpl<$Res>
    implements $SelectedSoundCopyWith<$Res> {
  _$SelectedSoundCopyWithImpl(this._value, this._then);

  final SelectedSound _value;
  // ignore: unused_field
  final $Res Function(SelectedSound) _then;

  @override
  $Res call({
    Object? localFileName = freezed,
  }) {
    return _then(_value.copyWith(
      localFileName: localFileName == freezed
          ? _value.localFileName
          : localFileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$SelectedSoundUploadingCopyWith<$Res>
    implements $SelectedSoundCopyWith<$Res> {
  factory _$SelectedSoundUploadingCopyWith(_SelectedSoundUploading value,
          $Res Function(_SelectedSoundUploading) then) =
      __$SelectedSoundUploadingCopyWithImpl<$Res>;
  @override
  $Res call({String localFileName});
}

/// @nodoc
class __$SelectedSoundUploadingCopyWithImpl<$Res>
    extends _$SelectedSoundCopyWithImpl<$Res>
    implements _$SelectedSoundUploadingCopyWith<$Res> {
  __$SelectedSoundUploadingCopyWithImpl(_SelectedSoundUploading _value,
      $Res Function(_SelectedSoundUploading) _then)
      : super(_value, (v) => _then(v as _SelectedSoundUploading));

  @override
  _SelectedSoundUploading get _value => super._value as _SelectedSoundUploading;

  @override
  $Res call({
    Object? localFileName = freezed,
  }) {
    return _then(_SelectedSoundUploading(
      localFileName: localFileName == freezed
          ? _value.localFileName
          : localFileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_SelectedSoundUploading implements _SelectedSoundUploading {
  const _$_SelectedSoundUploading({required this.localFileName});

  @override
  final String localFileName;

  @override
  String toString() {
    return 'SelectedSound.uploading(localFileName: $localFileName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SelectedSoundUploading &&
            const DeepCollectionEquality()
                .equals(other.localFileName, localFileName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(localFileName));

  @JsonKey(ignore: true)
  @override
  _$SelectedSoundUploadingCopyWith<_SelectedSoundUploading> get copyWith =>
      __$SelectedSoundUploadingCopyWithImpl<_SelectedSoundUploading>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String localFileName) uploading,
    required TResult Function(String localFileName, String remoteFileName)
        uploaded,
  }) {
    return uploading(localFileName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
  }) {
    return uploading?.call(localFileName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(localFileName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectedSoundUploading value) uploading,
    required TResult Function(_SelectedSoundUploaded value) uploaded,
  }) {
    return uploading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
  }) {
    return uploading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(this);
    }
    return orElse();
  }
}

abstract class _SelectedSoundUploading implements SelectedSound {
  const factory _SelectedSoundUploading({required String localFileName}) =
      _$_SelectedSoundUploading;

  @override
  String get localFileName;
  @override
  @JsonKey(ignore: true)
  _$SelectedSoundUploadingCopyWith<_SelectedSoundUploading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$SelectedSoundUploadedCopyWith<$Res>
    implements $SelectedSoundCopyWith<$Res> {
  factory _$SelectedSoundUploadedCopyWith(_SelectedSoundUploaded value,
          $Res Function(_SelectedSoundUploaded) then) =
      __$SelectedSoundUploadedCopyWithImpl<$Res>;
  @override
  $Res call({String localFileName, String remoteFileName});
}

/// @nodoc
class __$SelectedSoundUploadedCopyWithImpl<$Res>
    extends _$SelectedSoundCopyWithImpl<$Res>
    implements _$SelectedSoundUploadedCopyWith<$Res> {
  __$SelectedSoundUploadedCopyWithImpl(_SelectedSoundUploaded _value,
      $Res Function(_SelectedSoundUploaded) _then)
      : super(_value, (v) => _then(v as _SelectedSoundUploaded));

  @override
  _SelectedSoundUploaded get _value => super._value as _SelectedSoundUploaded;

  @override
  $Res call({
    Object? localFileName = freezed,
    Object? remoteFileName = freezed,
  }) {
    return _then(_SelectedSoundUploaded(
      localFileName: localFileName == freezed
          ? _value.localFileName
          : localFileName // ignore: cast_nullable_to_non_nullable
              as String,
      remoteFileName: remoteFileName == freezed
          ? _value.remoteFileName
          : remoteFileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_SelectedSoundUploaded implements _SelectedSoundUploaded {
  const _$_SelectedSoundUploaded(
      {required this.localFileName, required this.remoteFileName});

  @override
  final String localFileName;
  @override
  final String remoteFileName;

  @override
  String toString() {
    return 'SelectedSound.uploaded(localFileName: $localFileName, remoteFileName: $remoteFileName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SelectedSoundUploaded &&
            const DeepCollectionEquality()
                .equals(other.localFileName, localFileName) &&
            const DeepCollectionEquality()
                .equals(other.remoteFileName, remoteFileName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(localFileName),
      const DeepCollectionEquality().hash(remoteFileName));

  @JsonKey(ignore: true)
  @override
  _$SelectedSoundUploadedCopyWith<_SelectedSoundUploaded> get copyWith =>
      __$SelectedSoundUploadedCopyWithImpl<_SelectedSoundUploaded>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String localFileName) uploading,
    required TResult Function(String localFileName, String remoteFileName)
        uploaded,
  }) {
    return uploaded(localFileName, remoteFileName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
  }) {
    return uploaded?.call(localFileName, remoteFileName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String localFileName)? uploading,
    TResult Function(String localFileName, String remoteFileName)? uploaded,
    required TResult orElse(),
  }) {
    if (uploaded != null) {
      return uploaded(localFileName, remoteFileName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectedSoundUploading value) uploading,
    required TResult Function(_SelectedSoundUploaded value) uploaded,
  }) {
    return uploaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
  }) {
    return uploaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectedSoundUploading value)? uploading,
    TResult Function(_SelectedSoundUploaded value)? uploaded,
    required TResult orElse(),
  }) {
    if (uploaded != null) {
      return uploaded(this);
    }
    return orElse();
  }
}

abstract class _SelectedSoundUploaded implements SelectedSound {
  const factory _SelectedSoundUploaded(
      {required String localFileName,
      required String remoteFileName}) = _$_SelectedSoundUploaded;

  @override
  String get localFileName;
  String get remoteFileName;
  @override
  @JsonKey(ignore: true)
  _$SelectedSoundUploadedCopyWith<_SelectedSoundUploaded> get copyWith =>
      throw _privateConstructorUsedError;
}
