import 'dart:math';

import 'package:fire_and_rain/rain/components/rain_drop.dart';
import 'package:fire_and_rain/rain/components/splash_effect.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class RainGame extends FlameGame {
  final GlobalKey personKey;
  Rect? _personRect;
  late final Timer _spawnTimer;
  final _rand = Random();

  RainGame(this.personKey);

  @override
  Future<void> onLoad() async {
    // Spawn raindrops frequently for rain effect
    _spawnTimer = Timer(.08, repeat: true, onTick: () {
      final x = size.x * _rand.nextDouble(); // full width
      add(Raindrop(position: Vector2(x, 0)));
    });
    _spawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);

    // Update button rect
    final ctx = personKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      final topLeft = box.localToGlobal(Offset.zero);
      _personRect = topLeft & box.size;
    }

    // Check collision with raindrops
    for (final drop in children.whereType<Raindrop>()) {
      final global = convertLocalToGlobalCoordinate(drop.position);
      if (_personRect?.contains(Offset(global.x, global.y)) ?? false) {
        add(Splash(position: drop.position.clone()));
        drop.removeFromParent();
      }
    }
  }
}
