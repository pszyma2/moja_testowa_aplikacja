import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  double _dragAmount = 0.0;
  int _currentIndex = 2026;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragAmount -=
                details.primaryDelta! / MediaQuery.of(context).size.width;
            _dragAmount = _dragAmount.clamp(-1.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragAmount.abs() > 0.35) {
            setState(() {
              _currentIndex += _dragAmount > 0 ? 1 : -1;
              _dragAmount = 0.0;
            });
          } else {
            setState(() => _dragAmount = 0.0);
          }
        },
        child: Stack(
          children: [
            _buildCompletePage(
                _dragAmount > 0 ? _currentIndex + 1 : _currentIndex - 1, 0),
            ClipPath(
              clipper: CylinderClipper(_dragAmount),
              child: _buildCompletePage(_currentIndex, _dragAmount),
            ),
            if (_dragAmount != 0)
              IgnorePointer(
                child: CustomPaint(
                  painter: DynamicCylinderPainter(_dragAmount),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePage(int year, double drag) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFFFF7E6),
      child: CustomPaint(
        painter: FullPagePainter(year: year.toString(), bend: drag),
      ),
    );
  }
}

class FullPagePainter extends CustomPainter {
  final String year;
  final double bend;
  FullPagePainter({required this.year, required this.bend});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. LINIE - teraz mocne i wyraźne (Brązowe)
    final linePaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.25)
      ..strokeWidth = 1.4;

    for (double i = 65; i < size.height; i += 35) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // 2. ROK Z EFEKTEM NASUWANIA
    final textPainter = TextPainter(
      text: TextSpan(
        text: year,
        style: TextStyle(
            fontSize: 110,
            fontWeight: FontWeight.bold,
            color: Colors.brown.withValues(alpha: 0.12)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double tx = (size.width - textPainter.width) / 2;
    double ty = (size.height - textPainter.height) / 2;

    canvas.save();
    if (bend != 0) {
      double absA = bend.abs();
      double foldX = bend > 0 ? size.width * (1 - absA) : size.width * absA;
      double dist = (tx + textPainter.width / 2 - foldX).abs();

      if (dist < 140) {
        double warp = (140 - dist) / 140;
        canvas.translate(tx - (25 * warp * (bend > 0 ? 1 : -1)), ty);
        canvas.scale(1.0 - (0.35 * warp), 1.0);
      } else {
        canvas.translate(tx, ty);
      }
    } else {
      canvas.translate(tx, ty);
    }
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FullPagePainter old) =>
      old.bend != bend || old.year != year;
}

class DynamicCylinderPainter extends CustomPainter {
  final double amount;
  DynamicCylinderPainter(this.amount);

  @override
  void paint(Canvas canvas, Size size) {
    double absA = amount.abs();
    double xPos = amount > 0 ? size.width * (1 - absA) : size.width * absA;

    // Dynamika grubości wałka (którą już mamy)
    double cylinderWidth = amount > 0
        ? 20.0 + (75.0 * math.sqrt(absA))
        : 95.0 - (75.0 * math.pow(absA, 0.6));

    // Prostokąt wałka
    Rect cylinderRect = Rect.fromLTWH(amount > 0 ? xPos : xPos - cylinderWidth,
        0, cylinderWidth, size.height);

    // 1. RYSOWANIE REWERSU (Linie na wałku)
    canvas.save();
    canvas.clipRect(cylinderRect); // Rysujemy tylko wewnątrz wałka

    // Tło rewersu (ciut ciemniejszy papier)
    canvas.drawRect(cylinderRect, Paint()..color = const Color(0xFFF2E4C1));

    // Linie na rewersie (muszą być w tych samych miejscach co na stronie)
    final linePaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.15)
      ..strokeWidth = 1.2;

    for (double i = 65; i < size.height; i += 35) {
      // Rysujemy linie poziome przez całą szerokość wałka
      canvas.drawLine(Offset(cylinderRect.left, i),
          Offset(cylinderRect.right, i), linePaint);
    }
    canvas.restore();

    // 2. GRADIENT 3D (Nakładamy go NA linie, żeby je pocieniować)
    final foldPaint = Paint()
      ..shader = LinearGradient(
        begin: amount > 0 ? Alignment.centerLeft : Alignment.centerRight,
        end: amount > 0 ? Alignment.centerRight : Alignment.centerLeft,
        colors: [
          Colors.black.withValues(alpha: 0.1), // Cień przy krawędzi styku
          Colors.white.withValues(alpha: 0.4), // Błysk na szczycie wałka
          Colors.black.withValues(alpha: 0.2), // Głęboki cień wewnątrz zwoju
        ],
        stops: const [0.0, 0.25, 1.0],
      ).createShader(cylinderRect);

    canvas.drawRect(cylinderRect, foldPaint);

    // 3. CIEŃ RZUCANY NA STRONĘ POD SPODEM
    final dropShadow = Paint()
      ..shader = LinearGradient(
        begin: amount > 0 ? Alignment.centerRight : Alignment.centerLeft,
        end: amount > 0 ? Alignment.centerLeft : Alignment.centerRight,
        colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
      ).createShader(
          Rect.fromLTWH(amount > 0 ? xPos - 40 : xPos, 0, 40, size.height));

    canvas.drawRect(
        Rect.fromLTWH(amount > 0 ? xPos - 40 : xPos, 0, 40, size.height),
        dropShadow);
  }

  @override
  bool shouldRepaint(DynamicCylinderPainter old) => old.amount != amount;
}

class CylinderClipper extends CustomClipper<Path> {
  final double amount;
  CylinderClipper(this.amount);
  @override
  Path getClip(Size size) {
    double absA = amount.abs();
    double xPos = amount > 0 ? size.width * (1 - absA) : size.width * absA;
    Path path = Path();
    if (amount >= 0) {
      path.addRect(Rect.fromLTWH(0, 0, xPos, size.height));
    } else {
      path.addRect(Rect.fromLTWH(xPos, 0, size.width - xPos, size.height));
    }
    return path;
  }

  @override
  bool shouldReclip(CylinderClipper old) => old.amount != amount;
}
