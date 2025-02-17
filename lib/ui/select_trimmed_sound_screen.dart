import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/ui/component/choice_position_bar.dart';
import 'package:my_pet_melody/ui/component/circled_play_button.dart';
import 'package:my_pet_melody/ui/component/footer.dart';
import 'package:my_pet_melody/ui/component/primary_button.dart';
import 'package:my_pet_melody/ui/component/transparent_app_bar.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/join_premium_plan_screen.dart';
import 'package:my_pet_melody/ui/model/player_choice.dart';
import 'package:my_pet_melody/ui/select_trimmed_sound_state.dart';
import 'package:my_pet_melody/ui/select_trimmed_sound_view_model.dart';
import 'package:my_pet_melody/ui/set_piece_title_screen.dart';
import 'package:my_pet_melody/ui/trim_sound_for_generation_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

final selectTrimmedSoundViewModelProvider = StateNotifierProvider.autoDispose
    .family<SelectTrimmedSoundViewModel, SelectTrimmedSoundState,
        SelectTrimmedSoundArgs>(
  (ref, args) => SelectTrimmedSoundViewModel(
    ref: ref,
    args: args,
  ),
);

const _seekBarBorderWidth = 4.0;
const _seekBarHeight = 24.0;

class SelectTrimmedSoundScreen extends ConsumerStatefulWidget {
  SelectTrimmedSoundScreen({
    required SelectTrimmedSoundArgs args,
    super.key,
  }) : viewModelProvider = selectTrimmedSoundViewModelProvider(args);

  static const name = 'SelectTrimmedSoundScreen';

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;

  static MaterialPageRoute<SelectTrimmedSoundResult?> route({
    required SelectTrimmedSoundArgs args,
  }) =>
      MaterialPageRoute<SelectTrimmedSoundResult?>(
        builder: (_) => SelectTrimmedSoundScreen(args: args),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<SelectTrimmedSoundScreen> createState() =>
      _SelectTrimmedSoundState();
}

class _SelectTrimmedSoundState extends ConsumerState<SelectTrimmedSoundScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).setup(
      moveToTrimSoundForGenerationScreen: (args) async {
        if (!mounted) {
          return;
        }

        await Navigator.push(
          context,
          TrimSoundForGenerationScreen.route(args: args),
        );
      },
      displayTrimmingForGenerationIsRestricted: () async {
        if (!mounted) {
          return;
        }

        final shouldShowJoinPremiumPlanScreen = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                AppLocalizations.of(context)!
                    .manualTrimmingIsRestrictedDescription,
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.aboutPremiumPlan),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        );

        if (shouldShowJoinPremiumPlanScreen != true) {
          return;
        }

        if (!mounted) {
          return;
        }

        await Navigator.push<void>(context, JoinPremiumPlanScreen.route());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);

    if (state.choices.isEmpty) {
      return _UnavailableTrimmedSoundScreen(
        viewModelProvider: widget.viewModelProvider,
      );
    }

    return _SelectTrimmedSoundScreen(
      viewModelProvider: widget.viewModelProvider,
    );
  }
}

