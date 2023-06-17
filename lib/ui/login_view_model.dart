import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/model/login_error.dart';
import 'package:my_pet_melody/data/model/result.dart';
import 'package:my_pet_melody/data/service/auth_service.dart';
import 'package:my_pet_melody/data/usecase/auth_use_case.dart';
import 'package:my_pet_melody/ui/login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel({
    required Ref ref,
  })  : _ref = ref,
        super(const LoginState());

  final Ref _ref;

  Future<Result<void, LoginError>> loginWithTwitter() async {
    state = state.copyWith(isProcessing: true);

    final action = _ref.read(loginWithTwitterActionProvider);

    final result = await action();

    state = state.copyWith(isProcessing: false);

    return result;
  }

  Future<Result<void, LoginError>> loginWithFacebook() async {
    state = state.copyWith(isProcessing: true);

    final action = _ref.read(loginWithFacebookActionProvider);

    final result = await action();

    state = state.copyWith(isProcessing: false);

    return result;
  }

  Future<void> continueWithoutLoginButton() async {
    state = state.copyWith(isProcessing: true);

    await _ref.read(authActionsProvider).signInAnonymously();

    state = state.copyWith(isProcessing: false);
  }
}
