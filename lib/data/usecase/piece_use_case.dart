import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/di/service_providers.dart';
import 'package:my_pet_melody/data/model/piece.dart';
import 'package:my_pet_melody/data/model/template.dart';
import 'package:my_pet_melody/data/service/database_service.dart';
import 'package:my_pet_melody/data/service/in_app_purchase_service.dart';

final templatesProvider = FutureProvider((ref) async {
  final templateDrafts = await ref.watch(templateDraftsProvider.future);
  final storageService = await ref.watch(storageServiceProvider.future);

  return Future.wait(
    templateDrafts.map((templateDraft) async {
      final musicUrl =
          await storageService.templateMusicUrl(id: templateDraft.id);
      final thumbnailUrl =
          await storageService.templateThumbnailUrl(id: templateDraft.id);

      return Template(
        id: templateDraft.id,
        name: templateDraft.name,
        musicUrl: musicUrl,
        thumbnailUrl: thumbnailUrl,
      );
    }),
  );
});

final piecesProvider = FutureProvider(
  (ref) async {
    final isPremiumPlan = ref.watch(isPremiumPlanProvider);
    final pieceDrafts = await ref.watch(pieceDraftsProvider.future);
    final storageService = await ref.read(storageServiceProvider.future);

    final converted = await Future.wait(
      pieceDrafts.map(
        (piece) => piece.map(
          generating: (piece) async => Piece.generating(
            id: piece.id,
            name: piece.name,
            submittedAt: piece.submittedAt,
          ),
          generated: (piece) async {
            final movieUrl = await storageService.pieceMovieDownloadUrl(
              fileName: piece.movieFileName,
            );

            final thumbnailUrl = await storageService.pieceThumbnailDownloadUrl(
              fileName: piece.thumbnailFileName,
            );

            final availableUntil = isPremiumPlan == true
                ? null
                : piece.generatedAt.add(const Duration(days: 3));

            return Piece.generated(
              id: piece.id,
              name: piece.name,
              generatedAt: piece.generatedAt,
              availableUntil: availableUntil,
              movieUrl: movieUrl,
              thumbnailUrl: thumbnailUrl,
            );
          },
        ),
      ),
    );

    return converted.sorted(
      (a, b) {
        final dateTimeA = a.map(
          generating: (generating) => generating.submittedAt,
          generated: (generated) => generated.generatedAt,
        );

        final dateTimeB = b.map(
          generating: (generating) => generating.submittedAt,
          generated: (generated) => generated.generatedAt,
        );

        return dateTimeB.compareTo(dateTimeA);
      },
    );
  },
);
