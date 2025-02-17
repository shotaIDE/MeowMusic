import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/ui/completed_to_submit_screen.dart';
import 'package:my_pet_melody/ui/component/footer.dart';
import 'package:my_pet_melody/ui/component/outlined_action_button.dart';
import 'package:my_pet_melody/ui/component/primary_button.dart';
import 'package:my_pet_melody/ui/component/transparent_app_bar.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/request_push_notification_permission_state.dart';
import 'package:my_pet_melody/ui/request_push_notification_permission_view_model.dart';
import 'package:my_pet_melody/ui/select_template_screen.dart';

final requestPushNotificationPermissionViewModelProvider =
    StateNotifierProvider.autoDispose.family<
        RequestPushNotificationPermissionViewModel,
        RequestPushNotificationPermissionState,
        RequestPushNotificationPermissionArgs>(
  (ref, args) => RequestPushNotificationPermissionViewModel(
    ref: ref,
    args: args,
  ),
);

class RequestPushNotificationPermissionScreen extends ConsumerStatefulWidget {
  RequestPushNotificationPermissionScreen({
    required RequestPushNotificationPermissionArgs args,
    super.key,
  }) : viewModel = requestPushNotificationPermissionViewModelProvider(args);

  static const name = 'RequestPushNotificationPermissionScreen';

  final AutoDisposeStateNotifierProvider<
      RequestPushNotificationPermissionViewModel,
      RequestPushNotificationPermissionState> viewModel;

  static MaterialPageRoute<RequestPushNotificationPermissionScreen> route({
    required RequestPushNotificationPermissionArgs args,
  }) =>
      MaterialPageRoute(
        builder: (_) => RequestPushNotificationPermissionScreen(args: args),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<RequestPushNotificationPermissionScreen> createState() =>
      _SelectTemplateState();
}

class _SelectTemplateState
    extends ConsumerState<RequestPushNotificationPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModel);

    final title = Text(
      AppLocalizations.of(context)!.allowPushNotification,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final description = Text(
      AppLocalizations.of(context)!.allowPushNotificationDescription,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );

    final notificationImage =
        Image.asset('assets/images/push_notification_banner.png');

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 32,
        children: [
          description,
          notificationImage,
        ],
      ),
    );

    final requestPermissionAndSubmitButton = PrimaryButton(
      text: AppLocalizations.of(context)!.allowAndGeneratePiece,
      onPressed: _requestPermissionAndSubmit,
    );
    final submitButton = OutlinedActionButton(
      onPressed: _submit,
      text: AppLocalizations.of(context)!.notAllowAndGeneratePiece,
    );
    final footerContent = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DisplayDefinition.actionButtonMaxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          requestPermissionAndSubmitButton,
          submitButton,
        ],
      ),
    );
    final footer = Footer(child: footerContent);

    final scaffold = Scaffold(
      appBar: transparentAppBar(
        context: context,
        titleText: AppLocalizations.of(context)!.preparationToGeneratePiece,
      ),
      body: Stack(
        children: [
          Column(
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
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: body,
                ),
              ),
              footer,
            ],
          ),
        ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.submitting,
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

  Future<void> _requestPermissionAndSubmit() async {
    await ref.read(widget.viewModel.notifier).requestPermissionAndSubmit();

    await _launchCompletedScreen();
  }

  Future<void> _submit() async {
    await ref.read(widget.viewModel.notifier).submit();

    await _launchCompletedScreen();
  }

  Future<void> _launchCompletedScreen() async {
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
