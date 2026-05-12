import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vodafone_service.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // هيدر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أهلاً،',
                          style: GoogleFonts.cairo(
                              fontSize: 15, color: AppTheme.grey)),
                      Text('$firstName $lastName',
                          style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.white)),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
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
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // كارد المعلومات
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
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
              )
                  .animate(delay: 150.ms)
                  .fadeIn()
                  .slideY(begin: 0.2),

              const SizedBox(height: 32),

              Text('الخدمات',
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white))
                  .animate(delay: 250.ms).fadeIn(),

              const SizedBox(height: 16),

              // زرار Chat
              _ServiceCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'تواصل مع خدمة العملاء',
                subtitle: 'محادثة مباشرة مع موظف',
                delay: 300,
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
              ),

              const Spacer(),

              // Team Ali
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

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final int delay;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white)),
                  Text(subtitle,
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: AppTheme.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.grey, size: 16),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.2);
  }
}
