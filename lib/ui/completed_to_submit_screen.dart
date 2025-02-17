import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  CompletedToSubmitScreen({super.key});

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
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).setup(
      onClose: () async {
        Navigator.pop(context);
      },
      onCompleteImmediately: () async {
        final shouldShowJoinPremiumPlanScreen = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                AppLocalizations.of(context)!
                    .completePieceRightNowIsRestrictedDescription,
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

    final title = Text(
      AppLocalizations.of(context)!.generationOfPieceHasBegun,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final completeImmediatelyButton = _CompleteImmediatelyButton(
      onPressed: () =>
          ref.read(widget.viewModelProvider.notifier).onCompleteImmediately(),
    );

    final body = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 32,
          children: [
            const _Description(),
            completeImmediatelyButton,
            const ListeningMusicCatImage(),
          ],
        ),
      ),
    );

    final remainTimeMilliseconds = state.remainTimeMilliseconds;
    final Widget automaticallyClosePanel;
    if (remainTimeMilliseconds == null) {
      automaticallyClosePanel = const Row();
    } else {
      final remainTimeSeconds = (remainTimeMilliseconds / 1000).ceil();
      final automaticallyCloseText = Text(
        AppLocalizations.of(context)!
            .thisScreenWillBeClosedInNSeconds(remainTimeSeconds),
        style: Theme.of(context).textTheme.bodyMedium,
      );
      final remainTimeProgressRing = CircularProgressIndicator(
        value: remainTimeMilliseconds /
            CompletedToSubmitViewModel
                .waitingTimeToCloseAutomaticallyMilliseconds,
      );
      final stopButton = IconButton(
        onPressed: () => ref.read(widget.viewModelProvider.notifier).stop(),
        icon: Icon(
          Icons.stop,
          color: Theme.of(context).primaryColor,
        ),
      );
      automaticallyClosePanel = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: automaticallyCloseText,
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              remainTimeProgressRing,
              stopButton,
            ],
          ),
        ],
      );
    }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: title,
              ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: automaticallyClosePanel,
                ),
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
  const _Description();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    final text = isPremiumPlan == true
        ? AppLocalizations.of(context)!.waitALittleDescription
        : AppLocalizations.of(context)!.waitAFewMinutesDescription;
    return Text(
      text,
      textAlign: TextAlign.center,
    );
  }
}

class _CompleteImmediatelyButton extends ConsumerWidget {
  const _CompleteImmediatelyButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    return isPremiumPlan == true
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: onPressed,
            child: Text(AppLocalizations.of(context)!.completePieceRightNow),
          );
  }
}
