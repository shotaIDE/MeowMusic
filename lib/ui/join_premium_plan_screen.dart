import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/definitions/app_definitions.dart';
import 'package:my_pet_melody/data/service/in_app_purchase_service.dart';
import 'package:my_pet_melody/data/usecase/purchase_use_case.dart';
import 'package:my_pet_melody/ui/component/rounded_and_chained_list_tile.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/definition/list_tile_position_in_group.dart';
import 'package:my_pet_melody/ui/join_premium_plan_state.dart';
import 'package:my_pet_melody/ui/join_premium_plan_view_model.dart';

final _joinPremiumPlanViewModelProvider = StateNotifierProvider.autoDispose<
    JoinPremiumPlanViewModel, JoinPremiumPlanState>(
  (ref) => JoinPremiumPlanViewModel(ref: ref),
);

class JoinPremiumPlanScreen extends ConsumerStatefulWidget {
  JoinPremiumPlanScreen({super.key});

  static const name = 'SetPieceTitleScreen';

  final viewModelProvider = _joinPremiumPlanViewModelProvider;

  static MaterialPageRoute<JoinPremiumPlanScreen> route() => MaterialPageRoute(
        builder: (_) => JoinPremiumPlanScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<JoinPremiumPlanScreen> createState() =>
      _JoinPremiumPlanScreenState();
}

class _JoinPremiumPlanScreenState extends ConsumerState<JoinPremiumPlanScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).registerListener(
      showCompletedJoiningPremiumPlan: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.youHaveJoinedPremiumPlan),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      showFailedJoiningPremiumPlan: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.unknownErrorDescription),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      showCompletedRestoring: () {
        final snackBar = SnackBar(
          content:
              Text(AppLocalizations.of(context)!.purchasedPlanHasBeenRestored),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      showFailedRestoring: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.unknownErrorDescription),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);

    const iconSize = 48.0;
    final largeStorageFeatureTile = _RoundedDescriptionListTile(
      leading: const Icon(
        Icons.cloud_done,
        size: iconSize,
      ),
      title: Text(AppLocalizations.of(context)!.largerCreationSpace),
      description: Text(
        AppLocalizations.of(context)!
            .largerCreationSpaceDescription(maxPiecesOnPremiumPlan),
      ),
      positionInGroup: ListTilePositionInGroup.first,
    );
    final rapidGenerationFeatureTile = _RoundedDescriptionListTile(
      leading: const Icon(
        Icons.hourglass_disabled,
        size: iconSize,
      ),
      title: Text(AppLocalizations.of(context)!.fasterGenerationSpeed),
      description:
          Text(AppLocalizations.of(context)!.fasterGenerationSpeedDescription),
      positionInGroup: ListTilePositionInGroup.middle,
    );
    final highQualityGenerationFeatureTile = _RoundedDescriptionListTile(
      leading: const Icon(
        Icons.music_video,
        size: iconSize,
      ),
      title: Text(AppLocalizations.of(context)!.higherCreationQuality),
      description:
          Text(AppLocalizations.of(context)!.higherCreationQualityDescription),
      positionInGroup: ListTilePositionInGroup.last,
    );

    final purchaseActionsPanel = _PurchaseActionsPanel(
      viewModelProvider: widget.viewModelProvider,
    );

    final restoreButton = TextButton(
      onPressed: ref.read(widget.viewModelProvider.notifier).restore,
      child: Text(AppLocalizations.of(context)!.restoreWhenChangedDevice),
    );

    final subscriptionDescription1Tile = _RoundedDescriptionListTile(
      title: Text(AppLocalizations.of(context)!.aboutAutomaticRecurringBilling),
      description: Text(
        AppLocalizations.of(context)!.aboutAutomaticRecurringBillingDescription,
      ),
      positionInGroup: ListTilePositionInGroup.first,
    );
    final subscriptionDescription2Tile = _RoundedDescriptionListTile(
      title: Text(AppLocalizations.of(context)!.confirmationAndCancellation),
      description: Text(
        Platform.isIOS
            ? AppLocalizations.of(context)!
                .confirmationAndCancellationDescriptionForIOS
            : AppLocalizations.of(context)!
                .confirmationAndCancellationDescriptionForAndroid,
      ),
      positionInGroup: ListTilePositionInGroup.middle,
    );
    final subscriptionDescription3Tile = _RoundedDescriptionListTile(
      title: Text(AppLocalizations.of(context)!.restorationWhenChangedDevice),
      description: Text(
        Platform.isIOS
            ? AppLocalizations.of(context)!
                .restorationWhenChangedDeviceDescriptionForIOS
            : AppLocalizations.of(context)!
                .restorationWhenChangedDeviceDescriptionForAndroid,
      ),
      positionInGroup: ListTilePositionInGroup.middle,
    );
    final subscriptionDescription4Tile = _RoundedDescriptionListTile(
      title: Text(AppLocalizations.of(context)!.pointsToNote),
      description: Text(
        Platform.isIOS
            ? AppLocalizations.of(context)!.pointsToNoteDescriptionForIOS
            : AppLocalizations.of(context)!.pointsToNoteDescriptionForAndroid,
      ),
      positionInGroup: ListTilePositionInGroup.last,
    );

    final body = SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom,
        left: DisplayDefinition.screenPaddingSmall,
        right: DisplayDefinition.screenPaddingSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          largeStorageFeatureTile,
          rapidGenerationFeatureTile,
          highQualityGenerationFeatureTile,
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: purchaseActionsPanel,
          ),
          const SizedBox(height: 16),
          restoreButton,
          const SizedBox(height: 32),
          subscriptionDescription1Tile,
          subscriptionDescription2Tile,
          subscriptionDescription3Tile,
          subscriptionDescription4Tile,
        ],
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.premiumPlan),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: body,
      ),
      resizeToAvoidBottomInset: false,
    );

    return state.isProcessing
        ? Stack(
            children: [
              scaffold,
              Container(
                alignment: Alignment.center,
                color: Colors.black.withAlpha(128),
                child: const LinearProgressIndicator(),
              ),
            ],
          )
        : scaffold;
  }
}

