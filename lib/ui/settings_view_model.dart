import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/model/delete_account_error.dart';
import 'package:my_pet_melody/data/model/result.dart';
import 'package:my_pet_melody/data/usecase/auth_use_case.dart';
import 'package:my_pet_melody/ui/settings_state.dart';

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel({
    required Ref ref,
  })  : _ref = ref,
        super(
          const SettingsState(),
        );

  final Ref _ref;

  Future<Result<void, DeleteAccountError>> deleteAccount() async {
    state = state.copyWith(isProcessingToDeleteAccount: true);

    final action = _ref.read(deleteAccountActionProvider);

    final result = await action();

    state = state.copyWith(isProcessingToDeleteAccount: false);

    return result;
  }
}
