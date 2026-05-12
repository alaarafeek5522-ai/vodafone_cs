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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // خلفية
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // محتوى المنتصف
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // لوجو
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.red,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.red.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.headset_mic_rounded,
                      color: Colors.white, size: 50),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // اسم التطبيق
                Text(
                  'خدمة العملاء',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.white,
                    letterSpacing: 1,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 6),

                // Vodafone
                Text(
                  'Vodafone Egypt',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.red,
                    letterSpacing: 3,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Team Ali
                Text(
                  'Team Ali',
                  style: GoogleFonts.dancingScript(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 600.ms)
                    .shimmer(
                      duration: 1200.ms,
                      color: Colors.white,
                      delay: 900.ms,
                    ),
              ],
            ),
          ),

          // loading في الأسفل
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: AppTheme.darkSurface,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.red),
                    minHeight: 2,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
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
