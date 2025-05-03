import 'package:fire_and_rain/fire/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Fireball extends PositionComponent with HasGameRef<FireGame> {
  // ── Tunables ────────────────────────────────────────────────────
  static final Vector2 fireballSize = Vector2.all(128); // sprite rect
  static const double gravity = 480; // px/s²

  // ── Internals ───────────────────────────────────────────────────
  final Vector2 _vel = Vector2(0, 350); // initial downward speed
  double _time = 0.0;

  late final ui.FragmentProgram _prog;
  late final ui.FragmentShader _shader;

  Fireball({required Vector2 position})
      : super(
    position: position,
    size: fireballSize,
    anchor: Anchor.center,
  );

  // ─── Load shader ────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    super.onLoad();
    _prog = await ui.FragmentProgram.fromAsset('shaders/fire.frag');
    _shader = _prog.fragmentShader();
  }

  // ─── Update: physics + uniforms ─────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    // 1) Physics
    _time += dt;
    _vel.y += gravity * dt;
    position += _vel * dt;

    // 2) Cull when off‑screen
    if (position.y > gameRef.size.y + size.y / 2) {
      removeFromParent();
      return;
    }

    // 3) Pass uniforms
    if (!isLoaded) return;
    _shader
      ..setFloat(0, size.x) // resolution.x
      ..setFloat(1, size.y) // resolution.y
      ..setFloat(2, _time) // u_time
      ..setFloat(3, _vel.y); // u_speed (current vertical speed)
  }

  // ─── Draw ───────────────────────────────────────────────────────
  @override
  void render(Canvas canvas) {
    if (!isLoaded) return;
    paint ??= Paint()..shader = _shader;
    canvas.drawRect(Offset.zero & size.toSize(), paint!);
  }

  Paint? paint; // cached paint with shader
}