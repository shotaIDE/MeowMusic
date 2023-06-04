import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/service/auth_service.dart';
import 'package:my_pet_melody/data/usecase/auth_use_case.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({
    Key? key,
  }) : super(key: key);

  static const name = 'DebugScreen';

  static MaterialPageRoute<DebugScreen> route() =>
      MaterialPageRoute<DebugScreen>(
        builder: (_) => const DebugScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final signOutTile = session != null
        ? ListTile(
            title: const Text('サインアウト'),
            onTap: ref.watch(signOutActionProvider),
          )
        : ListTile(
            title: const Text('サインイン'),
            onTap: ref.watch(signInActionProvider),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('デバッグ'),
      ),
      body: Column(
        children: [
          signOutTile,
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
