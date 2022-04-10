import 'dart:io';

import 'package:meow_music/data/api/submission_api.dart';
import 'package:meow_music/data/definitions/app_definitions.dart';
import 'package:meow_music/data/model/detected_non_silent_segments.dart';
import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/data/model/uploaded_sound.dart';
import 'package:meow_music/data/repository/remote/submission_remote_data_source.dart';

class SubmissionRepository {
  SubmissionRepository({required SubmissionRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final SubmissionRemoteDataSource _remote;

  Future<List<Template>> getTemplates() async {
    return [
      const Template(
        id: 'happy_birthday',
        name: 'Happy Birthday',
        url:
            '${AppDefinitions.serverOrigin}/static/templates/happy_birthday.wav',
      ),
    ];
  }

  Future<DetectedNonSilentSegments?> detect(
    File file, {
    required String fileName,
  }) async {
    return _remote.detect(
      file,
      fileName: fileName,
    );
  }

  Future<UploadedSound?> upload(
    File file, {
    required String fileName,
  }) async {
    return _remote.upload(
      file,
      fileName: fileName,
    );
  }

  Future<FetchedPiece?> submit({
    required String userId,
    required String templateId,
    required List<UploadedSound> sounds,
  }) async {
    return _remote.submit(
      userId: userId,
      templateId: templateId,
      sounds: sounds,
    );
  }
}
