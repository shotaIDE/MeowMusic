import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/ui/component/footer.dart';
import 'package:my_pet_melody/ui/component/primary_button.dart';
import 'package:my_pet_melody/ui/component/transparent_app_bar.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/select_trimmed_sound_state.dart';
import 'package:my_pet_melody/ui/set_piece_title_screen.dart';
import 'package:my_pet_melody/ui/trim_sound_for_generation_state.dart';
import 'package:my_pet_melody/ui/trim_sound_for_generation_view_model.dart';
import 'package:video_trimmer/video_trimmer.dart';

final _trimSoundForGenerationViewModelProvider =
    StateNotifierProvider.autoDispose.family<TrimSoundForGenerationViewModel,
        TrimSoundForGenerationState, TrimSoundForGenerationArgs>(
  (ref, args) => TrimSoundForGenerationViewModel(
    ref: ref,
    args: args,
  ),
);

class TrimSoundForGenerationScreen extends ConsumerStatefulWidget {
  TrimSoundForGenerationScreen({
    required TrimSoundForGenerationArgs args,
    super.key,
  }) : viewModelProvider = _trimSoundForGenerationViewModelProvider(args);

  static const name = 'TrimSoundForGenerationScreen';

  final AutoDisposeStateNotifierProvider<TrimSoundForGenerationViewModel,
      TrimSoundForGenerationState> viewModelProvider;

  static MaterialPageRoute<SelectTrimmedSoundResult?> route({
    required TrimSoundForGenerationArgs args,
  }) =>
      MaterialPageRoute<SelectTrimmedSoundResult?>(
        builder: (_) => TrimSoundForGenerationScreen(args: args),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<TrimSoundForGenerationScreen> createState() =>
      _TrimSoundForGenerationScreenState();
}

class _TrimSoundForGenerationScreenState
    extends ConsumerState<TrimSoundForGenerationScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).setup();
  }

  @override
  Widget build(BuildContext context) {
    final title = Text(
      AppLocalizations.of(context)!.trimMeow,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final description = Text(
      AppLocalizations.of(context)!.trimMeowDescription,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );

    final viewer = _VideoViewer(viewModelProvider: widget.viewModelProvider);

    final playControlPanel = GestureDetector(
      onTap: ref.read(widget.viewModelProvider.notifier).onPlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          viewer,
          _PlayControlButton(
            viewModelProvider: widget.viewModelProvider,
          ),
        ],
      ),
    );

    final editor = _TrimEditor(viewModelProvider: widget.viewModelProvider);

    final footerButton = PrimaryButton(
      onPressed: _onGoNext,
      text: AppLocalizations.of(context)!.goToNext,
    );
    final footerContent = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DisplayDefinition.actionButtonMaxWidth,
      ),
      child: footerButton,
    );
    final footer = Footer(child: footerContent);

    final scaffold = Scaffold(
      appBar: transparentAppBar(
        context: context,
        titleText: AppLocalizations.of(context)!.step4TrimmingOf5,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: title,
            ),
          ),
          const SizedBox(height: 32),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: description,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: playControlPanel,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: SafeArea(
              top: false,
              bottom: false,
              child: editor,
            ),
          ),
          const SizedBox(height: 24),
          footer,
        ],
      ),
      resizeToAvoidBottomInset: false,
    );

    return _GrayMask(
      viewModelProvider: widget.viewModelProvider,
      child: scaffold,
    );
  }

  Future<void> _onGoNext() async {
    final result = await ref.read(widget.viewModelProvider.notifier).onGoNext();
    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.push<void>(
      context,
      SetPieceTitleScreen.route(args: result),
    );
  }
}

class _VideoViewer extends ConsumerWidget {
  const _VideoViewer({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<TrimSoundForGenerationViewModel,
      TrimSoundForGenerationState> viewModelProvider;

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
  });

  final AutoDisposeStateNotifierProvider<TrimSoundForGenerationViewModel,
      TrimSoundForGenerationState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider.notifier);
    final trimmer =
        ref.watch(viewModelProvider.select((state) => state.trimmer));

    return LayoutBuilder(
      builder: (context, constraints) => TrimViewer(
        trimmer: trimmer,
        viewerWidth: constraints.maxWidth - 16,
        maxVideoLength: TrimSoundForGenerationViewModel.maxDurationToTrim,
        durationTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
        onChangeStart: viewModel.onUpdateStart,
        onChangeEnd: viewModel.onUpdateEnd,
        onChangePlaybackState: (isPlaying) =>
            viewModel.onUpdatePlaybackState(isPlaying: isPlaying),
        editorProperties: const TrimEditorProperties(
          circleSize: 8,
          circleSizeOnDrag: 10,
          borderWidth: 4,
          scrubberWidth: 2,
          circlePaintColor: Colors.orangeAccent,
          borderPaintColor: Colors.orangeAccent,
          scrubberPaintColor: Colors.orangeAccent,
        ),
      ),
    );
  }
}

class _PlayControlButton extends ConsumerWidget {
  const _PlayControlButton({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<TrimSoundForGenerationViewModel,
      TrimSoundForGenerationState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying =
        ref.watch(viewModelProvider.select((state) => state.isPlaying));

    return isPlaying
        ? const SizedBox.shrink()
        : const Icon(
            Icons.play_arrow,
            size: 48,
            color: Colors.white,
          );
  }
}

class _GrayMask extends ConsumerWidget {
  const _GrayMask({
    required this.viewModelProvider,
    required this.child,
  });

  final AutoDisposeStateNotifierProvider<TrimSoundForGenerationViewModel,
      TrimSoundForGenerationState> viewModelProvider;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final process =
        ref.watch(viewModelProvider.select((state) => state.process));

    final message = process != null ? _processLabel(process, context) : '';
    final messageText = Text(
      message,
      style:
          Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
    );

    return Stack(
      children: [
        child,
        Visibility(
          visible: process != null,
          child: Container(
            alignment: Alignment.center,
            color: Colors.black.withAlpha(128),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DisplayDefinition.screenPaddingSmall,
                  ),
                  child: messageText,
                ),
                const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _processLabel(
    TrimSoundForGenerationScreenProcess process,
    BuildContext context,
  ) {
    switch (process) {
      case TrimSoundForGenerationScreenProcess.convert:
        return AppLocalizations.of(context)!.convertingVideoDescription;

      case TrimSoundForGenerationScreenProcess.upload:
        return AppLocalizations.of(context)!.uploading;
    }
  }
}
