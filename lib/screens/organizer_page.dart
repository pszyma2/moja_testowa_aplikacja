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

  // MAPA: Rok -> Lista punktów (zapisuje notatki dla każdego roku osobno)
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
    // Inicjalizacja listy dla bieżącego roku, jeśli jeszcze nie istnieje
    _allNotes.putIfAbsent(_currentIndex, () => []);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // 1. KARTA POD SPODEM (Inny rok)
          _buildFullPage(
              _dragValue >= 0 ? _currentIndex + 1 : _currentIndex - 1,
              isBackground: true),

          // 2. KARTA WIERZCHNIA (Bieżący rok + Twój Waterman)
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
                  if (_dragValue.abs() < 0.05) {
                    setState(() {
                      _allNotes[_currentIndex]!.add(details.localPosition);
                    });
                  }
                },
                onPanEnd: (details) =>
                    setState(() => _allNotes[_currentIndex]!.add(null)),
                child: _buildFullPage(_currentIndex),
              ),
            ),
          ),

          // 3. DOLNY PASEK DO PRZEWIJANIA
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

          // Gumka
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.brown.withOpacity(0.4),
              child: const Icon(Icons.delete_forever, color: Colors.white70),
              onPressed: () => setState(() => _allNotes[_currentIndex] = []),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPage(int year, {bool isBackground = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8D3B9),
      child: CustomPaint(
        painter: VintagePagePainter(
          year: year,
          // Przekazujemy notatki tylko dla tego konkretnego roku
          points: _allNotes[year] ?? [],
        ),
      ),
    );
  }
}

class VintagePagePainter extends CustomPainter {
  final int year;
  final List<Offset?> points;
  VintagePagePainter({required this.year, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Papier
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFE8D3B9));

    // Linie
    final linePaint = Paint()..color = Colors.brown.withOpacity(0.08);
    for (double i = 100; i < size.height; i += 22) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Rok
    final tp = TextPainter(
      text: TextSpan(
          text: "ROK $year",
          style: TextStyle(
              color: Colors.brown[900]!.withOpacity(0.6),
              fontSize: 45,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              letterSpacing: 5)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, 40));

    // Kalendarz (Dni)
    _drawCalendar(canvas, size);

    // ATRAMENT (Tylko dla tego roku)
    final ink = Paint()
      ..color = const Color(0xFF002B5B)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, ink);
      }
    }
  }

  void _drawCalendar(Canvas canvas, Size size) {
    double startY = 140;
    double gridW = size.width / 3.3;
    double gridH = (size.height - 200) / 4.5;
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

    for (int m = 0; m < 12; m++) {
      double x = (m % 3) * gridW + 25;
      double y = (m ~/ 3) * gridH + startY;

      TextPainter(
          text: TextSpan(
              text: months[m],
              style: const TextStyle(
                  color: Colors.brown,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr)
        ..layout()
        ..paint(canvas, Offset(x, y));

      DateTime firstDay = DateTime(year, m + 1, 1);
      int daysInMonth = DateTime(year, m + 2, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        int pos = d + firstDay.weekday - 1;
        double dx = x + ((pos - 1) % 7) * (gridW / 8.5);
        double dy = y + 15 + ((pos - 1) ~/ 7) * 11;
        TextPainter(
            text: TextSpan(
                text: "$d",
                style: TextStyle(
                    color: Colors.brown[900]!.withOpacity(0.5), fontSize: 7)),
            textDirection: TextDirection.ltr)
          ..layout()
          ..paint(canvas, Offset(dx, dy));
      }
    }
  }

  @override
  bool shouldRepaint(VintagePagePainter old) =>
      old.points != points || old.year != year;
}
