import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/ui/component/social_login_button.dart';
import 'package:my_pet_melody/ui/component/speaking_cat_image.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/home_screen.dart';
import 'package:my_pet_melody/ui/login_state.dart';
import 'package:my_pet_melody/ui/login_view_model.dart';

final _loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(
    ref: ref,
  ),
);

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({
    super.key,
  });

  static const name = 'LoginScreen';

  final viewModel = _loginViewModelProvider;

  static MaterialPageRoute<LoginScreen> route() =>
      MaterialPageRoute<LoginScreen>(
        builder: (_) => LoginScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<LoginScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModel);

    final isCreateMode = state.isCreateMode;

    final title = isCreateMode
        ? AppLocalizations.of(context)!.letsCreateAccount
        : AppLocalizations.of(context)!.letsLoginAccount;
    final titleText = Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );

    final description = isCreateMode
        ? AppLocalizations.of(context)!.accountCreationReasonDescription
        : AppLocalizations.of(context)!.accountLoginReasonDescription;
    final descriptionText = Text(
      description,
      textAlign: TextAlign.center,
    );

    final continueWithGoogleButton = ContinueWithGoogleButton(
      onPressed: _continueWithGoogle,
    );
    final continueWithAppleButton = ContinueWithAppleButton(
      onPressed: _continueWithApple,
    );
    final buttonsPanel = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DisplayDefinition.actionButtonMaxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          continueWithGoogleButton,
          continueWithAppleButton,
        ],
      ),
    );

    final toggleModeLabel = isCreateMode
        ? AppLocalizations.of(context)!.loginIfYouHaveAccount
        : AppLocalizations.of(context)!.createAccountIfYouHaveNoAccount;
    final toggleModelButton = TextButton(
      onPressed: () => ref.read(widget.viewModel.notifier).toggleMode(),
      child: Text(toggleModeLabel),
    );

    final continueWithoutLoginLabel = isCreateMode
        ? AppLocalizations.of(context)!.continueWithoutCreatingAccount
        : AppLocalizations.of(context)!.continueWithoutLogin;
    final continueWithoutLoginButton = TextButton(
      onPressed: _continueWithoutLoginButton,
      child: Text(continueWithoutLoginLabel),
    );

    final body = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: SpeakingCatImage.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            descriptionText,
            buttonsPanel,
            toggleModelButton,
            continueWithoutLoginButton,
          ],
        ),
      ),
    );

    final scaffold = Scaffold(
      body: Stack(
        children: [
          Column(
            spacing: 16,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: titleText,
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            right: 16,
            child: SpeakingCatImage(),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );

    return state.isProcessing
        ? Stack(
            children: [
              scaffold,
              ColoredBox(
                color: Colors.black.withAlpha(128),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          )
        : scaffold;
  }

  Future<void> _continueWithGoogle() async {
    final result =
        await ref.read(widget.viewModel.notifier).continueWithGoogle();

    await result.when(
      success: (_) async {
        await Navigator.pushReplacement<HomeScreen, void>(
          context,
          HomeScreen.route(),
        );
      },
      failure: (error) => error.mapOrNull(
        alreadyInUse: (_) async {
          final snackBar = SnackBar(
            content: Text(
              AppLocalizations.of(context)!
                  .googleAccountIsAlreadyUsedErrorDescription,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        unrecoverable: (_) async {
          final snackBar = SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unknownErrorDescription,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      ),
    );
  }

  Future<void> _continueWithApple() async {
    final result =
        await ref.read(widget.viewModel.notifier).continueWithApple();

    await result.when(
      success: (_) async {
        await Navigator.pushReplacement<HomeScreen, void>(
          context,
          HomeScreen.route(),
        );
      },
      failure: (error) => error.mapOrNull(
        alreadyInUse: (_) async {
          final snackBar = SnackBar(
            content: Text(
              AppLocalizations.of(context)!
                  .appleAccountIsAlreadyUsedErrorDescription,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        unrecoverable: (_) async {
          final snackBar = SnackBar(
            content:
                Text(AppLocalizations.of(context)!.unknownErrorDescription),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      ),
    );
  }

  Future<void> _continueWithoutLoginButton() async {
    await ref.read(widget.viewModel.notifier).continueWithoutLoginButton();

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacement<HomeScreen, void>(
      context,
      HomeScreen.route(),
    );
  }
}