class _RoundedDescriptionListTile extends StatelessWidget {
  const _RoundedDescriptionListTile({
    required this.title,
    required this.description,
    this.leading,
    this.positionInGroup = ListTilePositionInGroup.only,
  });

  final Widget title;
  final Widget description;
  final Widget? leading;
  final ListTilePositionInGroup positionInGroup;

  @override
  Widget build(BuildContext context) {
    final titleAndDescription = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyMedium,
          child: title,
        ),
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall,
          child: description,
        ),
      ],
    );

    final bodyWidgets = <Widget>[];
    if (leading != null) {
      bodyWidgets.addAll([
        leading!,
        const SizedBox(width: 16),
      ]);
    }

    bodyWidgets.add(
      Expanded(
        child: titleAndDescription,
      ),
    );

    final body = Row(
      children: bodyWidgets,
    );

    return RoundedAndChainedListTile(
      positionInGroup: positionInGroup,
      child: body,
    );
  }
}

class _PurchaseActionsPanel extends ConsumerWidget {
  const _PurchaseActionsPanel({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<JoinPremiumPlanViewModel,
      JoinPremiumPlanState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    if (isPremiumPlan == null) {
      return const CircularProgressIndicator();
    }

    if (isPremiumPlan) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          Text(AppLocalizations.of(context)!.alreadyJoinedPremiumPlan),
          const SizedBox(width: 8),
        ],
      );
    }

    return _PurchaseButtonsPanel(viewModelProvider: viewModelProvider);
  }
}

class _PurchaseButtonsPanel extends ConsumerWidget {
  const _PurchaseButtonsPanel({
    required this.viewModelProvider,
  });

  final AutoDisposeStateNotifierProvider<JoinPremiumPlanViewModel,
      JoinPremiumPlanState> viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasableListValue = ref.watch(currentUserPurchasableListProvider);

    return purchasableListValue.when(
      data: (purchasableList) {
        if (purchasableList == null || purchasableList.isEmpty) {
          return const _NoAvailablePurchasableText();
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final purchasable = purchasableList[index];

            return _PurchasableButton(
              text: '${purchasable.title} : ${purchasable.price}',
              onPressed: () async {
                await ref
                    .read(viewModelProvider.notifier)
                    .joinPremiumPlan(purchasable: purchasable);
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 32),
          itemCount: purchasableList.length,
        );
      },
      loading: () {
        return const CircularProgressIndicator();
      },
      error: (_, __) {
        return const _NoAvailablePurchasableText();
      },
    );
  }
}

class _NoAvailablePurchasableText extends StatelessWidget {
  const _NoAvailablePurchasableText();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.noPurchasablePlanWasFound,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _PurchasableButton extends StatelessWidget {
  const _PurchasableButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                DisplayDefinition.cornerRadiusSizeLarge,
              ),
            ),
          ),
          textStyle: WidgetStateProperty.all<TextStyle>(
            Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 16,
                  // Specify a default text theme to apply the system font
                  // to allow the Japanese yen symbol to be displayed.
                  fontFamily: '',
                ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(text),
        ),
      ),
    );
  }
}
