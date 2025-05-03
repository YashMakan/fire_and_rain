import 'dart:math';

import 'package:fire_and_rain/fire/components/fire_ball.dart';
import 'package:fire_and_rain/fire/components/sparkle.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FireGame extends FlameGame {
  final GlobalKey buttonKey;
  Rect? _buttonRect;
  late final Timer _spawnTimer;
  final _rand = Random();

  FireGame(this.buttonKey);

  @override
  Future<void> onLoad() async {
    // spawn a new fireball every 0.5s
    _spawnTimer = Timer(0.5, repeat: true, onTick: () {
      final x = _rand.nextDouble() * size.x;
      add(Fireball(position: Vector2(x, 0)));
    });
    _spawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);

    // 1) update the button's screen Rect
    final ctx = buttonKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      final topLeft = box.localToGlobal(Offset.zero);
      _buttonRect = topLeft & box.size;
    }

    // 2) for each fireball, project game→screen and check hit
    for (final fb in children.whereType<Fireball>()) {
      final global = convertLocalToGlobalCoordinate(fb.position);
      if (_buttonRect?.contains(Offset(global.x, global.y)) ?? false) {
        // spawn a sparkle burst
        add(Sparkle(position: fb.position.clone()));
        // then remove the fireball
        fb.removeFromParent();
      }
    }
  }
}
