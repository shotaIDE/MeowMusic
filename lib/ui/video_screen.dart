import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/logger/event_reporter.dart';
import 'package:my_pet_melody/data/model/piece.dart';
import 'package:my_pet_melody/ui/video_state.dart';
import 'package:my_pet_melody/ui/video_view_model.dart';

final _videoViewModelProvider = StateNotifierProvider.autoDispose
    .family<VideoViewModel, VideoState, PieceGenerated>(
  (ref, piece) {
    final eventReporter = ref.watch(eventReporterProvider);

    return VideoViewModel(
      piece: piece,
      eventReporter: eventReporter,
      ref: ref,
    );
  },
);

class VideoScreen extends ConsumerStatefulWidget {
  VideoScreen({
    required PieceGenerated piece,
    super.key,
  }) : viewModel = _videoViewModelProvider(piece);

  static const name = 'VideoScreen';

  final AutoDisposeStateNotifierProvider<VideoViewModel, VideoState> viewModel;

  static MaterialPageRoute<VideoScreen> route({
    required PieceGenerated piece,
  }) =>
      MaterialPageRoute<VideoScreen>(
        builder: (_) => VideoScreen(piece: piece),
        settings: const RouteSettings(name: name),
        fullscreenDialog: true,
      );

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModel.notifier).setup();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModel);

    final controller = state.controller;
    final body = controller == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Chewie(
            controller: controller,
          );

    final shareButton = IconButton(
      onPressed: () => ref.read(widget.viewModel.notifier).share(),
      icon: const Icon(Icons.share),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(state.title),
        actions: [
          shareButton,
        ],
      ),
      body: SafeArea(
        top: false,
        child: body,
      ),
      resizeToAvoidBottomInset: false,
    );

    return state.isProcessing
        ? Stack(
            children: [
              scaffold,
              ColoredBox(
                color: Colors.black.withAlpha(128),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          )
        : scaffold;
  }
}
