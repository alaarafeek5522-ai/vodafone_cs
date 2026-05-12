import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : const Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter(isDark: isDark))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الدائرة الدوارة مع Team Ali
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // دائرة خارجية دوارة
                      AnimatedBuilder(
                        animation: _rotCtrl,
                        builder: (_, __) => Transform.rotate(
                          angle: _rotCtrl.value * 2 * pi,
                          child: CustomPaint(
                            size: const Size(220, 220),
                            painter: _CircleTextPainter(
                              text: 'Team Ali  ✦  Team Ali  ✦  ',
                            ),
                          ),
                        ),
                      ),
                      // لوجو في المنتصف
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.red,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.red.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: 52),
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 400.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  'خدمة العملاء',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 6),

                Text(
                  'Vodafone Egypt',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.red,
                    letterSpacing: 3,
                  ),
                ).animate(delay: 500.ms).fadeIn(),
              ],
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  backgroundColor: isDark
                      ? const Color(0xFF1C1C1C)
                      : const Color(0xFFE0E0E0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.red),
                  minHeight: 2,
                ),
              ).animate(delay: 400.ms).fadeIn(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleTextPainter extends CustomPainter {
  final String text;
  _CircleTextPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final charAngle = (2 * pi) / text.length;

    for (int i = 0; i < text.length; i++) {
      final angle = i * charAngle - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);

      textPainter.text = TextSpan(
        text: text[i],
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.gold,
          letterSpacing: 1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
