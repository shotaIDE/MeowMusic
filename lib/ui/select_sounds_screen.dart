import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/di/use_case_providers.dart';
import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/ui/completed_to_submit_screen.dart';
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
    final template = state.template;

    final title = Text(
      '鳴き声を3つ\n設定しよう',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline5,
    );

    final templateTile = ListTile(
      leading: const Icon(Icons.play_arrow_rounded),
      title: Text(template.name),
      onTap: () {},
    );
    final description = Text(
      'お手元でトリミングした鳴き声をアップロードしてください',
      style: Theme.of(context).textTheme.bodyText1,
    );
    final trimmingButton =
        TextButton(onPressed: () {}, child: const Text('トリミングの方法を見る'));

    final soundsList = ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        3,
        (index) => ListTile(
          key: Key('reorderable_list_$index'),
          leading: const Icon(Icons.drag_handle),
          title: const Text('鳴き声を選択する'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {},
          ),
          onTap: _selectSound,
        ),
      ),
      onReorder: (src, dst) {},
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
              onPressed: _submit,
              child: const Text('作品を提出する'),
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

  Future<void> _selectSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'm4a', 'mp3'],
    );

    if (result == null) {
      return;
    }

    final file = File(result.files.single.path!);

    await ref.read(widget.viewModel.notifier).upload(file);
  }

  Future<void> _submit() async {
    await ref.read(widget.viewModel.notifier).submit();
    return;

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