class _UnavailableTrimmedSoundScreen extends ConsumerStatefulWidget {
  const _UnavailableTrimmedSoundScreen({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;

  @override
  ConsumerState<_UnavailableTrimmedSoundScreen> createState() =>
      _UnavailableTrimmedSoundScreenState();
}

class _UnavailableTrimmedSoundScreenState
    extends ConsumerState<_UnavailableTrimmedSoundScreen> {
  @override
  Widget build(BuildContext context) {
    final title = Text(
      AppLocalizations.of(context)!.noMeowsWereFound,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final movieTile = _MovieTile(
      viewModelProvider: widget.viewModelProvider,
      thumbnailWidth: DisplayDefinition.thumbnailWidthSmall,
      thumbnailHeight: DisplayDefinition.thumbnailHeightSmall,
    );

    final noDesiredTrimmingDescription = Text(
      AppLocalizations.of(context)!.noMeowsWereFoundDescription,
      textAlign: TextAlign.center,
    );

    final trimManuallyButton = TextButton(
      onPressed: ref.read(widget.viewModelProvider.notifier).onTrimManually,
      child: Text(AppLocalizations.of(context)!.trimManually),
    );

    final body = SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom,
        left: DisplayDefinition.screenPaddingSmall,
        right: DisplayDefinition.screenPaddingSmall,
      ),
      child: Column(
        children: [
          movieTile,
          const SizedBox(height: 32),
          noDesiredTrimmingDescription,
          const SizedBox(height: 16),
          trimManuallyButton,
        ],
      ),
    );

    return Scaffold(
      appBar: transparentAppBar(
        context: context,
        titleText: AppLocalizations.of(context)!.step4Of5,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 32),
            title,
            const SizedBox(height: 16),
            Expanded(
              child: body,
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class _SelectTrimmedSoundScreen extends ConsumerStatefulWidget {
  const _SelectTrimmedSoundScreen({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;

  @override
  ConsumerState<_SelectTrimmedSoundScreen> createState() =>
      _SelectTrimmedSoundScreenState();
}

class _SelectTrimmedSoundScreenState
    extends ConsumerState<_SelectTrimmedSoundScreen> {
  @override
  Widget build(BuildContext context) {
    final choicesCount = ref.watch(
      widget.viewModelProvider.select((state) => state.choices.length),
    );
    final isUploading = ref.watch(
      widget.viewModelProvider.select((state) => state.isUploading),
    );
    final isAvailableGoNext = ref.watch(
      widget.viewModelProvider.select((state) => state.isAvailableGoNext),
    );
    final viewModel = ref.watch(widget.viewModelProvider.notifier);

    final title = Text(
      AppLocalizations.of(context)!.selectMeow,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final noDesiredTrimmingDescription = Text(
      AppLocalizations.of(context)!.selectMeowDescription,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    );

    final trimManuallyButton = TextButton(
      onPressed: ref.read(widget.viewModelProvider.notifier).onTrimManually,
      child: Text(AppLocalizations.of(context)!.trimManually),
    );

    final choicesPanel = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) => _ChoicePanel(
        viewModelProvider: widget.viewModelProvider,
        index: index,
        onPlay: viewModel.play,
        onStop: viewModel.stop,
        onSelect: viewModel.select,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: choicesCount,
    );

    final body = SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 8,
        left: DisplayDefinition.screenPaddingSmall,
        right: DisplayDefinition.screenPaddingSmall,
      ),
      child: Column(
        children: [
          noDesiredTrimmingDescription,
          const SizedBox(height: 16),
          trimManuallyButton,
          const SizedBox(height: 32),
          choicesPanel,
        ],
      ),
    );

    final footerButton = PrimaryButton(
      onPressed: isAvailableGoNext ? _onGoNext : null,
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
        titleText: AppLocalizations.of(context)!.step4Of5,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DisplayDefinition.screenPaddingSmall,
              ),
              child: title,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: body,
            ),
            footer,
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );

    return isUploading
        ? Stack(
            children: [
              scaffold,
              Container(
                alignment: Alignment.center,
                color: Colors.black.withAlpha(128),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.uploading,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                    const LinearProgressIndicator(),
                  ],
                ),
              ),
            ],
          )
        : scaffold;
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

class _MovieTile extends ConsumerWidget {
  const _MovieTile({
    required this.viewModelProvider,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final double thumbnailWidth;
  final double thumbnailHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName =
        ref.watch(viewModelProvider.select((state) => state.displayName));

    final thumbnail = _EquallyDividedThumbnail(
      viewModelProvider: viewModelProvider,
      index: 0,
      width: thumbnailWidth,
      height: thumbnailHeight,
    );
    final title = Text(
      displayName,
      style: Theme.of(context).textTheme.bodyMedium,
      overflow: TextOverflow.ellipsis,
    );
    final contents = Row(
      children: [
        thumbnail,
        const SizedBox(width: 16),
        Expanded(
          child: title,
        ),
        const SizedBox(width: 16),
      ],
    );

    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(
          DisplayDefinition.cornerRadiusSizeSmall,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              DisplayDefinition.cornerRadiusSizeSmall,
            ),
          ),
        ),
        child: contents,
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.viewModelProvider,
    required this.index,
    required this.onPlay,
    required this.onStop,
    required this.onSelect,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;
  final void Function({required PlayerChoiceTrimmedMovie choice}) onPlay;
  final void Function({required PlayerChoiceTrimmedMovie choice}) onStop;
  final void Function({required int index}) onSelect;

  @override
  Widget build(BuildContext context) {
    final detailsPanel = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _seekBarBorderWidth),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ChoiceThumbnail(
                          viewModelProvider: viewModelProvider,
                          index: index,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _PositionText(
                              viewModelProvider: viewModelProvider,
                              index: index,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _SeekBar(
            viewModelProvider: viewModelProvider,
            index: index,
          ),
        ),
      ],
    );

    final detailsPanelWithControls = Row(
      children: [
        _ChoiceRadioButton(
          viewModelProvider: viewModelProvider,
          index: index,
          onSelect: () => onSelect(index: index),
        ),
        const SizedBox(width: 8 - _seekBarBorderWidth),
        Expanded(
          child: detailsPanel,
        ),
        const SizedBox(width: 8 - _seekBarBorderWidth),
        _ChoicePlayButton(
          viewModelProvider: viewModelProvider,
          index: index,
          onPlay: onPlay,
          onStop: onStop,
        ),
      ],
    );

    final body = Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(
            left: 8 - _seekBarBorderWidth,
            right: 16,
          ),
          child: detailsPanelWithControls,
        ),
        const SizedBox(height: 8 - _seekBarBorderWidth),
        _PlayingIndicator(
          viewModelProvider: viewModelProvider,
          index: index,
        ),
      ],
    );

    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(
          DisplayDefinition.cornerRadiusSizeSmall,
        ),
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            DisplayDefinition.cornerRadiusSizeSmall,
          ),
        ),
        child: InkWell(
          onTap: () => onSelect(index: index),
          child: body,
        ),
      ),
    );
  }
}

