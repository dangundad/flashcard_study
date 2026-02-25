import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ConfettiOverlay({super.key, required this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _particles = List.generate(80, (_) => _generateParticle());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  _ConfettiParticle _generateParticle() {
    return _ConfettiParticle(
      x: _rng.nextDouble(),
      y: -_rng.nextDouble() * 0.3,
      velocityX: (_rng.nextDouble() - 0.5) * 0.4,
      velocityY: 0.3 + _rng.nextDouble() * 0.5,
      rotation: _rng.nextDouble() * 2 * pi,
      rotationSpeed: (_rng.nextDouble() - 0.5) * 6,
      size: 4 + _rng.nextDouble() * 8,
      color: _confettiColors[_rng.nextInt(_confettiColors.length)],
      shape: _rng.nextInt(3),
    );
  }

  static const List<Color> _confettiColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF9F43),
    Color(0xFFEE5A24),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final int shape;

  const _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;

    for (final p in particles) {
      final t = progress;
      final gravity = 0.5 * t * t;
      final currentX = (p.x + p.velocityX * t) * size.width;
      final currentY = (p.y + p.velocityY * t + gravity) * size.height;

      if (currentY > size.height * 1.2) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      switch (p.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6,
            ),
            paint,
          );
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
        default:
          final path = Path()
            ..moveTo(0, -p.size * 0.5)
            ..lineTo(p.size * 0.4, p.size * 0.3)
            ..lineTo(-p.size * 0.4, p.size * 0.3)
            ..close();
          canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
