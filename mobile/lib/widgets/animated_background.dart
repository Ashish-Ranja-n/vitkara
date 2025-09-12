import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  /// densityMultiplier: scales the number of particles (1.0 = base)
  /// minParticles: lower bound for particle count
  /// speed: scales particle velocity
  /// particleColor / lineColor: visual colors
  /// connectThreshold: max distance to draw connecting lines
  const AnimatedBackground({
    super.key,
    this.densityMultiplier = 1.8,
    this.minParticles = 50,
    this.speed = 1.0,
    this.particleColor = const Color.fromRGBO(0, 229, 255, 0.55),
    this.lineColor = const Color.fromRGBO(0, 229, 255, 0.16),
    this.connectThreshold = 120.0,
  });

  final double densityMultiplier;
  final int minParticles;
  final double speed;
  final Color particleColor;
  final Color lineColor;
  final double connectThreshold;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Particle> _particles = [];
  late Size _size;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
    // periodic tick to update positions at ~60fps
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      for (final p in _particles) {
        p.update(_size);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _ensureParticles(Size size) {
    _size = size;
    if (_particles.isNotEmpty) return;
    // base area divisor (smaller -> more particles); tuned for mobile
    // lowered divisor -> more particles overall
    const baseDivisor = 10000.0;
    final area = size.width * size.height;
    final particleCount = max(
      widget.minParticles,
      (area / baseDivisor * widget.densityMultiplier).round(),
    );
    final rnd = Random();
    for (int i = 0; i < particleCount; i++) {
      final dirX = (rnd.nextDouble() - 0.5) * 0.6 * widget.speed;
      final dirY = (rnd.nextDouble() - 0.5) * 0.6 * widget.speed;
      _particles.add(
        _Particle(
          offset: Offset(
            rnd.nextDouble() * size.width,
            rnd.nextDouble() * size.height,
          ),
          dir: Offset(dirX, dirY),
          size: rnd.nextDouble() * 2.5 + 0.6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sz = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureParticles(sz);
        return IgnorePointer(
          child: CustomPaint(
            size: sz,
            painter: _ParticlePainter(
              _particles,
              particleColor: widget.particleColor,
              lineColor: widget.lineColor,
              connectThreshold: widget.connectThreshold,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  Offset offset;
  Offset dir;
  double size;
  _Particle({required this.offset, required this.dir, required this.size});

  void update(Size sz) {
    offset = offset + dir;
    if (offset.dx <= 0 || offset.dx >= sz.width) dir = Offset(-dir.dx, dir.dy);
    if (offset.dy <= 0 || offset.dy >= sz.height) dir = Offset(dir.dx, -dir.dy);
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color particleColor;
  final Color lineColor;
  final double connectThreshold;

  _ParticlePainter(
    this.particles, {
    required this.particleColor,
    required this.lineColor,
    required this.connectThreshold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // draw particles
    for (final p in particles) {
      paint.color = particleColor;
      canvas.drawCircle(p.offset, p.size, paint);
    }

    // connect nearby particles
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = lineColor;

    final threshold = connectThreshold;
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final a = particles[i].offset;
        final b = particles[j].offset;
        final dist = (a - b).distance;
        if (dist < threshold) {
          final alpha = (1.0 - (dist / threshold)) * 0.28;
          canvas.drawLine(
            a,
            b,
            linePaint..color = lineColor.withOpacity(alpha),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
