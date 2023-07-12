import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/model/piece.dart';
import 'package:my_pet_melody/ui/video_state.dart';
import 'package:video_player/video_player.dart';

class VideoViewModel extends StateNotifier<VideoState> {
  VideoViewModel({
    required PieceGenerated piece,
  })  : _uri = Uri.parse(piece.movieUrl),
        super(
          VideoState(title: piece.name),
        );

  final Uri _uri;

  late final VideoPlayerController _videoPlayerController;

  @override
  Future<void> dispose() async {
    await _videoPlayerController.dispose();
    state.controller?.dispose();

    super.dispose();
  }

  Future<void> setup() async {
    _videoPlayerController = VideoPlayerController.networkUrl(_uri);

    await _videoPlayerController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
    );

    state = state.copyWith(controller: chewieController);
  }
}
