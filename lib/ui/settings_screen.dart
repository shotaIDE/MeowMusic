import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:my_pet_melody/data/definitions/app_definitions.dart';
import 'package:my_pet_melody/data/definitions/app_features.dart';
import 'package:my_pet_melody/data/model/profile.dart';
import 'package:my_pet_melody/data/service/app_service.dart';
import 'package:my_pet_melody/data/service/in_app_purchase_service.dart';
import 'package:my_pet_melody/data/usecase/auth_use_case.dart';
import 'package:my_pet_melody/root_view_model.dart';
import 'package:my_pet_melody/ui/component/is_premium_plan_text.dart';
import 'package:my_pet_melody/ui/component/profile_icon.dart';
import 'package:my_pet_melody/ui/component/rounded_settings_list_tile.dart';
import 'package:my_pet_melody/ui/debug_screen.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/definition/list_tile_position_in_group.dart';
import 'package:my_pet_melody/ui/join_premium_plan_screen.dart';
import 'package:my_pet_melody/ui/link_with_account_screen.dart';
import 'package:my_pet_melody/ui/settings_state.dart';
import 'package:my_pet_melody/ui/settings_view_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final _settingsViewModelProvider =
    StateNotifierProvider.autoDispose<SettingsViewModel, SettingsState>(
  (ref) => SettingsViewModel(ref: ref),
);

class SettingsScreen extends ConsumerStatefulWidget {
  SettingsScreen({
    super.key,
  });

  static const name = 'SettingsScreen';

  final viewModelProvider = _settingsViewModelProvider;

  static MaterialPageRoute<SettingsScreen> route() =>
      MaterialPageRoute<SettingsScreen>(
        builder: (_) => SettingsScreen(),
        settings: const RouteSettings(name: name),
        fullscreenDialog: true,
      );

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);

    final profileTile = _ProfileTile(
      onTapCreateAccountTile: () =>
          Navigator.push<void>(context, LinkWithAccountScreen.route()),
    );

    final currentPlanTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.currentPlan),
      trailing: const _IsPremiumPlanText(),
      positionInGroup: ListTilePositionInGroup.first,
    );
    final registerPremiumPlanTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.subscribeToPremiumPlan),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push<void>(context, JoinPremiumPlanScreen.route()),
      positionInGroup: ListTilePositionInGroup.last,
    );

    final writeReviewTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.writeReview),
      trailing: const Icon(Icons.open_in_browser),
      onTap: _writeReview,
      positionInGroup: ListTilePositionInGroup.first,
    );
    final shareWithFriendsTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.shareWithFriends),
      trailing: const Icon(Icons.open_in_browser),
      onTap: _shareWithFriends,
      positionInGroup: ListTilePositionInGroup.middle,
    );
    final termsOfServiceTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.termsOfUse),
      trailing: const Icon(Icons.open_in_browser),
      onTap: _openTermsOfService,
      positionInGroup: ListTilePositionInGroup.middle,
    );
    final privacyPolicyTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.privacyPolicy),
      trailing: const Icon(Icons.open_in_browser),
      onTap: _openPrivacyPolicy,
      positionInGroup: ListTilePositionInGroup.last,
    );

    final debugTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.debug),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, DebugScreen.route()),
      positionInGroup: ListTilePositionInGroup.first,
    );
    final versionTile = RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.version),
      trailing: const _FullVersionNameText(),
      positionInGroup: ListTilePositionInGroup.last,
    );

    final body = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).viewPadding.bottom,
          left: DisplayDefinition.screenPaddingSmall,
          right: DisplayDefinition.screenPaddingSmall,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            profileTile,
            const SizedBox(height: 32),
            currentPlanTile,
            registerPremiumPlanTile,
            const SizedBox(height: 32),
            writeReviewTile,
            shareWithFriendsTile,
            termsOfServiceTile,
            privacyPolicyTile,
            const SizedBox(height: 32),
            if (debugScreenAvailable) debugTile,
            versionTile,
            const SizedBox(height: 32),
            _DeleteAccountPanel(
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: body,
      ),
      resizeToAvoidBottomInset: false,
    );

    return state.isProcessingToDeleteAccount
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
                      AppLocalizations.of(context)!.deletingAccount,
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

  Future<void> _writeReview() async {
    // In-app reviews are limited to the number of times they can be
    // displayed, so go to Store and open the page to write a review.
    await InAppReview.instance.openStoreListing(appStoreId: appStoreId);
  }

  Future<void> _shareWithFriends() async {
    final storeUrl = Platform.isIOS
        ? 'https://apps.apple.com/us/app/うちのコメロディー/id6450181110'
        : 'https://play.google.com/store/apps/details?id=ide.shota.colomney.MyPetMelody';
    await Share.share(
      AppLocalizations.of(context)!.shareWithFriendsSentence(storeUrl),
    );
  }

  Future<void> _openTermsOfService() async {
    await launchUrl(
      Uri.parse(
        'https://tricolor-fright-c89.notion.site/8b169d10b790461ab72b961064e16c49',
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    await launchUrl(
      Uri.parse(
        'https://tricolor-fright-c89.notion.site/19903a30a07e4499887f37ee67fdf876',
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.deleteAccountDescription),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
    );

    if (shouldContinue == null || !shouldContinue) {
      return;
    }

    final result =
        await ref.read(widget.viewModelProvider.notifier).deleteAccount();

    await result.when(
      success: (_) async {
        await ref.read(rootViewModelProvider.notifier).restart();

        if (!mounted) {
          return;
        }

        Navigator.popUntil(context, (route) => route.isFirst);
      },
      failure: (error) => error.when(
        cancelledByUser: () {},
        unrecoverable: () async {
          final snackBar = SnackBar(
            content:
                Text(AppLocalizations.of(context)!.unknownErrorDescription),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      ),
    );
  }
}

class _IsPremiumPlanText extends ConsumerWidget {
  const _IsPremiumPlanText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);

    return IsPremiumPlanText(isPremiumPlan: isPremiumPlan);
  }
}

class _FullVersionNameText extends ConsumerWidget {
  const _FullVersionNameText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullVersionNameAsyncValue = ref.watch(fullVersionNameProvider);
    final fullVersionName = fullVersionNameAsyncValue.whenOrNull(
          data: (fullVersionName) => fullVersionName,
        ) ??
        '';
    return Text(fullVersionName);
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({
    required this.onTapCreateAccountTile,
  });

  final VoidCallback onTapCreateAccountTile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(nonAnonymousProfileProvider);
    return profile != null
        ? _LoggedInProfileTile(profile: profile)
        : _NotLoggedInTile(onTap: onTapCreateAccountTile);
  }
}

class _LoggedInProfileTile extends StatelessWidget {
  const _LoggedInProfileTile({
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photoUrl;
    final icon = ProfileIcon(photoUrl: photoUrl);

    final name = profile.name;
    final titleText = name ?? AppLocalizations.of(context)!.noNameLabel;

    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: icon,
      ),
      title: Text(titleText),
    );
  }
}

class _NotLoggedInTile extends StatelessWidget {
  const _NotLoggedInTile({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RoundedSettingsListTile(
      title: Text(AppLocalizations.of(context)!.createAccount),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DeleteAccountPanel extends ConsumerWidget {
  const _DeleteAccountPanel({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInNotAnonymouslyProvider);

    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    return RoundedSettingsListTile(
      title: Text(
        AppLocalizations.of(context)!.deleteAccount,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      onTap: onTap,
    );
  }
}
