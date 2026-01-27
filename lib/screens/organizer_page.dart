import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  int _currentIndex = 2026;
  late AnimationController _controller;
  final Map<int, List<Offset?>> _allNotes = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  void _handleUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) return;
    setState(() {
      _dragValue -= details.primaryDelta! / MediaQuery.of(context).size.width;
      _dragValue = _dragValue.clamp(-1.0, 1.0);
    });
  }

  void _animateTo(double target, {VoidCallback? onComplete}) {
    final Animation<double> localAnim =
        Tween<double>(begin: _dragValue, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    localAnim.addListener(() => setState(() => _dragValue = localAnim.value));
    _controller.forward(from: 0.0).then((_) {
      _controller.reset();
      if (onComplete != null) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    _allNotes.putIfAbsent(_currentIndex, () => []);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          if (_dragValue != 0)
            _PageContainer(
              key: ValueKey(
                  _dragValue > 0 ? _currentIndex + 1 : _currentIndex - 1),
              year: _dragValue > 0 ? _currentIndex + 1 : _currentIndex - 1,
              notes: _allNotes[
                      _dragValue > 0 ? _currentIndex + 1 : _currentIndex - 1] ??
                  [],
            ),
          Center(
            child: Transform(
              alignment: _dragValue >= 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_dragValue * math.pi / 1.5),
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (_dragValue.abs() < 0.02) {
                    setState(() =>
                        _allNotes[_currentIndex]!.add(details.localPosition));
                  }
                },
                onPanEnd: (details) =>
                    setState(() => _allNotes[_currentIndex]!.add(null)),
                child: _PageContainer(
                  key: ValueKey(_currentIndex),
                  year: _currentIndex,
                  notes: _allNotes[_currentIndex]!,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onHorizontalDragUpdate: _handleUpdate,
              onHorizontalDragEnd: (d) {
                double target = _dragValue.abs() > 0.3
                    ? (_dragValue > 0 ? 1.0 : -1.0)
                    : 0.0;
                _animateTo(target, onComplete: () {
                  if (target.abs() == 1.0) {
                    setState(() {
                      _currentIndex += _dragValue > 0 ? 1 : -1;
                      _dragValue = 0.0;
                    });
                  }
                });
              },
              child: Container(height: 100, color: Colors.transparent),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.delete_sweep,
                  color: Color(0xFF5D4037), size: 30),
              onPressed: () => setState(() => _allNotes[_currentIndex] = []),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContainer extends StatelessWidget {
  final int year;
  final List<Offset?> notes;
  const _PageContainer({super.key, required this.year, required this.notes});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFFF3E5AB),
              Color(0xFFC1A17B)
            ], // Efekt "starej skóry/pergaminu"
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
                size: Size.infinite, painter: CalendarPainter(year: year)),
            CustomPaint(
                size: Size.infinite, painter: InkPainter(points: notes)),
          ],
        ),
      ),
    );
  }
}

class CalendarPainter extends CustomPainter {
  final int year;
  CalendarPainter({required this.year});

  @override
  void paint(Canvas canvas, Size size) {
    // Linie (delikatniejsze)
    final linePaint = Paint()
      ..color = Colors.brown.withOpacity(0.05)
      ..strokeWidth = 1.0;
    for (double i = 100; i < size.height; i += 22) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    final tp = TextPainter(
      text: TextSpan(
          text: "ROK $year",
          style: TextStyle(
              color: const Color(0xFF3E2723).withOpacity(0.8),
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              letterSpacing: 6)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, 45));

    _drawCalendar(canvas, size);
  }

  void _drawCalendar(Canvas canvas, Size size) {
    double startY = 150;
    double gridW = size.width / 3.4;
    double gridH = (size.height - 200) / 4.6;
    final months = [
      "STYCZEŃ",
      "LUTY",
      "MARZEC",
      "KWIECIEŃ",
      "MAJ",
      "CZERWIEC",
      "LIPIEC",
      "SIERPIEŃ",
      "WRZESIEŃ",
      "PAŹDZIERNIK",
      "LISTOPAD",
      "GRUDZIEŃ"
    ];
    final daysHeader = ["P", "W", "Ś", "C", "P", "S", "N"];

    for (int m = 0; m < 12; m++) {
      double x = (m % 3) * gridW + 28;
      double y = (m ~/ 3) * gridH + startY;

      // Miesiąc
      TextPainter(
          text: TextSpan(
              text: months[m],
              style: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr)
        ..layout()
        ..paint(canvas, Offset(x, y));

      // Nagłówek dni tygodnia
      for (int i = 0; i < 7; i++) {
        TextPainter(
          text: TextSpan(
              text: daysHeader[i],
              style: TextStyle(
                  color: i == 6
                      ? Colors.red.withOpacity(0.5)
                      : Colors.brown.withOpacity(0.4),
                  fontSize: 7,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, Offset(x + i * (gridW / 8.5), y + 14));
      }

      // Daty
      DateTime firstDay = DateTime(year, m + 1, 1);
      int daysInMonth = DateTime(year, m + 2, 0).day;
      int startOffset = firstDay.weekday - 1;

      for (int d = 1; d <= daysInMonth; d++) {
        int pos = d + startOffset;
        int col = (pos - 1) % 7;
        int row = (pos - 1) ~/ 7;
        double dx = x + col * (gridW / 8.5);
        double dy = y + 25 + row * 11;

        TextPainter(
          text: TextSpan(
              text: "$d",
              style: TextStyle(
                  color: col == 6
                      ? Colors.red.withOpacity(0.6)
                      : const Color(0xFF3E2723).withOpacity(0.6),
                  fontSize: 7.5,
                  fontFamily: 'Monospace')),
          textDirection: TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, Offset(dx, dy));
      }
    }
  }

  @override
  bool shouldRepaint(CalendarPainter old) => old.year != year;
}

class InkPainter extends CustomPainter {
  final List<Offset?> points;
  InkPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final ink = Paint()
      ..color = const Color(0xFF002147)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..isAntiAlias = true;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(points[i]!, points[i + 1]!, ink);
    }
  }

  @override
  bool shouldRepaint(InkPainter old) => true;
}
