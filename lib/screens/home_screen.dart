import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  final String token, phone, firstName, lastName, tariff;
  const HomeScreen({
    super.key,
    required this.token,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.tariff,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أهلاً،',
                          style: GoogleFonts.cairo(
                              fontSize: 15, color: Colors.grey)),
                      Text('$firstName $lastName',
                          style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textColor)),
                    ],
                  ),
                  Row(
                    children: [
                      // زرار الوضع الليلي
                      GestureDetector(
                        onTap: () =>
                            context.read<ThemeProvider>().toggle(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? AppTheme.gold : Colors.blueGrey,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.red.withOpacity(0.4),
                                blurRadius: 20),
                          ],
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.red, AppTheme.darkRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.red.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('رقم الهاتف',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7))),
                    Text(phone,
                        style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1)),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(tariff,
                            style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 32),

              Text('الخدمات',
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor))
                  .animate(delay: 250.ms).fadeIn(),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      phone: phone,
                      firstName: firstName,
                      lastName: lastName,
                      tariff: tariff,
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            color: AppTheme.red, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تواصل مع خدمة العملاء',
                                style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textColor)),
                            Text('محادثة مباشرة مع موظف',
                                style: GoogleFonts.cairo(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.2),

              const Spacer(),

              Center(
                child: Text('Team Ali',
                    style: GoogleFonts.dancingScript(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gold.withOpacity(0.6),
                    )),
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
