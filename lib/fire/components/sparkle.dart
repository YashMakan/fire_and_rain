import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class Sparkle extends ParticleSystemComponent {
  /// [color] controls the sparkle hue.
  Sparkle({
    required Vector2 position,
    this.color,
  }) : super(
          position: position,
          // just a handful of quick line‑streaks
          particle: Particle.generate(
            count: 8,
            lifespan: 0.25,
            generator: (_) {
              final lifetime = 0.25;
              final speed = 80 + Random().nextDouble() * 120;
              final angle = Random().nextDouble() * 2 * pi;
              final vel = Vector2(cos(angle), sin(angle)) * speed;
              return AcceleratedParticle(
                acceleration: Vector2(0, 300),
                speed: vel,
                // rotate the child to align with velocity
                child: CircleParticle(
                  radius: 0.5 + Random().nextDouble() * 1.0,
                  paint: Paint()..color = color ?? const Color(0xFF902503),
                  lifespan: lifetime,
                ),
              );
            },
          ),
        );

  final Color? color;
}
