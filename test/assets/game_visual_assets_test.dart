import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generated game visual assets are bundled as png files', () async {
    const handSpriteNames = [
      'hands_left_annulaire.png',
      'hands_left_auriculaire.png',
      'hands_left_index.png',
      'hands_left_majeur.png',
      'hands_none.png',
      'hands_pouces.png',
      'hands_right_annulaire.png',
      'hands_right_auriculaire.png',
      'hands_right_index.png',
      'hands_right_majeur.png',
    ];

    for (final path in [
      'assets/images/game/balloon_background.png',
      'assets/images/game/balloon_red.png',
      'assets/images/game/garden_background.png',
      'assets/images/game/garden_flower.png',
      'assets/images/game/hands_guide.png',
      for (final name in handSpriteNames) 'assets/images/game/hands/$name',
      for (final name in handSpriteNames) 'assets/images/game/hands/red/$name',
      for (final name in handSpriteNames)
        'assets/images/game/hands/high_contrast/$name',
      'assets/images/game/mole_background.png',
      'assets/images/game/mole_sprite.png',
      'assets/images/game/race_background.png',
      'assets/images/game/race_car.png',
      'assets/images/game/cars/race_car_damage_00.png',
      'assets/images/game/cars/race_car_damage_01.png',
      'assets/images/game/cars/race_car_damage_02.png',
      'assets/images/game/cars/race_car_damage_03.png',
      'assets/images/game/cars/race_car_damage_04.png',
      'assets/images/game/cars/race_car_damage_05.png',
      'assets/images/game/cars/race_car_damage_06.png',
      'assets/images/game/cars/race_car_damage_07.png',
      'assets/images/game/cars/race_car_damage_08.png',
      'assets/images/game/cars/race_car_damage_09.png',
      'assets/images/game/cars/race_car_damage_10.png',
      'assets/images/game/rocket_sprite.png',
      'assets/images/game/space_background.png',
    ]) {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();

      expect(bytes.length, greaterThan(1000));
      expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    }
  });
}
