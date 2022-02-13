import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/di/use_case_providers.dart';
import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/ui/completed_to_submit_screen.dart';
import 'package:meow_music/ui/model/player_choice.dart';
import 'package:meow_music/ui/select_sounds_state.dart';
import 'package:meow_music/ui/select_sounds_view_model.dart';
import 'package:meow_music/ui/select_template_screen.dart';

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
      '主役となる鳴き声を\n3つ設定しよう',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline5,
    );

    final template = state.template;
    final templateTile = ListTile(
      leading: const Icon(Icons.play_arrow_rounded),
      title: Text(template.template.name),
      onTap: () {},
    );
    final description = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'お手元で',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextSpan(
            text: 'トリミング',
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'した鳴き声を設定してください。',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );

    final trimmingButton =
        TextButton(onPressed: () {}, child: const Text('トリミングの方法を確認する'));

    final sounds = state.sounds;
    final soundsList = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];

        return sound.sound.when(
          none: (_) => ListTile(
            key: Key('reorderable_list_$index'),
            title: const Text(
              '鳴き声を設定する',
              style: TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSound(target: sound),
          ),
          uploading: (_, localFileName) => ListTile(
            key: Key('reorderable_list_$index'),
            leading: const Icon(Icons.drag_handle),
            title: Text(
              localFileName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const CircularProgressIndicator(),
          ),
          uploaded: (_, localFileName, remoteFileName) => ListTile(
            key: Key('reorderable_list_$index'),
            leading: const Icon(Icons.drag_handle),
            title: Text(
              localFileName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(widget.viewModel.notifier).delete(target: sound),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 0),
    );

    final body = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          templateTile,
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: description,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: trimmingButton,
          ),
          soundsList,
        ],
      ),
    );

    final footer = Container(
      alignment: Alignment.center,
      color: Theme.of(context).secondaryHeaderColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              onPressed: state.isAvailableSubmission ? _submit : null,
              child: const Text('製作を依頼する'),
            ),
          ),
        ),
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('STEP 2/2'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: title,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: body,
            ),
          ),
          footer,
        ],
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'm4a', 'mp3'],
    );

    if (result == null) {
      return;
    }

    final file = File(result.files.single.path!);

    await ref.read(widget.viewModel.notifier).upload(file, target: target);
  }

  Future<void> _submit() async {
    await ref.read(widget.viewModel.notifier).submit();

    if (!mounted) {
      return;
    }

    Navigator.popUntil(
      context,
      (route) => route.settings.name == SelectTemplateScreen.name,
    );
    await Navigator.pushReplacement<CompletedToSubmitScreen, void>(
      context,
      CompletedToSubmitScreen.route(),
    );
  }
}
