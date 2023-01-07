import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/definitions/types.dart';
import 'package:meow_music/data/service/database_service.dart';
import 'package:meow_music/data/usecase/auth_use_case.dart';
import 'package:meow_music/data/usecase/settings_use_case.dart';
import 'package:meow_music/root_state.dart';

class RootViewModel extends StateNotifier<RootState> {
  RootViewModel({
    required Ref ref,
    required Listener listener,
  }) : super(const RootState()) {
    _setup(
      ref: ref,
      listener: listener,
    );
  }

  Future<void> _setup({
    required Ref ref,
    required Listener listener,
  }) async {
    await ref.read(ensureLoggedInActionProvider.future);

    final isOnboardingFinished =
        await ref.read(settingsActionsProvider).getIsOnboardingFinished();

    state = state.copyWith(shouldLaunchOnboarding: !isOnboardingFinished);

    listener<Future<String?>>(
      registrationTokenProvider.future,
      (_, next) async {
        final registrationToken = await next;
        if (registrationToken == null) {
          return;
        }

        final databaseActions = await ref.read(databaseActionsProvider.future);
        await databaseActions.sendRegistrationTokenIfNeeded(registrationToken);
      },
      fireImmediately: true,
    );
  }
}
