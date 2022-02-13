import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_music/data/model/piece.dart';
import 'package:meow_music/data/usecase/piece_use_case.dart';
import 'package:meow_music/ui/home_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel({
    required PieceUseCase pieceUseCase,
  })  : _pieceUseCase = pieceUseCase,
        super(const HomeState()) {
    _setup();
  }

  final PieceUseCase _pieceUseCase;
  final _player = AudioPlayer();

  Duration? _currentAudioLength;
  StreamSubscription<List<Piece>>? _piecesSubscription;
  StreamSubscription<Duration>? _audioLengthSubscription;
  StreamSubscription<Duration>? _audioPositionSubscription;
  StreamSubscription<void>? _audioStoppedSubscription;

  @override
  Future<void> dispose() async {
    final tasks = [
      _piecesSubscription?.cancel(),
      _audioLengthSubscription?.cancel(),
      _audioPositionSubscription?.cancel(),
      _audioStoppedSubscription?.cancel(),
    ].whereType<Future<void>>().toList();

    await Future.wait<void>(tasks);

    super.dispose();
  }

  Future<void> play({required PlayablePiece piece}) async {
    final originalPieces = state.pieces;
    if (originalPieces == null) {
      return;
    }

    final currentPlayingPiece = originalPieces.firstWhereOrNull(
      (playablePiece) => playablePiece.playStatus
          .map(stop: (_) => false, playing: (_) => true),
    );
    final List<PlayablePiece> pieces;
    if (currentPlayingPiece != null) {
      pieces = _replaceStatusToStop(
        pieces: originalPieces,
        target: currentPlayingPiece,
      );
    } else {
      pieces = originalPieces;
    }

    final index = pieces.indexOf(piece);

    final replaced =
        piece.copyWith(playStatus: const PlayStatus.playing(position: 0));
    pieces[index] = replaced;

    state = state.copyWith(pieces: pieces);

    await _player.play(piece.piece.url);
  }

  Future<void> stop({required PlayablePiece piece}) async {
    final pieces = state.pieces;
    if (pieces == null) {
      return;
    }

    final replaced = _replaceStatusToStop(pieces: pieces, target: piece);

    state = state.copyWith(pieces: replaced);

    await _player.stop();
  }

  Future<void> share({required Piece piece}) async {
    state = state.copyWith(isProcessing: true);

    final dio = Dio();

    final parentDirectory = await getApplicationDocumentsDirectory();
    final parentPath = parentDirectory.path;
    final directory = Directory('$parentPath/${piece.name}');
    await directory.create(recursive: true);

    final path = '${directory.path}/${piece.name}.mp3';

    await dio.download(piece.url, path);

    await Share.shareFiles([path]);

    state = state.copyWith(isProcessing: false);
  }

  Future<void> _setup() async {
    final piecesStream = await _pieceUseCase.getPiecesStream();
    _piecesSubscription = piecesStream.listen((pieces) {
      final playablePieces = pieces
          .map(
            (piece) => PlayablePiece(
              piece: piece,
              playStatus: const PlayStatus.stop(),
            ),
          )
          .toList();
      state = state.copyWith(pieces: playablePieces);
    });

    _audioLengthSubscription = _player.onDurationChanged.listen((duration) {
      _currentAudioLength = duration;
    });

    _audioPositionSubscription =
        _player.onAudioPositionChanged.listen((currentPosition) {
      final currentLength = _currentAudioLength;
      if (currentLength == null) {
        return;
      }

      final currentLengthSeconds = currentLength.inMilliseconds;
      final currentPositionSeconds = currentPosition.inMilliseconds;

      final currentPositionRatio =
          currentPositionSeconds / currentLengthSeconds;

      _updatePosition(currentPositionRatio);
    });

    _audioStoppedSubscription = _player.onPlayerCompletion.listen((_) {
      final pieces = state.pieces;
      if (pieces == null) {
        return;
      }

      final currentPlayingPiece = pieces.firstWhereOrNull(
        (playablePiece) => playablePiece.playStatus
            .map(stop: (_) => false, playing: (_) => true),
      );
      if (currentPlayingPiece == null) {
        return;
      }

      final replaced = _replaceStatusToStop(
        pieces: pieces,
        target: currentPlayingPiece,
      );

      state = state.copyWith(pieces: replaced);
    });
  }

  List<PlayablePiece> _replaceStatusToStop({
    required List<PlayablePiece> pieces,
    required PlayablePiece target,
  }) {
    final index =
        pieces.indexWhere((piece) => piece.piece.id == target.piece.id);

    final cloned = [...pieces];

    final replaced = target.copyWith(playStatus: const PlayStatus.stop());

    cloned[index] = replaced;

    return cloned;
  }

  void _updatePosition(double position) {
    final pieces = state.pieces;
    if (pieces == null) {
      return;
    }

    final currentPlayingPiece = pieces.firstWhereOrNull(
      (playablePiece) => playablePiece.playStatus
          .map(stop: (_) => false, playing: (_) => true),
    );
    if (currentPlayingPiece == null) {
      return;
    }

    final index = pieces.indexOf(currentPlayingPiece);

    final cloned = [...pieces];

    final replaced = currentPlayingPiece.copyWith(
      playStatus: PlayStatus.playing(position: position),
    );

    cloned[index] = replaced;

    state = state.copyWith(pieces: cloned);
  }
}
