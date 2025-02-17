import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/definitions/app_definitions.dart';
import 'package:my_pet_melody/data/model/piece.dart';
import 'package:my_pet_melody/data/model/template.dart';
import 'package:my_pet_melody/data/service/database_service.dart';
import 'package:my_pet_melody/data/service/in_app_purchase_service.dart';
import 'package:my_pet_melody/data/service/storage_service_firebase.dart';
import 'package:path/path.dart';

final templatesProvider = FutureProvider((ref) async {
  final templateDrafts = await ref.watch(templateDraftsProvider.future);
  final storageService = await ref.watch(storageServiceProvider.future);

  final converted = await Future.wait(
    templateDrafts.map((templateDraft) async {
      final musicUrl =
          await storageService.templateMusicUrl(id: templateDraft.id);
      final thumbnailUrl =
          await storageService.templateThumbnailUrl(id: templateDraft.id);

      return Template(
        id: templateDraft.id,
        name: templateDraft.name,
        publishedAt: templateDraft.publishedAt,
        musicUrl: musicUrl,
        thumbnailUrl: thumbnailUrl,
      );
    }),
  );

  return converted
      .sortedBy((template) => template.publishedAt)
      .reversed
      .toList();
});

final piecesProvider = FutureProvider(
  (ref) async {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);
    final pieceDrafts = await ref.watch(pieceDraftsProvider.future);
    final storageService = await ref.read(storageServiceProvider.future);

    final currentDateTime = DateTime.now();

    final converted = await Future.wait(
      pieceDrafts.map(
        (piece) => piece.map(
          generating: (piece) async {
            final thumbnailUrl =
                await storageService.generatingPieceThumbnailDownloadUrl(
              fileName: piece.thumbnailFileName,
            );

            return Piece.generating(
              id: piece.id,
              name: piece.name,
              submittedAt: piece.submittedAt,
              thumbnailUrl: thumbnailUrl,
            );
          },
          generated: (piece) async {
            final availableUntil = isPremiumPlan == true
                ? null
                : piece.generatedAt.add(const Duration(days: 3));

            final thumbnailUrl =
                await storageService.generatedPieceThumbnailDownloadUrl(
              fileName: piece.thumbnailFileName,
            );

            if (availableUntil != null &&
                currentDateTime.isAfter(availableUntil)) {
              return Piece.expired(
                id: piece.id,
                name: piece.name,
                generatedAt: piece.generatedAt,
                availableUntil: availableUntil,
                thumbnailUrl: thumbnailUrl,
              );
            }

            final movieUrl = await storageService.pieceMovieDownloadUrl(
              fileName: piece.movieFileName,
            );

            final movieExtension = extension(piece.movieFileName);

            return Piece.generated(
              id: piece.id,
              name: piece.name,
              generatedAt: piece.generatedAt,
              availableUntil: availableUntil,
              movieUrl: movieUrl,
              movieExtension: movieExtension,
              thumbnailUrl: thumbnailUrl,
            );
          },
        ),
      ),
    );

    final sorted = converted.nonNulls.sorted(
      (a, b) {
        final dateTimeA = a.map(
          generating: (generating) => generating.submittedAt,
          generated: (generated) => generated.generatedAt,
          expired: (expired) => expired.generatedAt,
        );

        final dateTimeB = b.map(
          generating: (generating) => generating.submittedAt,
          generated: (generated) => generated.generatedAt,
          expired: (expired) => expired.generatedAt,
        );

        return dateTimeB.compareTo(dateTimeA);
      },
    );

    if (sorted.length < maxPiecesOnPremiumPlan) {
      return sorted;
    }

    return sorted.sublist(0, maxPiecesOnPremiumPlan);
  },
);
