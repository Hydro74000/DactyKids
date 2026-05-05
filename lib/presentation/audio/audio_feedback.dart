import 'package:audioplayers/audioplayers.dart';

class AudioFeedback {
  AudioFeedback({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Future<void> playCorrect() => _play('sounds/correct.wav');

  Future<void> playError() => _play('sounds/error.wav');

  Future<void> playSuccess() => _play('sounds/success.wav');

  Future<void> dispose() => _player.dispose();

  Future<void> _play(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path));
  }
}
