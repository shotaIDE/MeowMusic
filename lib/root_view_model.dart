import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/service/database_provider.dart';
import 'package:meow_music/data/usecase/auth_use_case.dart';
import 'package:meow_music/data/usecase/settings_use_case.dart';
import 'package:meow_music/root_state.dart';

class RootViewModel extends StateNotifier<RootState> {
  RootViewModel({
    required Reader reader,
    required Future<String?> registrationToken,
  }) : super(const RootState()) {
    _setup(reader: reader, registrationTokenFuture: registrationToken);
  }

  Future<void> _setup({
    required Reader reader,
    required Future<String?> registrationTokenFuture,
  }) async {
    await reader(ensureLoggedInActionProvider.future);

    final isOnboardingFinished =
        await reader(isOnboardingFinishedProvider).call();

    state = state.copyWith(shouldLaunchOnboarding: !isOnboardingFinished);

    final registrationToken = await registrationTokenFuture;
    if (registrationToken != null) {
      final sendRegistrationTokenIfNeededAction =
          await reader(sendRegistrationTokenIfNeededActionProvider.future);
      await sendRegistrationTokenIfNeededAction.call(registrationToken);
    }
  }
}
