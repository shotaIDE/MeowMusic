import 'package:meow_music/data/model/preference_key.dart';
import 'package:meow_music/data/service/preference_service.dart';

class SettingsLocalDataSource {
  Future<bool> getIsOnboardingFinished() async {
    final isFinished =
        await PreferenceService.getBool(PreferenceKey.isOnboardingFinished);

    return isFinished ?? false;
  }

  Future<void> setIsOnboardingFinished() async {
    await PreferenceService.setBool(
      PreferenceKey.isOnboardingFinished,
      value: true,
    );
  }

  Future<bool> getHasRequestedPushNotificationPermissionAtLeastOnce() async {
    final hasRequested = await PreferenceService.getBool(
      PreferenceKey.hasRequestedPushNotificationPermissionAtLeastOnce,
    );

    return hasRequested ?? false;
  }

  Future<void> setHasRequestedPushNotificationPermissionAtLeastOnce() async {
    await PreferenceService.setBool(
      PreferenceKey.hasRequestedPushNotificationPermissionAtLeastOnce,
      value: true,
    );
  }
}
