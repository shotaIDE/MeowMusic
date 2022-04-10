import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/definitions/app_definitions.dart';
import 'package:meow_music/data/di/use_case_providers.dart';
import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/data/model/uploaded_sound.dart';
import 'package:meow_music/ui/completed_to_submit_screen.dart';
import 'package:meow_music/ui/model/player_choice.dart';
import 'package:meow_music/ui/preparation_screen.dart';
import 'package:meow_music/ui/request_push_notification_permission_screen.dart';
import 'package:meow_music/ui/select_sounds_state.dart';
import 'package:meow_music/ui/select_sounds_view_model.dart';
import 'package:meow_music/ui/select_trimmed_sound_screen.dart';
import 'package:url_launcher/url_launcher.dart';

final selectSoundsViewModelProvider = StateNotifierProvider.autoDispose
    .family<SelectSoundsViewModel, SelectSoundsState, Template>(
  (ref, template) => SelectSoundsViewModel(
    selectedTemplate: template,
    submissionUseCase: ref.watch(submissionUseCaseProvider),
  ),
);

class SelectSoundsScreen extends ConsumerStatefulWidget {
  SelectSoundsScreen({required Template template, Key? key})
      : viewModel = selectSoundsViewModelProvider(template),
        super(key: key);

  static const name = 'SelectSoundsScreen';

  final AutoDisposeStateNotifierProvider<SelectSoundsViewModel,
      SelectSoundsState> viewModel;

  static MaterialPageRoute route({
    required Template template,
  }) =>
      MaterialPageRoute<SelectSoundsScreen>(
        builder: (_) => SelectSoundsScreen(template: template),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<SelectSoundsScreen> createState() => _SelectTemplateState();
}

class _SelectTemplateState extends ConsumerState<SelectSoundsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModel);

    final title = Text(
      '鳴き声を\n2つ設定しよう',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline5,
    );

    final template = state.template;
    final templateTile = ListTile(
      leading: template.status.map(
        stop: (_) => const Icon(Icons.play_arrow),
        playing: (_) => const Icon(Icons.stop),
      ),
      title: Text(template.template.name),
      tileColor: Colors.grey[300],
      onTap: template.status.map(
        stop: (_) =>
            () => ref.read(widget.viewModel.notifier).play(choice: template),
        playing: (_) =>
            () => ref.read(widget.viewModel.notifier).stop(choice: template),
      ),
    );
    final templateControl = Column(
      mainAxisSize: MainAxisSize.min,
      children: template.status.when(
        stop: () => [
          templateTile,
          const Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: LinearProgressIndicator(),
          ),
        ],
        playing: (position) => [
          templateTile,
          LinearProgressIndicator(
            value: position,
          )
        ],
      ),
    );

    final description = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'トリミング',
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'した鳴き声を2つ設定してね！',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );

    final trimmingButton = TextButton(
      onPressed: () => launch(AppDefinitions.trimmingPageUrl),
      child: const Text('トリミングの方法を確認する'),
    );

    final sounds = state.sounds;
    final soundsList = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];

        final leading = sound.status.map(
          stop: (_) => const Icon(Icons.play_arrow),
          playing: (_) => const Icon(Icons.stop),
        );

        final titleLabel = index == 0 ? '高めの鳴き声を設定する' : '低めの鳴き声を設定する';
        final tile = sound.sound.when(
          none: (_) => ListTile(
            leading: const Icon(Icons.source_rounded),
            title: Text(
              titleLabel,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSound(target: sound),
          ),
          uploading: (_, localFileName) => ListTile(
            leading: leading,
            title: Text(
              localFileName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const CircularProgressIndicator(),
          ),
          uploaded: (_, __, localFileName, remoteFileName) => ListTile(
            leading: leading,
            title: Text(
              localFileName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(widget.viewModel.notifier).delete(target: sound),
            ),
            onTap: sound.status.map(
              stop: (_) =>
                  () => ref.read(widget.viewModel.notifier).play(choice: sound),
              playing: (_) =>
                  () => ref.read(widget.viewModel.notifier).stop(choice: sound),
            ),
          ),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: sound.status.when(
            stop: () => [
              tile,
              const Visibility(
                visible: false,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: LinearProgressIndicator(),
              ),
            ],
            playing: (position) => [
              tile,
              LinearProgressIndicator(
                value: position,
              )
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 0),
    );

    final body = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 138),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          templateControl,
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
            child: description,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: trimmingButton,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: soundsList,
          ),
        ],
      ),
    );

    final isRequestStepExists = state.isRequestStepExists;
    final Widget footerContent;
    if (isRequestStepExists == null) {
      footerContent = const CircularProgressIndicator();
    } else {
      final ButtonStyleButton footerButton;
      if (isRequestStepExists) {
        footerButton = ElevatedButton(
          onPressed: state.isAvailableSubmission ? _showRequestScreen : null,
          child: const Text('依頼前の準備に進む'),
        );
      } else {
        footerButton = ElevatedButton(
          onPressed: state.isAvailableSubmission ? _submit : null,
          child: const Text('製作を依頼する'),
        );
      }

      footerContent = SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: footerButton,
      );
    }

    final catImage = Image.asset('assets/images/speaking_cat_eye_closed.png');

    final footer = Container(
      alignment: Alignment.center,
      color: Theme.of(context).secondaryHeaderColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: footerContent,
        ),
      ),
    );

    final scaffold = WillPopScope(
      onWillPop: () async {
        await ref.read(widget.viewModel.notifier).beforeHideScreen();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('STEP 2/2'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
              child: title,
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: body,
                  ),
                  Positioned(bottom: 0, right: 16, child: catImage),
                ],
              ),
            ),
            footer,
          ],
        ),
      ),
    );

    return state.isProcessing
        ? Stack(
            children: [
              scaffold,
              Container(
                alignment: Alignment.center,
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '提出しています',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(),
                    ),
                  ],
                ),
              )
            ],
          )
        : scaffold;
  }

  Future<void> _selectSound({required PlayerChoiceSound target}) async {
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (pickedFileResult == null) {
      return;
    }

    final pickedPlatformFile = pickedFileResult.files.single;
    final pickedPath = pickedPlatformFile.path!;
    final pickedFile = File(pickedPath);

    final selectTrimmedSoundArgs =
        await ref.read(widget.viewModel.notifier).detect(pickedFile);
    if (selectTrimmedSoundArgs == null || !mounted) {
      return;
    }

    final selectedTrimmedSound = await Navigator.push<UploadedSound?>(
      context,
      SelectTrimmedSoundScreen.route(
        args: selectTrimmedSoundArgs,
      ),
    );

    if (selectedTrimmedSound == null) {
      return;
    }

    await ref
        .read(widget.viewModel.notifier)
        .onSelectedTrimmedSound(selectedTrimmedSound, target: target);
  }

  Future<void> _showRequestScreen() async {
    final args = ref.read(widget.viewModel.notifier).getRequestPermissionArgs();

    await Navigator.push<void>(
      context,
      RequestPushNotificationPermissionScreen.route(args: args),
    );
  }

  Future<void> _submit() async {
    await ref.read(widget.viewModel.notifier).submit();

    if (!mounted) {
      return;
    }

    Navigator.popUntil(
      context,
      (route) => route.settings.name == PreparationScreen.name,
    );
    await Navigator.pushReplacement<CompletedToSubmitScreen, void>(
      context,
      CompletedToSubmitScreen.route(),
    );
  }
}
