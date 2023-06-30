import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/service/in_app_purchase_service.dart';
import 'package:my_pet_melody/ui/completed_to_submit_state.dart';
import 'package:my_pet_melody/ui/completed_to_submit_view_model.dart';
import 'package:my_pet_melody/ui/component/listening_music_cat_image.dart';
import 'package:my_pet_melody/ui/component/transparent_app_bar.dart';
import 'package:my_pet_melody/ui/join_premium_plan_screen.dart';

final completedToSubmitViewModelProvider = StateNotifierProvider.autoDispose<
    CompletedToSubmitViewModel, CompletedToSubmitState>(
  (_) => CompletedToSubmitViewModel(),
);

class CompletedToSubmitScreen extends ConsumerStatefulWidget {
  CompletedToSubmitScreen({Key? key}) : super(key: key);

  static const name = 'CompletedToSubmitScreen';

  final viewModelProvider = completedToSubmitViewModelProvider;

  static MaterialPageRoute<CompletedToSubmitScreen> route() =>
      MaterialPageRoute<CompletedToSubmitScreen>(
        builder: (_) => CompletedToSubmitScreen(),
        settings: const RouteSettings(name: name),
        fullscreenDialog: true,
      );

  @override
  ConsumerState<CompletedToSubmitScreen> createState() =>
      _SelectTemplateState();
}

class _SelectTemplateState extends ConsumerState<CompletedToSubmitScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);

    final title = Text(
      '作品の製作が\n開始されました',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final completeImmediatelyButton = _CompleteImmediatelyButton(
      onPressed: () async {
        final shouldShowJoinPremiumPlanScreen = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                '製作の待ち時間を減らすにはプレミアムプランに加入してください。',
              ),
              actions: [
                TextButton(
                  child: const Text('プレミアムプランとは'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        );

        if (shouldShowJoinPremiumPlanScreen != true || !mounted) {
          return;
        }

        await Navigator.push<void>(context, JoinPremiumPlanScreen.route());
      },
    );

    final body = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Description(),
            const SizedBox(height: 32),
            completeImmediatelyButton,
            const SizedBox(height: 32),
            const ListeningMusicCatImage(),
          ],
        ),
      ),
    );

    final remainTimeSeconds = state.remainTimeSeconds;
    final remainTimeSecondsInt = remainTimeSeconds.toInt();
    final automaticallyCloseText = Text(
      'この画面はあと$remainTimeSecondsInt秒で自動的に閉じます。',
      style: Theme.of(context).textTheme.bodyMedium,
    );
    final remainTimeProgressRing = CircularProgressIndicator(
      value: remainTimeSeconds /
          CompletedToSubmitViewModel.waitingTimeToCloseAutomaticallySeconds,
    );
    final stopButton = IconButton(
      onPressed: () {},
      icon: const Icon(Icons.stop),
    );
    final automaticallyClosePanel = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        automaticallyCloseText,
        const SizedBox(width: 16),
        Stack(
          children: [
            remainTimeProgressRing,
            stopButton,
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: transparentAppBar(
        context: context,
        titleText: '',
      ),
      body: Column(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: title,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: body,
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                automaticallyClosePanel,
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class _Description extends ConsumerWidget {
  const _Description({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    final text =
        isPremiumPlan == true ? '完成まで少し待ってね！' : '完成までしばらく待ってね！5分くらいかかるよ！';
    return Text(
      text,
      textAlign: TextAlign.center,
    );
  }
}

class _CompleteImmediatelyButton extends ConsumerWidget {
  const _CompleteImmediatelyButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    return isPremiumPlan == true
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: onPressed,
            child: const Text('いますぐ作品を完成させる'),
          );
  }
}
