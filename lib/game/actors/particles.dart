import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class DustParticle extends ParticleSystemComponent {
  DustParticle({required Vector2 position})
      : super(
          particle: Particle.generate(
            count: 5,
            lifespan: 0.5,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 50),
              speed: Vector2.random() * 50 - Vector2(25, 25), // Random spread
              position: position,
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
}

class PopParticle extends ParticleSystemComponent {
  PopParticle({required Vector2 position})
      : super(
          particle: Particle.generate(
            count: 10,
            lifespan: 0.5,
            generator: (i) => AcceleratedParticle(
              speed: Vector2.random() * 100 - Vector2(50, 50),
              position: position,
              child: CircleParticle(
                radius: 3,
                paint: Paint()..color = Colors.white,
              ),
            ),
          ),
        );
}

