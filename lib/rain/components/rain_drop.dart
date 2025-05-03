import 'package:fire_and_rain/rain/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Raindrop extends PositionComponent with HasGameRef<RainGame> {
  static final Vector2 dropSize = Vector2(1, 18);
  static const double gravity = 1000; // px/s²

  // Initial velocity: mostly down, some left for wind
  final Vector2 _vel = Vector2(-150, 600);
  double _time = 0.0;

  late final ui.FragmentProgram _prog;
  late final ui.FragmentShader _shader;

  Raindrop({required Vector2 position})
      : super(
    position: position,
    size: dropSize,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _prog = await ui.FragmentProgram.fromAsset('shaders/rain.frag');
    _shader = _prog.fragmentShader();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
    _vel.y += gravity * dt;
    position += _vel * dt;

    // Remove if off screen
    if (position.x < -size.x || position.y > gameRef.size.y + size.y) {
      removeFromParent();
      return;
    }

    if (!isLoaded) return;
    _shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, _time)
      ..setFloat(3, _vel.length);
  }

  @override
  void render(Canvas canvas) {
    if (!isLoaded) return;
    paint ??= Paint()..shader = _shader;
    canvas.drawRect(Offset.zero & size.toSize(), paint!);
  }

  Paint? paint;
}