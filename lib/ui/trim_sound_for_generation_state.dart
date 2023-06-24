import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_pet_melody/data/model/template.dart';
import 'package:video_trimmer/video_trimmer.dart';

part 'trim_sound_for_generation_state.freezed.dart';

@freezed
class TrimSoundForGenerationState with _$TrimSoundForGenerationState {
  const factory TrimSoundForGenerationState({
    required Trimmer trimmer,
    @Default(0.0) double startValue,
    @Default(0.0) double endValue,
    @Default(false) bool isPlaying,
    @Default(false) bool isUploading,
  }) = _TrimSoundForGenerationState;
}

@freezed
class TrimSoundForGenerationArgs with _$TrimSoundForGenerationArgs {
  const factory TrimSoundForGenerationArgs({
    required Template template,
    required String displayName,
    required String soundPath,
  }) = _TrimSoundForGenerationArgs;
}
