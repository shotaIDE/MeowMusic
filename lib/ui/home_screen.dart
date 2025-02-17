import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pet_melody/data/usecase/auth_use_case.dart';
import 'package:my_pet_melody/ui/component/fetched_thumbnail.dart';
import 'package:my_pet_melody/ui/component/lying_down_cat_image.dart';
import 'package:my_pet_melody/ui/component/profile_icon.dart';
import 'package:my_pet_melody/ui/definition/display_definition.dart';
import 'package:my_pet_melody/ui/home_state.dart';
import 'package:my_pet_melody/ui/home_view_model.dart';
import 'package:my_pet_melody/ui/join_premium_plan_screen.dart';
import 'package:my_pet_melody/ui/select_template_screen.dart';
import 'package:my_pet_melody/ui/settings_screen.dart';
import 'package:my_pet_melody/ui/video_screen.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(
    ref: ref,
    listener: ref.listen,
  ),
);

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({
    super.key,
  });

  static const name = 'HomeScreen';

  final viewModelProvider = homeViewModelProvider;

  static MaterialPageRoute<HomeScreen> route() => MaterialPageRoute<HomeScreen>(
        builder: (_) => HomeScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(widget.viewModelProvider.notifier).registerListener(
      moveToSelectTemplateScreen: () async {
        if (!mounted) {
          return;
        }

        await Navigator.push<void>(context, SelectTemplateScreen.route());
      },
      displayMakingPieceIsRestricted: () async {
        if (!mounted) {
          return;
        }

        final shouldShowJoinPremiumPlanScreen = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                AppLocalizations.of(context)!
                    .accessiblePiecesCountReachedTheMaxErrorDescription,
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.aboutPremiumPlan),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        );

        if (shouldShowJoinPremiumPlanScreen != true) {
          return;
        }

        if (!mounted) {
          return;
        }

        await Navigator.push<void>(context, JoinPremiumPlanScreen.route());
      },
      confirmToMakePieceWithWarnings: () async {
        if (!mounted) {
          return null;
        }

        return showDialog<ConfirmToMakePieceResult>(
          context: context,
          builder: (context) {
            var requestedDoNotShowAgain = false;

            final text = Text(
              AppLocalizations.of(context)!
                  .accessiblePiecesCountReachedTheMaxWarningDescription,
            );

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      text,
                      CheckboxListTile(
                        value: requestedDoNotShowAgain,
                        onChanged: (value) {
                          setState(() {
                            requestedDoNotShowAgain = value!;
                          });
                        },
                        title: Text(
                          AppLocalizations.of(context)!.doNotShowAgain,
                        ),
                      ),
                    ],
                  ),
                  contentPadding:
                      const EdgeInsets.only(top: 20, left: 24, right: 24),
                  actions: [
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.doContinue),
                      onPressed: () => Navigator.pop(
                        context,
                        ConfirmToMakePieceResult.continued(
                          requestedDoNotShowWarningsAgain:
                              requestedDoNotShowAgain,
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () => Navigator.pop(
                        context,
                        const ConfirmToMakePieceResult.canceled(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModelProvider);
    final pieces = state.pieces;
    final Widget body;
    if (pieces == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      final currentDateTime = DateTime.now();

      if (pieces.isNotEmpty) {
        body = ListView.separated(
          padding: const EdgeInsets.only(
            top: DisplayDefinition.screenPaddingSmall,
            bottom: LyingDownCatImage.height,
            left: DisplayDefinition.screenPaddingSmall,
            right: DisplayDefinition.screenPaddingSmall,
          ),
          itemBuilder: (_, index) {
            final playablePiece = pieces[index];

            final thumbnailImageUrl = playablePiece.piece.thumbnailUrl;
            final thumbnailImage = FetchedThumbnail(url: thumbnailImageUrl);

            final thumbnail = SizedBox(
              width: DisplayDefinition.thumbnailWidthLarge,
              height: DisplayDefinition.thumbnailHeightLarge,
              child: thumbnailImage,
            );

            final piece = playablePiece.piece;
            final foregroundColor = piece.map(
              generating: (_) => Theme.of(context).disabledColor,
              generated: (_) => null,
              expired: (_) => Theme.of(context).disabledColor,
            );
            final nameText = Text(
              piece.name,
              style: TextStyle(color: foregroundColor),
            );

            final detailsText = piece.map(
              generating: (generating) => Text(
                AppLocalizations.of(context)!.generating,
                style: TextStyle(color: foregroundColor),
              ),
              generated: (generated) {
                final availableUntil = generated.availableUntil;
                if (availableUntil == null) {
                  return null;
                }

                return _AvailableUntilText(
                  availableUntil: availableUntil,
                  current: currentDateTime,
                  defaultForegroundColor: foregroundColor,
                );
              },
              expired: (expired) {
                final availableUntil = expired.availableUntil;
                if (availableUntil == null) {
                  return null;
                }

                return _AvailableUntilText(
                  availableUntil: availableUntil,
                  current: currentDateTime,
                  defaultForegroundColor: foregroundColor,
                );
              },
            );
            final body = <Widget>[nameText];
            if (detailsText != null) {
              body.addAll([
                const SizedBox(height: 8),
                detailsText,
              ]);
            }

            final onTap = piece.map(
              generating: (_) => null,
              generated: (generatedPiece) => () => Navigator.push(
                    context,
                    VideoScreen.route(piece: generatedPiece),
                  ),
              expired: (_) => _showPieceIsExpiredDialog,
            );

            final borderColor = piece.map(
              generating: (_) => Theme.of(context).dividerColor,
              generated: (_) => Colors.transparent,
              expired: (_) => Theme.of(context).dividerColor,
            );
            final backgroundColor = piece.map(
              generating: (_) => Colors.transparent,
              generated: (_) => Theme.of(context).cardColor,
              expired: (_) => Colors.transparent,
            );

            return ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(
                  DisplayDefinition.cornerRadiusSizeSmall,
                ),
              ),
              child: Material(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(
                    DisplayDefinition.cornerRadiusSizeSmall,
                  ),
                ),
                child: InkWell(
                  onTap: onTap,
                  child: Row(
                    children: [
                      thumbnail,
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: body,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: pieces.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        );
      } else {
        body = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!.noPiecesDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).disabledColor),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.createdPieces,
        ),
        actions: [
          _SettingsButton(
            onPressed: () => Navigator.push(context, SettingsScreen.route()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: body,
                ),
                const Positioned(
                  bottom: 0,
                  left: 16,
                  child: LyingDownCatImage(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: AppLocalizations.of(context)!.createPiece,
        child: FloatingActionButton(
          onPressed: ref.read(widget.viewModelProvider.notifier).onMakePiece,
          child: const Icon(Icons.add),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future<void> _showPieceIsExpiredDialog() async {
    final shouldShowJoinPremiumPlanScreen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            AppLocalizations.of(context)!.pieceExpiredDescription,
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.aboutPremiumPlan),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldShowJoinPremiumPlanScreen != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.push<void>(context, JoinPremiumPlanScreen.route());
  }
}

class _SettingsButton extends ConsumerWidget {
  const _SettingsButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrl = ref.watch(profilePhotoUrlProvider);

    return IconButton(
      onPressed: onPressed,
      icon: ProfileIcon(photoUrl: photoUrl),
    );
  }
}

class _AvailableUntilText extends StatelessWidget {
  const _AvailableUntilText({
    required this.availableUntil,
    required this.current,
    required this.defaultForegroundColor,
  });

  final DateTime availableUntil;
  final DateTime current;
  final Color? defaultForegroundColor;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!
        .retentionPeriodFormat(availableUntil, availableUntil);
    final color = current.isAfter(
      availableUntil.add(const Duration(days: -1)),
    )
        ? Theme.of(context).colorScheme.error
        : defaultForegroundColor;

    return Text(
      text,
      style: TextStyle(color: color),
    );
  }
}
