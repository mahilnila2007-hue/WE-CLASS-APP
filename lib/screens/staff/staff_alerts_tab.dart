import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/focus_guard_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/focus_guard_violation_card.dart';
import '../../widgets/focus_guard_admin_modal.dart';

class StaffAlertsTab extends StatelessWidget {
  const StaffAlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);
    final violations = focusGuard.violations;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Settings Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Alerts',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 4),
                        Text(
                          'Classroom phone violations & zone telemetry',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const FocusGuardAdminModal(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.brightCyan,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- FOCUSGUARD CLASSROOM PHONE ALERTS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FOCUSGUARD PHONE ALERTS',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.alertRed,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${violations.where((v) => v.status == "NEW").length} NEW',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (violations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Text(
                      'No phone usage violations detected in current sessions.',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ),
                )
              else
                ...violations.map((violation) {
                  return FocusGuardViolationStaffCard(
                    violation: violation,
                    focusGuard: focusGuard,
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0);
                }),

              const SizedBox(height: 24),

              // ---------------- GEOFENCE & PERIMETER CARD ----------------
              GradientCard(
                gradient: AppColors.purpleGradient,
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Smart Geofence',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brightGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brightGreen, width: 1),
                          ),
                          child: Text(
                            'ACTIVE (12m ACCURACY)',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brightGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Perimeter sensors operating normally across Main Campus, North Hostel & Tech Labs.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 24),

              // ---------------- LIVE BROADCASTS & WARNINGS ----------------
              Text(
                'LIVE BROADCASTS & WARNINGS',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textGrey,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              _buildAlertCard(
                title: 'Power Grid Scheduled Maintenance',
                message: 'Substation B will undergo preventative inspection from 04:00 PM to 06:00 PM.',
                severity: 'MEDIUM',
                timestamp: 'Today, 02:30 PM',
                icon: Icons.power_rounded,
                color: AppColors.orange,
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 12),

              _buildAlertCard(
                title: 'Emergency Blood Requirement',
                message: 'General Hospital campus unit requires O+ donors for emergency trauma standby.',
                severity: 'CRITICAL',
                timestamp: 'Today, 11:15 AM',
                icon: Icons.bloodtype_rounded,
                color: AppColors.alertRed,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),

              _buildAlertCard(
                title: 'Semester Attendance Cut-off Alert',
                message: 'Department portals will lock attendance inputs for Week 12 on Friday 5:00 PM.',
                severity: 'INFO',
                timestamp: 'Yesterday, 09:00 AM',
                icon: Icons.info_outline_rounded,
                color: AppColors.brightCyan,
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String severity,
    required String timestamp,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            timestamp,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.secondaryGrey,
            ),
          ),
        ],
      ),
    );
  }
}
