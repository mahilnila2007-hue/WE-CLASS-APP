import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/focus_guard_staff_card.dart';

class StaffHomeTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const StaffHomeTab({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final campusData = Provider.of<CampusDataService>(context);
    final staff = authService.currentUser ?? AuthService.defaultStaff;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- STAFF TOP HEADER ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOOD EVENING',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.violet,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          staff.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Staff ID: ${staff.displayId}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onNavigateTab(4), // Navigate to profile
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.badge_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ---------------- 4 STAFF OVERVIEW METRICS GRID ----------------
              Text(
                'CAMPUS PULSE',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textGrey,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStaffMetricCard(
                      title: 'Total Students',
                      value: '1,245',
                      icon: Icons.groups_rounded,
                      color: AppColors.brightCyan,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStaffMetricCard(
                      title: 'Present Today',
                      value: '982',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.brightGreen,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStaffMetricCard(
                      title: 'Active Complaints',
                      value: '${campusData.allComplaints.length}',
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.orange,
                      onTap: () => onNavigateTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStaffMetricCard(
                      title: 'Critical Issues',
                      value: '${campusData.criticalComplaintsCount}',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.alertRed,
                      onTap: () => onNavigateTab(2),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // ---------------- FOCUSGUARD CLASSROOM CONTROLLER ----------------
              const FocusGuardStaffCard().animate().fadeIn(delay: 230.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // ---------------- STAFF QUICK ACTIONS ----------------
              Text(
                'OPERATIONS & MANAGEMENT',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textGrey,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 14),

              // CARD 1: Attendance Monitor
              _buildStaffActionCard(
                title: 'Attendance Monitor',
                subtitle: 'Real-time department rosters & check-in logs',
                actionText: 'Open Monitor →',
                icon: Icons.fact_check_rounded,
                gradient: AppColors.primaryGradient,
                glowColor: AppColors.electricBlue,
                onTap: () => onNavigateTab(1),
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 14),

              // CARD 2: Complaint Management
              _buildStaffActionCard(
                title: 'Complaint Management',
                subtitle: 'AI-triaged maintenance routing & tickets',
                actionText: 'Manage Tickets →',
                icon: Icons.handyman_rounded,
                gradient: AppColors.orangeGradient,
                glowColor: AppColors.orange,
                onTap: () => onNavigateTab(2),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 14),

              // CARD 3: Campus Status & Alerts
              _buildStaffActionCard(
                title: 'Campus Alerts & Status',
                subtitle: 'Broadcast notifications & geofence telemetry',
                actionText: 'View Alerts →',
                icon: Icons.notifications_active_rounded,
                gradient: AppColors.purpleGradient,
                glowColor: AppColors.purple,
                onTap: () => onNavigateTab(3),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
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
                Icon(icon, color: color, size: 22),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActionCard({
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required Gradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          splashColor: Colors.white.withOpacity(0.2),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -15,
                child: Opacity(
                  opacity: 0.14,
                  child: Icon(icon, size: 120, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            actionText,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
