import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:meow_music/data/model/login_session.dart';
import 'package:meow_music/data/model/uploaded_media.dart';
import 'package:meow_music/data/service/storage_service.dart';
import 'package:path/path.dart';

class StorageServiceFirebase implements StorageService {
  StorageServiceFirebase({
    required LoginSession session,
  }) : _session = session;

  final format = DateFormat('yyyyMMddHHmmss');

  final LoginSession _session;

  @override
  Future<String> templateUrl({required String id}) async {
    final storageRef = FirebaseStorage.instance.ref();

    final pathRef = storageRef.child('systemMedia/templates/$id/template.wav');

    return pathRef.getDownloadURL();
  }

  @override
  Future<String> pieceMovieDownloadUrl({
    required String fileName,
  }) async {
    final userId = _session.userId;

    final storageRef = FirebaseStorage.instance.ref();

    final pathRef =
        storageRef.child('userMedia/$userId/generatedPieces/$fileName');

    return pathRef.getDownloadURL();
  }

  @override
  Future<String> pieceThumbnailDownloadUrl({
    required String fileName,
  }) async {
    final userId = _session.userId;

    final storageRef = FirebaseStorage.instance.ref();

    final pathRef =
        storageRef.child('userMedia/$userId/generatedThumbnail/$fileName');

    return pathRef.getDownloadURL();
  }

  @override
  Future<UploadedMedia?> uploadUnedited(
    File file, {
    required String fileName,
  }) async {
    final userId = _session.userId;

    final storageRef = FirebaseStorage.instance.ref();

    final current = DateTime.now();
    final uploadFileId = format.format(current);

    final fileExtension = extension(fileName);

    final path = '/userMedia/$userId/unedited/$uploadFileId$fileExtension';

    final pathRef = storageRef.child(path);

    try {
      await pathRef.putFile(file);
    } on FirebaseException catch (error) {
      if (error.code == 'unauthorized') {
        // ファイルサイズが制限よりも大きい
        return null;
      }

      rethrow;
    }

    final url = await pathRef.getDownloadURL();

    return UploadedMedia(id: uploadFileId, extension: fileExtension, url: url);
  }

  @override
  Future<UploadedMedia?> uploadEdited(
    File file, {
    required String fileName,
  }) async {
    final userId = _session.userId;

    final storageRef = FirebaseStorage.instance.ref();

    final current = DateTime.now();
    final uploadFileId = format.format(current);

    final fileExtension = extension(fileName);

    final path = '/userMedia/$userId/edited/$uploadFileId$fileExtension';

    final pathRef = storageRef.child(path);

    try {
      await pathRef.putFile(file);
    } on FirebaseException catch (error) {
      if (error.code == 'unauthorized') {
        // ファイルサイズが制限よりも大きい
        return null;
      }

      rethrow;
    }

    final url = await pathRef.getDownloadURL();

    return UploadedMedia(id: uploadFileId, extension: fileExtension, url: url);
  }
}
