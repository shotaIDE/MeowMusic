import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/model/detected_non_silent_segments.dart';
import 'package:meow_music/data/usecase/submission_use_case.dart';
import 'package:meow_music/ui/helper/audio_position_helper.dart';
import 'package:meow_music/ui/model/play_status.dart';
import 'package:meow_music/ui/model/player_choice.dart';
import 'package:meow_music/ui/select_trimmed_sound_state.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SelectTrimmedSoundViewModel
    extends StateNotifier<SelectTrimmedSoundState> {
  SelectTrimmedSoundViewModel({
    required SubmissionUseCase submissionUseCase,
    required SelectTrimmedSoundArgs args,
  })  : _submissionUseCase = submissionUseCase,
        _moviePath = args.soundPath,
        super(
          SelectTrimmedSoundState(
            fileName: basename(args.soundPath),
            choices: args.detected.list
                .mapIndexed(
                  (index, segment) => PlayerChoiceTrimmedMovie(
                    status: const PlayStatus.stop(),
                    index: index + 1,
                    path: args.soundPath,
                    segment: segment,
                  ),
                )
                .toList(),
            durationMilliseconds: args.detected.durationMilliseconds,
          ),
        );

  static const splitCount = 10;

  final SubmissionUseCase _submissionUseCase;
  final String _moviePath;
  final _player = AudioPlayer();

  NonSilentSegment? _currentPlayingSegment;
  StreamSubscription<Duration>? _audioPositionSubscription;
  StreamSubscription<void>? _audioStoppedSubscription;

  @override
  Future<void> dispose() async {
    final tasks = [
      _audioPositionSubscription?.cancel(),
      _audioStoppedSubscription?.cancel(),
    ].whereType<Future<void>>().toList();

    await Future.wait<void>(tasks);

    super.dispose();
  }

  Future<void> setup() async {
    _audioPositionSubscription =
        _player.onAudioPositionChanged.listen(_onAudioPositionReceived);

    _audioStoppedSubscription = _player.onPlayerCompletion.listen((_) {
      _onAudioFinished();
    });

    final startDateTime = DateTime.now();

    final outputDirectory = await getTemporaryDirectory();
    final outputParentPath = outputDirectory.path;

    final durationSeconds = state.durationMilliseconds / 1000;

    final segmentThumbnailPaths = state.choices.map((choice) {
      final paddedHash = '${choice.hashCode}'.padLeft(6, '0');
      final outputFileName = 'thumbnail_$paddedHash.png';
      return '$outputParentPath/$outputFileName';
    }).toList();

    final outputSegmentThumbnailsOption =
        state.choices.foldIndexed('', (index, previousOptions, choice) {
      final startSeconds = choice.segment.startMilliseconds / 1000;
      const outputFrameCount = 1;
      final outputPath = segmentThumbnailPaths[index];

      return '$previousOptions '
          '-ss $startSeconds '
          '-frames:v $outputFrameCount '
          '-f image2 '
          '-y '
          '$outputPath ';
    });

    final splitDurationSeconds = durationSeconds / splitCount;

    final splitThumbnailFilePaths = List.generate(splitCount, (index) {
      final paddedIndex = '$index'.padLeft(2, '0');
      final outputFileName = 'split_$paddedIndex.png';
      return '$outputParentPath/$outputFileName';
    });

    final outputSplitThumbnailsOption = splitThumbnailFilePaths.foldIndexed('',
        (index, previousOptions, outputPath) {
      final startSeconds = splitDurationSeconds * index;
      const outputFrameCount = 1;

      return '$previousOptions '
          '-ss $startSeconds '
          '-frames:v $outputFrameCount '
          '-f image2 '
          '-y '
          '$outputPath ';
    });

    await FFmpegKit.execute(
      '-i $_moviePath '
      '$outputSegmentThumbnailsOption '
      '$outputSplitThumbnailsOption',
    );

    state = state.copyWith(
      choices: state.choices
          .mapIndexed(
            (index, choice) => choice.copyWith(
              thumbnailPath: segmentThumbnailPaths[index],
            ),
          )
          .toList(),
      splitThumbnails: splitThumbnailFilePaths,
    );

    final endDateTime = DateTime.now();

    final elapsedDuration = endDateTime.difference(startDateTime);
    debugPrint('Running time to output thumbnails: $elapsedDuration');
  }

  String getLocalPathName() {
    return _moviePath;
  }

  Future<void> play({required PlayerChoiceTrimmedMovie choice}) async {
    final url = choice.uri;
    if (url == null) {
      return;
    }

    final choices = _getPlayerChoices();

    final stoppedList = PlayerChoiceConverter.getStoppedOrNull(
          originalList: choices,
        ) ??
        [...choices];

    final playingList = PlayerChoiceConverter.getTargetReplaced(
      originalList: stoppedList,
      targetId: choice.id,
      newPlayable:
          choice.copyWith(status: const PlayStatus.playing(position: 0)),
    );

    _currentPlayingSegment = choice.segment;

    _setPlayerChoices(playingList);

    await _player.play(
      url,
      position: Duration(milliseconds: choice.segment.startMilliseconds),
    );
  }

  Future<void> stop({required PlayerChoice choice}) async {
    final choices = _getPlayerChoices();

    final stoppedList = PlayerChoiceConverter.getTargetStopped(
      originalList: choices,
      targetId: choice.id,
    );

    _currentPlayingSegment = null;

    _setPlayerChoices(stoppedList);

    await _player.stop();
  }

  Future<SelectTrimmedSoundResult?> select({
    required PlayerChoiceTrimmedMovie choice,
  }) async {
    state = state.copyWith(isUploading: true);

    await FFmpegKit.cancel();

    final formattedStartPosition =
        AudioPositionHelper.generateFormattedPosition(
      choice.segment.startMilliseconds,
    );
    final formattedEndPosition = AudioPositionHelper.generateFormattedPosition(
      choice.segment.endMilliseconds,
    );

    final originalFileNameWithoutExtension =
        basenameWithoutExtension(_moviePath);
    final originalExtension = extension(_moviePath);

    final outputDirectory = await getTemporaryDirectory();
    final outputParentPath = outputDirectory.path;
    final outputFileName = '$originalFileNameWithoutExtension'
        '_detected${choice.id}'
        '$originalExtension';
    final outputPath = '$outputParentPath/$outputFileName';

    debugPrint(
      'Begin to trim from $formattedStartPosition to $formattedEndPosition.',
    );

    await FFmpegKit.execute(
      '-ss $formattedStartPosition '
      '-to $formattedEndPosition '
      '-i $_moviePath '
      '-y '
      '$outputPath',
    );

    final outputFile = File(outputPath);

    final uploadedSound = await _submissionUseCase.upload(
      outputFile,
      fileName: basename(outputFileName),
    );

    if (uploadedSound == null) {
      state = state.copyWith(isUploading: false);

      return null;
    }

    return SelectTrimmedSoundResult(
      uploaded: uploadedSound,
      label: '$originalFileNameWithoutExtension - セグメント${choice.id}',
    );
  }

  Future<void> _onAudioPositionReceived(Duration position) async {
    final segment = _currentPlayingSegment;
    if (segment == null) {
      return;
    }

    final duration = Duration(
      milliseconds: segment.endMilliseconds - segment.startMilliseconds,
    );
    final fixedPosition = Duration(
      milliseconds: position.inMilliseconds - segment.startMilliseconds,
    );

    if (fixedPosition > duration) {
      await _player.stop();

      _onAudioFinished();
      return;
    }

    final positionRatio = AudioPositionHelper.getPositionRatio(
      duration: duration,
      position: fixedPosition,
    );

    final choices = _getPlayerChoices();

    final positionUpdatedList = PlayerChoiceConverter.getPositionUpdatedOrNull(
      originalList: choices,
      position: positionRatio,
    );
    if (positionUpdatedList == null) {
      return;
    }

    _setPlayerChoices(positionUpdatedList);
  }

  void _onAudioFinished() {
    final choices = _getPlayerChoices();

    final stoppedList = PlayerChoiceConverter.getStoppedOrNull(
      originalList: choices,
    );
    if (stoppedList == null) {
      return;
    }

    _setPlayerChoices(stoppedList);
  }

  List<PlayerChoice> _getPlayerChoices() {
    return state.choices;
  }

  void _setPlayerChoices(List<PlayerChoice> choices) {
    state = state.copyWith(
      choices:
          choices.map((choice) => choice as PlayerChoiceTrimmedMovie).toList(),
    );
  }
}
