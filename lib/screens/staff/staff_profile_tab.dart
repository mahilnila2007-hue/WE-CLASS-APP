import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/info_grid_card.dart';
import '../auth/login_selection_screen.dart';

class StaffProfileTab extends StatelessWidget {
  const StaffProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final staff = authService.currentUser ?? AuthService.defaultStaff;

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
                'STAFF PROFILE',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet,
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
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 3,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms),

              const SizedBox(height: 14),

              // Staff Name
              Text(
                staff.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 2),

              // Staff ID
              Text(
                'STAFF ID: ${staff.displayId}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.violet,
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
                    value: staff.name,
                    icon: Icons.person_outline_rounded,
                    gradient: AppColors.purpleGradient,
                  ),
                  // CARD 2: Staff ID (Blue gradient)
                  InfoGridCard(
                    label: 'Staff ID',
                    value: staff.displayId,
                    icon: Icons.badge_outlined,
                    gradient: AppColors.blueGradient,
                  ),
                  // CARD 3: Department (Orange gradient)
                  InfoGridCard(
                    label: 'Department',
                    value: staff.department ?? 'Electrical Maintenance',
                    icon: Icons.electrical_services_rounded,
                    gradient: AppColors.orangeGradient,
                  ),
                  // CARD 4: Designation (Teal gradient)
                  InfoGridCard(
                    label: 'Designation',
                    value: staff.designation ?? 'Maintenance Officer',
                    icon: Icons.work_outline_rounded,
                    gradient: AppColors.greenTealGradient,
                  ),
                  // CARD 5: Email (Cyan gradient)
                  InfoGridCard(
                    label: 'Email',
                    value: staff.email,
                    icon: Icons.mail_outline_rounded,
                    gradient: AppColors.primaryGradient,
                  ),
                  // CARD 6: Phone (Red gradient)
                  InfoGridCard(
                    label: 'Phone',
                    value: staff.phone,
                    icon: Icons.phone_android_rounded,
                    gradient: AppColors.redGradient,
                  ),
                  // CARD 7: Joining Year (Purple gradient)
                  InfoGridCard(
                    label: 'Joining Year',
                    value: staff.joiningYear ?? '2021',
                    icon: Icons.calendar_today_rounded,
                    gradient: AppColors.purpleGradient,
                  ),
                  // CARD 8: Assigned Area (Green gradient)
                  InfoGridCard(
                    label: 'Assigned Area',
                    value: staff.assignedArea ?? 'Block 4 & Labs',
                    icon: Icons.map_rounded,
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
