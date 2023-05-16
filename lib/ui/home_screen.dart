import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meow_music/data/model/piece.dart';
import 'package:meow_music/data/usecase/auth_use_case.dart';
import 'package:meow_music/ui/component/lying_down_cat_image.dart';
import 'package:meow_music/ui/component/profile_icon.dart';
import 'package:meow_music/ui/definition/display_definition.dart';
import 'package:meow_music/ui/home_state.dart';
import 'package:meow_music/ui/home_view_model.dart';
import 'package:meow_music/ui/select_template_screen.dart';
import 'package:meow_music/ui/settings_screen.dart';
import 'package:meow_music/ui/video_screen.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(
    listener: ref.listen,
  ),
);

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({
    Key? key,
  }) : super(key: key);

  static const name = 'HomeScreen';

  final viewModel = homeViewModelProvider;

  static MaterialPageRoute<HomeScreen> route() => MaterialPageRoute<HomeScreen>(
        builder: (_) => HomeScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.viewModel);
    final pieces = state.pieces;
    final Widget body;
    if (pieces == null) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (pieces.isNotEmpty) {
        body = ListView.separated(
          padding: const EdgeInsets.only(bottom: LyingDownCatImage.height),
          itemBuilder: (_, index) {
            final playablePiece = pieces[index];
            final playStatus = playablePiece.status;
            final thumbnail = playablePiece.piece.map(
              generating: (_) => Container(),
              generated: (generated) =>
                  Image.network(generated.thumbnailUrl, fit: BoxFit.fitWidth),
            );
            const thumbnailHeight = 74.0;
            final piece = playablePiece.piece;
            final dateFormatter = DateFormat.yMd('ja');
            final timeFormatter = DateFormat.Hm('ja');
            final subtitleLabel = piece.map(
              generating: (generating) =>
                  '${dateFormatter.format(generating.submittedAt)} '
                  '${timeFormatter.format(generating.submittedAt)}   '
                  '製作中',
              generated: (generated) =>
                  '${dateFormatter.format(generated.generatedAt)} '
                  '${timeFormatter.format(generated.generatedAt)}',
            );

            final onTap = piece.map(
              generating: (_) => null,
              generated: (generatedPiece) {
                return playStatus.when(
                  stop: () {
                    return () {
                      Navigator.push(
                        context,
                        VideoScreen.route(url: generatedPiece.movieUrl),
                      );
                    };
                  },
                  playing: (_) {
                    return () => ref
                        .read(widget.viewModel.notifier)
                        .stop(piece: playablePiece);
                  },
                );
              },
            );

            final leading = Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(
                  width: thumbnailHeight * DisplayDefinition.aspectRatio,
                  height: thumbnailHeight,
                  child: thumbnail,
                ),
                CircularProgressIndicator(
                  value: playStatus.when(
                    stop: () => 0,
                    playing: (position) => position,
                  ),
                ),
                playStatus.when(
                  stop: () => const Icon(Icons.play_arrow),
                  playing: (_) => const Icon(Icons.stop),
                ),
              ],
            );

            return GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(piece.name),
                          Text(subtitleLabel),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _share(piece: piece),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: pieces.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
        );
      } else {
        body = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'まだ作品を製作していません。\n右下の “+” ボタンから作品を製作しましょう。',
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

    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('つくった作品'),
        actions: [
          _SettingsButton(
            onPressed: () => Navigator.push(context, SettingsScreen.route()),
          )
        ],
      ),
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await ref.read(widget.viewModel.notifier).beforeHideScreen();

          if (!mounted) {
            return;
          }

          await Navigator.push<void>(context, SelectTemplateScreen.route());
        },
      ),
      resizeToAvoidBottomInset: false,
    );

    return state.isProcessing
        ? Stack(
            children: [
              scaffold,
              ColoredBox(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          )
        : scaffold;
  }

  void _share({required Piece piece}) {
    final generated = piece.mapOrNull(generated: (generated) => generated);
    if (generated == null) {
      return;
    }

    ref.read(widget.viewModel.notifier).share(piece: generated);
  }
}

class _SettingsButton extends ConsumerWidget {
  const _SettingsButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

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
