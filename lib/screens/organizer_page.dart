import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage>
    with SingleTickerProviderStateMixin {
  double _dragAmount = 0.0;
  int _currentIndex = 2026;
  late AnimationController _animationController;
  Animation<double>? _currentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _finishMove(bool complete) {
    if (complete) {
      // Cel: 1.0 (lewo) lub -1.0 (prawo)
      double target = _dragAmount > 0 ? 1.0 : -1.0;

      _currentAnimation = Tween<double>(
        begin: _dragAmount,
        end: target,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.addListener(_updateDragAmount);

      _animationController.forward(from: 0.0).then((_) {
        _animationController.removeListener(_updateDragAmount);
        setState(() {
          _currentIndex += _dragAmount > 0 ? 1 : -1;
          _dragAmount = 0.0;
          _animationController.reset();
        });
      });
    } else {
      // Powrót do zera (anulowanie)
      _currentAnimation = Tween<double>(
        begin: _dragAmount,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.addListener(_updateDragAmount);
      _animationController.forward(from: 0.0).then((_) {
        _animationController.removeListener(_updateDragAmount);
        setState(() {
          _dragAmount = 0.0;
          _animationController.reset();
        });
      });
    }
  }

  void _updateDragAmount() {
    if (_currentAnimation != null) {
      setState(() {
        _dragAmount = _currentAnimation!.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          if (_animationController.isAnimating) return;
          setState(() {
            _dragAmount -=
                details.primaryDelta! / MediaQuery.of(context).size.width;
            _dragAmount = _dragAmount.clamp(-1.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          if (_animationController.isAnimating) return;
          // Decyzja na podstawie wychylenia lub szybkości machnięcia
          bool shouldFlip =
              _dragAmount.abs() > 0.4 || details.primaryVelocity!.abs() > 600;
          _finishMove(shouldFlip);
        },
        child: Stack(
          children: [
            // KARTA POD SPODEM
            _buildPaperContent(
                _dragAmount > 0 ? _currentIndex + 1 : _currentIndex - 1),

            // KARTA WIERZCHNIA (Ucinana)
            ClipPath(
              clipper: CylinderClipper(_dragAmount),
              child: _buildPaperContent(_currentIndex),
            ),

            // WAŁEK 3D
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

  Widget _buildPaperContent(int year) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFFFF7E6),
      child: CustomPaint(
        painter: FullPagePainter(year: year.toString()),
      ),
    );
  }
}

// --- RENDERING STRONY ---
class FullPagePainter extends CustomPainter {
  final String year;
  FullPagePainter({required this.year});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    for (double i = 60; i < size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final calendarPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    double cellW = size.width / 7;
    for (int col = 0; col <= 7; col++) {
      canvas.drawLine(
          Offset(col * cellW, 150), Offset(col * cellW, 450), calendarPaint);
    }
    for (int row = 0; row <= 5; row++) {
      canvas.drawLine(Offset(0, 150 + (row * 60)),
          Offset(size.width, 150 + (row * 60)), calendarPaint);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: "STYCZEŃ $year",
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.brown.withValues(alpha: 0.6)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, 80));
  }

  @override
  bool shouldRepaint(FullPagePainter old) => old.year != year;
}

// --- RENDERING WAŁKA 3D ---
class DynamicCylinderPainter extends CustomPainter {
  final double amount;
  DynamicCylinderPainter(this.amount);

  @override
  void paint(Canvas canvas, Size size) {
    double absA = amount.abs();
    double xPos = amount > 0 ? size.width * (1 - absA) : size.width * absA;
    double cylinderWidth = 25.0 + (85.0 * math.sqrt(absA));

    Rect cylinderRect = Rect.fromLTWH(amount > 0 ? xPos : xPos - cylinderWidth,
        0, cylinderWidth, size.height);

    // Cień rzucany
    final dropShadow = Paint()
      ..shader = LinearGradient(
        begin: amount > 0 ? Alignment.centerRight : Alignment.centerLeft,
        end: amount > 0 ? Alignment.centerLeft : Alignment.centerRight,
        colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
      ).createShader(
          Rect.fromLTWH(amount > 0 ? xPos - 40 : xPos, 0, 40, size.height));
    canvas.drawRect(
        Rect.fromLTWH(amount > 0 ? xPos - 40 : xPos, 0, 40, size.height),
        dropShadow);

    // Papier wałka
    canvas.drawRect(cylinderRect, Paint()..color = const Color(0xFFF2E4C1));

    // Odbicie siatki (Twoje zielone linie)
    canvas.save();
    canvas.clipRect(cylinderRect);
    final paint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    double cellW = size.width / 7;
    for (int col = 0; col <= 7; col++) {
      double origX = col * cellW;
      double dist = amount > 0 ? (origX - xPos) : (xPos - origX);
      double lineX = amount > 0 ? xPos + dist : xPos - dist;
      canvas.drawLine(Offset(lineX, 150), Offset(lineX, 450), paint);
    }
    for (double i = 60; i < size.height; i += 32) {
      canvas.drawLine(
          Offset(cylinderRect.left, i), Offset(cylinderRect.right, i), paint);
    }
    canvas.restore();

    // Efekt 3D (Światło)
    final highlight = Paint()
      ..shader = LinearGradient(
        begin: amount > 0 ? Alignment.centerLeft : Alignment.centerRight,
        end: amount > 0 ? Alignment.centerRight : Alignment.centerLeft,
        colors: [
          Colors.black.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.4),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(cylinderRect);
    canvas.drawRect(cylinderRect, highlight);
  }

  @override
  bool shouldRepaint(DynamicCylinderPainter old) => old.amount != amount;
}

// --- CLIPPER ---
class CylinderClipper extends CustomClipper<Path> {
  final double amount;
  CylinderClipper(this.amount);
  @override
  Path getClip(Size size) {
    double absA = amount.abs();
    double xPos = amount > 0 ? size.width * (1 - absA) : size.width * absA;
    Path path = Path();
    if (amount >= 0)
      path.addRect(Rect.fromLTWH(0, 0, xPos, size.height));
    else
      path.addRect(Rect.fromLTWH(xPos, 0, size.width - xPos, size.height));
    return path;
  }

  @override
  bool shouldReclip(CylinderClipper old) => old.amount != amount;
}