class _ChoiceRadioButton extends ConsumerWidget {
  const _ChoiceRadioButton({
    required this.viewModelProvider,
    required this.index,
    required this.onSelect,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(
      viewModelProvider.select((state) => state.selectedIndex),
    );

    return Semantics(
      label: AppLocalizations.of(context)!.selectNThMeow(index),
      child: Radio<int?>(
        value: selectedIndex,
        groupValue: index,
        onChanged: (_) => onSelect(),
      ),
    );
  }
}

class _ChoiceThumbnail extends ConsumerWidget {
  const _ChoiceThumbnail({
    required this.viewModelProvider,
    required this.index,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(
      viewModelProvider.select((state) => state.choices[index]),
    );

    return _Thumbnail(
      path: choice.thumbnailPath,
      width: DisplayDefinition.thumbnailWidthLarge,
      height: DisplayDefinition.thumbnailHeightLarge,
    );
  }
}

class _PositionText extends ConsumerWidget {
  const _PositionText({
    required this.viewModelProvider,
    required this.index,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startMilliseconds = ref.watch(
      viewModelProvider
          .select((state) => state.choices[index].segment.startMilliseconds),
    );
    final endMilliseconds = ref.watch(
      viewModelProvider
          .select((state) => state.choices[index].segment.endMilliseconds),
    );
    final durationMilliseconds = endMilliseconds - startMilliseconds;
    final durationSeconds = durationMilliseconds / 1000;

    final indexText = Text(
      AppLocalizations.of(context)!.numberN(index + 1),
      style: Theme.of(context).textTheme.bodyMedium,
    );
    final durationSecondsString = durationSeconds.toStringAsFixed(3);
    final durationText = Text(
      AppLocalizations.of(context)!.nSeconds(durationSecondsString),
      style: Theme.of(context).textTheme.bodySmall,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        indexText,
        durationText,
      ],
    );
  }
}

class _PlayingIndicator extends ConsumerWidget {
  const _PlayingIndicator({
    required this.viewModelProvider,
    required this.index,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      viewModelProvider.select((state) => state.choices[index].status),
    );

    return ChoicePositionBar(status: status);
  }
}

class _SeekBar extends ConsumerWidget {
  const _SeekBar({
    required this.viewModelProvider,
    required this.index,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationMilliseconds = ref.watch(
      viewModelProvider.select((state) => state.durationMilliseconds),
    );
    final startMilliseconds = ref.watch(
      viewModelProvider
          .select((state) => state.choices[index].segment.startMilliseconds),
    );
    final endMilliseconds = ref.watch(
      viewModelProvider
          .select((state) => state.choices[index].segment.endMilliseconds),
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(_seekBarBorderWidth),
          child: _SeekBarBackgroundLayer(
            viewModelProvider: viewModelProvider,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints.expand(
            height: _seekBarHeight + _seekBarBorderWidth * 2,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final seekBarWidth =
                  constraints.maxWidth - _seekBarBorderWidth * 2;
              final startRatio = startMilliseconds / durationMilliseconds;
              final endRatio = endMilliseconds / durationMilliseconds;
              final positionX1 =
                  seekBarWidth * startRatio + _seekBarBorderWidth;
              final positionX2 = seekBarWidth * endRatio + _seekBarBorderWidth;

              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: _seekBarBorderWidth,
                    ),
                    width: positionX1 - _seekBarBorderWidth,
                    color: Colors.white.withAlpha(128),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: positionX2,
                    ),
                    width: constraints.maxWidth -
                        (positionX2 + _seekBarBorderWidth),
                    color: Colors.white.withAlpha(128),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: positionX1 - 4),
                    width: positionX2 - positionX1 + 8,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orangeAccent,
                        width: _seekBarBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SeekBarBackgroundLayer extends ConsumerWidget {
  const _SeekBarBackgroundLayer({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equallyDividedCount = ref.watch(
      viewModelProvider
          .select((state) => state.equallyDividedThumbnailPaths.length),
    );

    return SizedBox(
      height: _seekBarHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final equallyDividedWidth = width ~/ equallyDividedCount;
          final thumbnailWidth =
              constraints.maxHeight * DisplayDefinition.aspectRatio;
          final thumbnailCountShouldBeDisplayed =
              (width / thumbnailWidth).ceil();
          final thumbnails =
              List.generate(thumbnailCountShouldBeDisplayed, (index) {
            final positionX = index * thumbnailWidth;
            final imageIndex = min(
              positionX ~/ equallyDividedWidth,
              DisplayDefinition.equallyDividedCount - 1,
            );

            final thumbnailBody = _EquallyDividedThumbnail(
              viewModelProvider: viewModelProvider,
              index: imageIndex,
              width: thumbnailWidth,
              height: _seekBarHeight,
            );

            return Padding(
              padding: EdgeInsets.only(left: positionX),
              child: thumbnailBody,
            );
          });

          return ClipRect(
            child: Stack(
              children: thumbnails,
            ),
          );
        },
      ),
    );
  }
}

class _ChoicePlayButton extends ConsumerWidget {
  const _ChoicePlayButton({
    required this.viewModelProvider,
    required this.index,
    required this.onPlay,
    required this.onStop,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;
  final void Function({required PlayerChoiceTrimmedMovie choice}) onPlay;
  final void Function({required PlayerChoiceTrimmedMovie choice}) onStop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(
      viewModelProvider.select((state) => state.choices[index]),
    );

    return CircledPlayButton(
      status: choice.status,
      onPressedWhenStop: () => onPlay(choice: choice),
      onPressedWhenPlaying: () => onStop(choice: choice),
    );
  }
}

class _EquallyDividedThumbnail extends ConsumerWidget {
  const _EquallyDividedThumbnail({
    required this.viewModelProvider,
    required this.index,
    required this.width,
    required this.height,
  });

  final AutoDisposeStateNotifierProvider<SelectTrimmedSoundViewModel,
      SelectTrimmedSoundState> viewModelProvider;
  final int index;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailPath = ref.watch(
      viewModelProvider
          .select((state) => state.equallyDividedThumbnailPaths[index]),
    );

    return _Thumbnail(
      path: thumbnailPath,
      width: width,
      height: height,
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.width,
    required this.height,
  });

  final String? path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final skeletonEnabled = path == null;
    final child = skeletonEnabled
        ? ColoredBox(
            color: Theme.of(context).primaryColor,
          )
        : Image.file(
            File(path!),
            fit: BoxFit.cover,
          );

    return Skeletonizer(
      enabled: skeletonEnabled,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
