import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  late final AnimationController _confettiController;
  late final List<ConfettiPiece> _confettiPieces;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _confettiPieces = _buildConfettiPieces();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<ConfettiPiece> _buildConfettiPieces() {
    final rng = Random(7);
    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFF7C4DFF),
      const Color(0xFF40C4FF),
      const Color(0xFF69F0AE),
      const Color(0xFFFFD740),
    ];
    return List.generate(22, (i) {
      return ConfettiPiece(
        start: Offset(
          rng.nextDouble() * 260 - 130,
          rng.nextDouble() * -120 - 20,
        ),
        radius: 5 + rng.nextDouble() * 7,
        isCircle: i.isEven,
        color: colors[i % colors.length],
        drift: rng.nextDouble() * 24 - 12,
        fallDistance: 240 + rng.nextDouble() * 80,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.0,
            colors: [Color(0xFFFFC1D9), Color(0xFFE53935)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                final next = value ?? selectedEmoji;
                setState(() => selectedEmoji = next);
                if (next != 'Party Heart') {
                  _confettiController
                    ..stop()
                    ..reset();
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/love_icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTapDown: (details) {
                    if (selectedEmoji != 'Party Heart') return;
                    final local = details.localPosition;
                    const size = Size(300, 300);
                    final center = Offset(size.width / 2, size.height / 2);
                    final a = Offset(center.dx, center.dy - 110);
                    final b = Offset(center.dx - 40, center.dy - 40);
                    final c = Offset(center.dx + 40, center.dy - 40);
                    if (_pointInTriangle(local, a, b, c)) {
                      _confettiController
                        ..reset()
                        ..repeat();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (_, __) => CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(
                        type: selectedEmoji,
                        confettiProgress: _confettiController.value,
                        confettiPieces: _confettiPieces,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _pointInTriangle(Offset p, Offset a, Offset b, Offset c) {
    double sign(Offset p1, Offset p2, Offset p3) {
      return (p1.dx - p3.dx) * (p2.dy - p3.dy) -
          (p2.dx - p3.dx) * (p1.dy - p3.dy);
    }

    final d1 = sign(p, a, b);
    final d2 = sign(p, b, c);
    final d3 = sign(p, c, a);
    final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
  }
}

class ConfettiPiece {
  const ConfettiPiece({
    required this.start,
    required this.radius,
    required this.isCircle,
    required this.color,
    required this.drift,
    required this.fallDistance,
  });
  final Offset start;
  final double radius;
  final bool isCircle;
  final Color color;
  final double drift;
  final double fallDistance;
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.confettiProgress,
    required this.confettiPieces,
  });
  final String type;
  final double confettiProgress;
  final List<ConfettiPiece> confettiPieces;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    final startColor = type == 'Party Heart'
        ? const Color(0xFFFF80AB)
        : const Color(0xFFFF5C8D);
    final endColor = type == 'Party Heart'
        ? const Color(0xFFEC407A)
        : const Color(0xFFD81B60);
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [startColor, endColor],
    ).createShader(Offset.zero & size);
    canvas.drawPath(heartPath, paint);

    // Face features (starter)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Party hat + falling confetti
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      for (final piece in confettiPieces) {
        final dy = piece.start.dy + (piece.fallDistance * confettiProgress);
        final wrappedY = dy > 140 ? dy - (piece.fallDistance + 140) : dy;
        final dx = piece.start.dx + (piece.drift * confettiProgress);
        final p = Offset(center.dx + dx, center.dy + wrappedY);

        final paintConfetti = Paint()..color = piece.color;
        if (piece.isCircle) {
          canvas.drawCircle(p, piece.radius, paintConfetti);
        } else {
          final tri = Path()
            ..moveTo(p.dx, p.dy - piece.radius)
            ..lineTo(p.dx - piece.radius, p.dy + piece.radius)
            ..lineTo(p.dx + piece.radius, p.dy + piece.radius)
            ..close();
          canvas.drawPath(tri, paintConfetti);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.confettiProgress != confettiProgress ||
      oldDelegate.confettiPieces != confettiPieces;
}
