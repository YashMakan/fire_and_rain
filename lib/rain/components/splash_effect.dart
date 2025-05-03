import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class Splash extends ParticleSystemComponent {
  Splash({
    required Vector2 position,
    this.color,
  }) : super(
          position: position,
          particle: Particle.generate(
            count: 8,
            lifespan: .8,
            generator: (_) {
              const lifetime = 0.8;
              final speed = 100 + Random().nextDouble() * 50;
              // Mostly upward splash: 60° to 120° in radians
              final angle =
                  -1 * (pi / 2) + (Random().nextDouble() - 0.5) * (pi / 3);
              final vel = Vector2(cos(angle), sin(angle)) * speed;
              return AcceleratedParticle(
                acceleration: Vector2(0, 200), // gravity downwards
                speed: vel,
                child: CircleParticle(
                  radius: 0.5 + Random().nextDouble() * 0.8,
                  paint: Paint()
                    ..color = color ?? const Color(0xFF66CCFF).withOpacity(0.3),
                  lifespan: lifetime,
                ),
              );
            },
          ),
        );

  final Color? color;
}
