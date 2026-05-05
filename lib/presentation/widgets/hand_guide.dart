import 'package:flutter/material.dart';

class HandGuide extends StatelessWidget {
  const HandGuide({
    super.key,
    required this.finger,
    required this.highContrast,
  });

  final String finger;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final asset = _assetFor(finger, highContrast: highContrast);

    return Semantics(
      label: 'Aide mains. Doigt a utiliser: $finger.',
      child: SizedBox(
        width: 250,
        height: 148,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            semanticLabel: '',
          ),
        ),
      ),
    );
  }

  String _assetFor(String rawFinger, {required bool highContrast}) {
    final directory = highContrast ? 'high_contrast' : 'red';
    final finger = rawFinger.toLowerCase();
    if (finger.contains('pouce')) {
      return 'assets/images/game/hands/$directory/hands_pouces.png';
    }
    final isLeft = finger.contains('gauche');
    if (finger.contains('auriculaire')) {
      return isLeft
          ? 'assets/images/game/hands/$directory/hands_left_auriculaire.png'
          : 'assets/images/game/hands/$directory/hands_right_auriculaire.png';
    }
    if (finger.contains('annulaire')) {
      return isLeft
          ? 'assets/images/game/hands/$directory/hands_left_annulaire.png'
          : 'assets/images/game/hands/$directory/hands_right_annulaire.png';
    }
    if (finger.contains('majeur')) {
      return isLeft
          ? 'assets/images/game/hands/$directory/hands_left_majeur.png'
          : 'assets/images/game/hands/$directory/hands_right_majeur.png';
    }
    if (finger.contains('index')) {
      return isLeft
          ? 'assets/images/game/hands/$directory/hands_left_index.png'
          : 'assets/images/game/hands/$directory/hands_right_index.png';
    }
    return 'assets/images/game/hands/$directory/hands_none.png';
  }
}
