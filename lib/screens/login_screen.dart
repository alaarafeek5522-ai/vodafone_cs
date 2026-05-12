import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vodafone_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await VodafoneService.login(
          _phoneCtrl.text.trim(), _passCtrl.text.trim());
      final profile = await VodafoneService.getUserProfile(
          token, _phoneCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            token: token,
            phone: _phoneCtrl.text.trim(),
            firstName: profile['firstName']!,
            lastName: profile['lastName']!,
            tariff: profile['tariff']!,
          ),
        ),
      );
    } catch (e) {
      setState(() { _error = 'رقم الهاتف أو كلمة المرور غلط'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _BgPainter())),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // هيدر
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.red.withOpacity(0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('خدمة العملاء',
                              style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.white)),
                          Text('Vodafone Egypt',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: AppTheme.red,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

                  const SizedBox(height: 60),

                  Text('تسجيل الدخول',
                      style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.white))
                      .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 6),

                  Text('ادخل بيانات تطبيق أنا فودافون',
                      style: GoogleFonts.cairo(
                          fontSize: 14, color: AppTheme.grey))
                      .animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 40),

                  // حقل الهاتف
                  _buildField(
                    controller: _phoneCtrl,
                    hint: 'رقم الهاتف',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    delay: 200,
                  ),

                  const SizedBox(height: 16),

                  // حقل الباسورد
                  _buildField(
                    controller: _passCtrl,
                    hint: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    delay: 250,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.grey,
                          size: 20),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.red, size: 18),
                          const SizedBox(width: 8),
                          Text(_error!,
                              style: GoogleFonts.cairo(
                                  color: AppTheme.red, fontSize: 13)),
                        ],
                      ),
                    ).animate().shakeX(),
                  ],

                  const SizedBox(height: 36),

                  // زرار الدخول
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red,
                        disabledBackgroundColor:
                            AppTheme.red.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('دخول',
                              style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

                  const SizedBox(height: 60),

                  // Team Ali
                  Center(
                    child: Text('Team Ali',
                        style: GoogleFonts.dancingScript(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold.withOpacity(0.7),
                        )),
                  ).animate(delay: 400.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    int delay = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textDirection: TextDirection.ltr,
        style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.cairo(color: AppTheme.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.red, size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.2);
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE60000).withOpacity(0.04)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}
