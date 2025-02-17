import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/ui/component/choice_position_bar.dart';
import 'package:my_pet_melody/ui/component/fetched_thumbnail.dart';
import 'package:my_pet_melody/ui/component/speaking_cat_image.dart';
import 'package:my_pet_melody/ui/component/transparent_app_bar.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/model/localized_template.dart';
import 'package:my_pet_melody/ui/select_sounds_state.dart';
import 'package:my_pet_melody/ui/select_sounds_view_model.dart';
import 'package:my_pet_melody/ui/trim_sound_for_detection_screen.dart';

final _selectSoundsViewModelProvider = StateNotifierProvider.autoDispose
    .family<SelectSoundsViewModel, SelectSoundsState, LocalizedTemplate>(
  (ref, template) => SelectSoundsViewModel(
    selectedTemplate: template,
  ),
);

class SelectSoundsScreen extends ConsumerStatefulWidget {
  SelectSoundsScreen({required LocalizedTemplate template, super.key})
      : viewModelProvider = _selectSoundsViewModelProvider(template);

  static const name = 'SelectSoundsScreen';

  final AutoDisposeStateNotifierProvider<SelectSoundsViewModel,
      SelectSoundsState> viewModelProvider;

  static MaterialPageRoute<SelectSoundsScreen> route({
    required LocalizedTemplate template,
  }) =>
      MaterialPageRoute(
        builder: (_) => SelectSoundsScreen(template: template),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<SelectSoundsScreen> createState() => _SelectTemplateState();
}

class _SelectTemplateState extends ConsumerState<SelectSoundsScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).registerListener(
      pickVideoFile: () async {
        final pickedFileResult = await FilePicker.platform.pickFiles(
          type: FileType.video,
        );
        return pickedFileResult?.files.single.path;
      },
      trimSoundForDetection: (args) {
        Navigator.push(
          context,
          TrimSoundForDetectionScreen.route(args: args),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);

    final title = Text(
      AppLocalizations.of(context)!.selectSound,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final template = state.template;
    final status = template.status;

    final icon = status.map(
      stop: (_) => Icons.play_arrow,
      loadingMedia: (_) => Icons.stop,
      playing: (_) => Icons.stop,
    );
    final thumbnailImage = SizedBox(
      width: DisplayDefinition.thumbnailWidthSmall,
      height: DisplayDefinition.thumbnailHeightSmall,
      child: FetchedThumbnail(
        url: template.template.thumbnailUrl,
      ),
    );
    final thumbnail = Stack(
      alignment: Alignment.center,
      children: [
        thumbnailImage,
        Icon(icon),
      ],
    );

    final templateName = Text(template.template.localizedName);

    final templatePositionBar = ChoicePositionBar(status: status);

    final onTapTemplate = status.map(
      stop: (_) => () =>
          ref.read(widget.viewModelProvider.notifier).play(choice: template),
      loadingMedia: (_) => () =>
          ref.read(widget.viewModelProvider.notifier).stop(choice: template),
      playing: (_) => () =>
          ref.read(widget.viewModelProvider.notifier).stop(choice: template),
    );

    final templateTile = ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(
          DisplayDefinition.cornerRadiusSizeSmall,
        ),
      ),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(
            DisplayDefinition.cornerRadiusSizeSmall,
          ),
        ),
        child: InkWell(
          onTap: onTapTemplate,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  thumbnail,
                  const SizedBox(width: 16),
                  Expanded(
                    child: templateName,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: templatePositionBar,
              ),
            ],
          ),
        ),
      ),
    );

    final description = Text(
      AppLocalizations.of(context)!.selectSoundDescription,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    );

    final soundsList = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        Future<void> onTap() =>
            ref.read(widget.viewModelProvider.notifier).onSelectSound();

        final label = Text(
          AppLocalizations.of(context)!.selectVideo,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).disabledColor),
          textAlign: TextAlign.center,
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
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
    );

    final body = SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: SpeakingCatImage.height,
        left: DisplayDefinition.screenPaddingSmall,
        right: DisplayDefinition.screenPaddingSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 32,
        children: [
          templateTile,
          description,
          soundsList,
        ],
      ),
    );

    final scaffold = PopScope(
      onPopInvokedWithResult: (_, __) {
        ref.read(widget.viewModelProvider.notifier).beforeHideScreen();
      },
      child: Scaffold(
        appBar: transparentAppBar(
          context: context,
          titleText: AppLocalizations.of(context)!.step2Of5,
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
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: body,
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 16,
                    child: SpeakingCatImage(),
                  ),
                ],
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
      ),
    );

    return state.isPicking
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
                      AppLocalizations.of(context)!.selectingVideo,
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
}
