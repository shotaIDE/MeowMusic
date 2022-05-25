import 'dart:async';
import 'dart:io';

import 'package:meow_music/data/model/detected_non_silent_segments.dart';
import 'package:meow_music/data/model/piece.dart';
import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/data/model/uploaded_sound.dart';
import 'package:meow_music/data/repository/piece_repository.dart';
import 'package:meow_music/data/repository/settings_repository.dart';
import 'package:meow_music/data/repository/submission_repository.dart';
import 'package:meow_music/data/service/auth_service.dart';
import 'package:meow_music/data/service/database_service.dart';
import 'package:meow_music/data/service/push_notification_service.dart';
import 'package:meow_music/data/service/storage_service.dart';

class SubmissionUseCase {
  SubmissionUseCase({
    required SubmissionRepository repository,
    required PieceRepository pieceRepository,
    required SettingsRepository settingsRepository,
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
    required PushNotificationService pushNotificationService,
  })  : _repository = repository,
        _pieceRepository = pieceRepository,
        _settingsRepository = settingsRepository,
        _authService = authService,
        _databaseService = databaseService,
        _storageService = storageService,
        _pushNotificationService = pushNotificationService;

  final SubmissionRepository _repository;
  final PieceRepository _pieceRepository;
  final SettingsRepository _settingsRepository;
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final PushNotificationService _pushNotificationService;

  Future<List<Template>> getTemplates() async {
    final templateDrafts = await _databaseService.getTemplates();

    return Future.wait(
      templateDrafts.map(
        (templateDraft) async {
          final url =
              await _storageService.getDownloadUrl(path: templateDraft.path);

          return Template(
            id: templateDraft.id,
            name: templateDraft.name,
            url: url,
          );
        },
      ),
    );
  }

  Future<DetectedNonSilentSegments?> detect(
    File file, {
    required String fileName,
  }) async {
    final token = await _authService.getCurrentUserIdTokenWhenLoggedIn();

    return _repository.detect(
      file,
      fileName: fileName,
      token: token,
    );
  }

  Future<UploadedSound?> upload(
    File file, {
    required String fileName,
  }) async {
    final userId = _authService.getCurrentUserIdWhenLoggedIn();

    return _storageService.upload(
      file,
      fileName: fileName,
      userId: userId,
    );
  }

  Future<bool> getShouldShowRequestPushNotificationPermission() async {
    if (Platform.isAndroid) {
      return false;
    }

    final hasRequestedPermission = await _settingsRepository
        .getHasRequestedPushNotificationPermissionAtLeastOnce();

    return !hasRequestedPermission;
  }

  Future<void> requestPushNotificationPermission() async {
    await _pushNotificationService.requestPermission();

    await _settingsRepository
        .setHasRequestedPushNotificationPermissionAtLeastOnce();
  }

  Future<void> submit({
    required Template template,
    required List<UploadedSound> sounds,
  }) async {
    final generated = await _repository.submit(
      userId: 'test-user-id',
      templateId: template.id,
      sounds: sounds,
    );

    if (generated == null) {
      return;
    }

    final generating = PieceGenerating(
      id: generated.id,
      name: template.name,
      submittedAt: DateTime.now(),
    );

    unawaited(
      _setTimerToNotifyCompletingToGenerate(
        generating: generating,
        path: generated.path,
      ),
    );
  }

  Future<void> _setTimerToNotifyCompletingToGenerate({
    required PieceGenerating generating,
    required String path,
  }) async {
    await _pieceRepository.add(generating);

    final url = await _storageService.getDownloadUrl(path: path);

    await Future<void>.delayed(const Duration(seconds: 5));

    final generated = PieceGenerated(
      id: generating.id,
      name: generating.name,
      generatedAt: DateTime.now(),
      url: url,
    );

    await _pieceRepository.replace(generated);

    await _pushNotificationService.showDummyNotification();
  }
}
