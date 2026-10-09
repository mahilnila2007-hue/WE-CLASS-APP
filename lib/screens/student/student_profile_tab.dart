import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/info_grid_card.dart';
import '../auth/login_selection_screen.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser ?? AuthService.defaultStudent;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Title
              Text(
                'PROFILE',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brightCyan,
                  letterSpacing: 2.5,
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // Large Circular Gradient Avatar
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brightCyan.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 3,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms),

              const SizedBox(height: 14),

              // Student Name
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 2),

              // Student ID
              Text(
                user.displayId,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brightCyan,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 26),

              // 2-Column Grid of 8 Colorful Information Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  // CARD 1: Name (Purple gradient)
                  InfoGridCard(
                    label: 'Name',
                    value: user.name,
                    icon: Icons.person_outline_rounded,
                    gradient: AppColors.purpleGradient,
                  ),
                  // CARD 2: Student ID (Blue gradient)
                  InfoGridCard(
                    label: 'Student ID',
                    value: user.displayId,
                    icon: Icons.badge_outlined,
                    gradient: AppColors.blueGradient,
                  ),
                  // CARD 3: Department (Orange gradient)
                  InfoGridCard(
                    label: 'Department',
                    value: user.department ?? 'ECE',
                    icon: Icons.school_outlined,
                    gradient: AppColors.orangeGradient,
                  ),
                  // CARD 4: Batch (Teal gradient)
                  InfoGridCard(
                    label: 'Batch',
                    value: user.batch ?? '2024–2028',
                    icon: Icons.timeline_rounded,
                    gradient: AppColors.greenTealGradient,
                  ),
                  // CARD 5: Year (Cyan gradient)
                  InfoGridCard(
                    label: 'Year',
                    value: user.year ?? 'III Year',
                    icon: Icons.history_edu_rounded,
                    gradient: AppColors.primaryGradient,
                  ),
                  // CARD 6: Blood Group (Red gradient)
                  InfoGridCard(
                    label: 'Blood Group',
                    value: user.bloodGroup ?? 'O+',
                    icon: Icons.bloodtype_outlined,
                    gradient: AppColors.redGradient,
                  ),
                  // CARD 7: Phone (Purple gradient)
                  InfoGridCard(
                    label: 'Phone',
                    value: user.phone,
                    icon: Icons.phone_android_rounded,
                    gradient: AppColors.purpleGradient,
                  ),
                  // CARD 8: Email (Green gradient)
                  InfoGridCard(
                    label: 'Email',
                    value: user.email,
                    icon: Icons.mail_outline_rounded,
                    gradient: AppColors.greenTealGradient,
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 28),

              // Sign Out Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.alertRed.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                          (route) => false,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.alertRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SIGN OUT',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.alertRed,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
