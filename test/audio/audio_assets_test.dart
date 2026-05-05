import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('audio feedback assets are bundled as wav files', () async {
    for (final path in [
      'assets/sounds/correct.wav',
      'assets/sounds/error.wav',
      'assets/sounds/success.wav',
    ]) {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();

      expect(bytes.length, greaterThan(44));
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
      expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WAVE');
    }
  });
}
