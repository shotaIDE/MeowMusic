import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/di/service_providers.dart';
import 'package:meow_music/data/service/auth_service.dart';

final registrationTokenProvider = FutureProvider((ref) async {
  // Gets a registration token each time the session is not null.
  await ref.watch(sessionStreamProvider.future);

  final pushNotificationService = ref.watch(pushNotificationServiceProvider);

  return pushNotificationService.registrationToken();
});

final ensureLoggedInActionProvider = FutureProvider((ref) async {
  // TODO(ide): 初期化が完了するまで待つ処理、ここに書くの微妙
  await ref.read(sessionProvider.notifier).setup();

  final session = ref.read(sessionProvider);
  if (session != null) {
    return;
  }

  await ref.read(authActionsProvider).signInAnonymously();
});
