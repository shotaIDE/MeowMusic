import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meow_music/data/model/uploaded_media.dart';
import 'package:video_trimmer/video_trimmer.dart';

part 'trim_sound_for_detecting_state.freezed.dart';

@freezed
class TrimSoundForDetectingState with _$TrimSoundForDetectingState {
  const factory TrimSoundForDetectingState({
    required Trimmer trimmer,
    @Default(0.0) double startValue,
    @Default(0.0) double endValue,
    @Default(false) bool isPlaying,
    @Default(false) bool progressVisibility,
    @Default(false) bool isUploading,
  }) = _TrimSoundForDetectingState;
}

@freezed
class TrimSoundForDetectingResult with _$TrimSoundForDetectingResult {
  const factory TrimSoundForDetectingResult({
    required UploadedMedia uploaded,
    required String displayName,
    required String thumbnailLocalPath,
  }) = _TrimSoundForDetectingResult;
}
