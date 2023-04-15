import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/ui/select_trimmed_sound_screen.dart';
import 'package:meow_music/ui/select_trimmed_sound_state.dart';
import 'package:meow_music/ui/trim_sound_for_detecting_state.dart';
import 'package:meow_music/ui/trim_sound_for_detecting_view_model.dart';
import 'package:video_trimmer/video_trimmer.dart';

final _trimSoundForDetectingViewModelProvider = StateNotifierProvider
    .autoDispose
    .family<TrimSoundForDetectingViewModel, TrimSoundForDetectingState, String>(
  (ref, moviePath) => TrimSoundForDetectingViewModel(
    ref: ref,
    moviePath: moviePath,
  ),
);

class TrimSoundForDetectingScreen extends ConsumerStatefulWidget {
  TrimSoundForDetectingScreen({
    required String moviePath,
    Key? key,
  })  : viewModelProvider = _trimSoundForDetectingViewModelProvider(moviePath),
        super(key: key);

  static const name = 'TrimSoundForDetectingScreen';

  final AutoDisposeStateNotifierProvider<TrimSoundForDetectingViewModel,
      TrimSoundForDetectingState> viewModelProvider;

  static MaterialPageRoute<SelectTrimmedSoundResult?> route({
    required String moviePath,
  }) =>
      MaterialPageRoute<SelectTrimmedSoundResult?>(
        builder: (_) => TrimSoundForDetectingScreen(moviePath: moviePath),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<TrimSoundForDetectingScreen> createState() =>
      _TrimSoundForDetectingScreenState();
}

class _TrimSoundForDetectingScreenState
    extends ConsumerState<TrimSoundForDetectingScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).setup();
  }

  @override
  Widget build(BuildContext context) {
    final viewer = _VideoViewer(viewModelProvider: widget.viewModelProvider);

    final editor = _TrimEditor(viewModelProvider: widget.viewModelProvider);

    final playButton = IconButton(
      onPressed: ref.read(widget.viewModelProvider.notifier).onPlay,
      icon: _PlayControlButton(viewModelProvider: widget.viewModelProvider),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('鳴き声を切り取り'),
        actions: [
          IconButton(
            onPressed: _onComplete,
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 30),
        color: Colors.black,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constrains) {
              return Column(
                children: [
                  Expanded(
                    child: viewer,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: constrains.maxWidth,
                      child: editor,
                    ),
                  ),
                  playButton,
                ],
              );
            },
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );

    return _GrayMask(
      viewModelProvider: widget.viewModelProvider,
      child: scaffold,
    );
  }

  Future<void> _onComplete() async {
    final args = await ref.read(widget.viewModelProvider.notifier).onComplete();
    if (args == null || !mounted) {
      return;
    }

    final results = await Navigator.push(
      context,
      SelectTrimmedSoundScreen.route(args: args),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, results);
  }
}

class _VideoViewer extends ConsumerWidget {
  const _VideoViewer({
    required this.viewModelProvider,
    Key? key,
  }) : super(key: key);

  final AutoDisposeStateNotifierProvider<TrimSoundForDetectingViewModel,
      TrimSoundForDetectingState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmer =
        ref.watch(viewModelProvider.select((state) => state.trimmer));

    return VideoViewer(trimmer: trimmer);
  }
}

class _TrimEditor extends ConsumerWidget {
  const _TrimEditor({
    required this.viewModelProvider,
    Key? key,
  }) : super(key: key);

  final AutoDisposeStateNotifierProvider<TrimSoundForDetectingViewModel,
      TrimSoundForDetectingState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider.notifier);
    final trimmer =
        ref.watch(viewModelProvider.select((state) => state.trimmer));

    return LayoutBuilder(
      builder: (context, constraints) => TrimEditor(
        trimmer: trimmer,
        viewerWidth: constraints.maxWidth - 16,
        maxVideoLength: const Duration(minutes: 1),
        onChangeStart: viewModel.onUpdateStart,
        onChangeEnd: viewModel.onUpdateEnd,
        onChangePlaybackState: (isPlaying) =>
            viewModel.onUpdatePlaybackState(isPlaying: isPlaying),
      ),
    );
  }
}

class _PlayControlButton extends ConsumerWidget {
  const _PlayControlButton({
    required this.viewModelProvider,
    Key? key,
  }) : super(key: key);

  final AutoDisposeStateNotifierProvider<TrimSoundForDetectingViewModel,
      TrimSoundForDetectingState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying =
        ref.watch(viewModelProvider.select((state) => state.isPlaying));

    return isPlaying
        ? const Icon(
            Icons.pause,
            size: 64,
            color: Colors.white,
          )
        : const Icon(
            Icons.play_arrow,
            size: 64,
            color: Colors.white,
          );
  }
}

class _GrayMask extends ConsumerWidget {
  const _GrayMask({
    required this.viewModelProvider,
    required this.child,
    Key? key,
  }) : super(key: key);

  final AutoDisposeStateNotifierProvider<TrimSoundForDetectingViewModel,
      TrimSoundForDetectingState> viewModelProvider;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading =
        ref.watch(viewModelProvider.select((state) => state.isUploading));

    return Stack(
      children: [
        child,
        Visibility(
          visible: isUploading,
          child: Container(
            alignment: Alignment.center,
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'アップロードしています',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
