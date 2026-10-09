import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/focus_guard_student_card.dart';

class StudentHomeTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const StudentHomeTab({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final campusData = Provider.of<CampusDataService>(context);
    final user = authService.currentUser ?? AuthService.defaultStudent;
    final attendance = campusData.studentAttendanceOverview;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- TOP HEADER ----------------
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
                            color: AppColors.brightCyan,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.name.toUpperCase(),
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
                          'ID: ${user.displayId}',
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
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brightCyan.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ---------------- 3 HORIZONTAL STATISTICS CARDS ----------------
              Row(
                children: [
                  // Stat 1: Attendance
                  Expanded(
                    child: _buildQuickStatCard(
                      title: 'Attendance',
                      value: attendance.percentageString,
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.brightCyan,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stat 2: Blood
                  Expanded(
                    child: _buildQuickStatCard(
                      title: 'Blood',
                      value: 'Available',
                      icon: Icons.bloodtype_rounded,
                      color: AppColors.alertRed,
                      onTap: () => onNavigateTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stat 3: Complaints
                  Expanded(
                    child: _buildQuickStatCard(
                      title: 'Complaints',
                      value: '${campusData.activeComplaintsCount} Active',
                      icon: Icons.report_problem_rounded,
                      color: AppColors.orange,
                      onTap: () => onNavigateTab(3),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // ---------------- TODAY'S ATTENDANCE HOME CARD ----------------
              GradientCard(
                solidColor: AppColors.deepNavy,
                borderRadius: 26,
                padding: const EdgeInsets.all(22),
                border: Border.all(
                  color: attendance.isPresentToday
                      ? AppColors.successGreen.withOpacity(0.3)
                      : AppColors.alertRed.withOpacity(0.3),
                  width: 1.2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TODAY'S ATTENDANCE",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGrey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        // Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: attendance.isPresentToday
                                ? AppColors.successGreen.withOpacity(0.15)
                                : AppColors.alertRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: attendance.isPresentToday
                                  ? AppColors.successGreen
                                  : AppColors.alertRed,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                attendance.isPresentToday
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 14,
                                color: attendance.isPresentToday
                                    ? AppColors.successGreen
                                    : AppColors.alertRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                attendance.isPresentToday ? 'PRESENT' : 'OUTSIDE CAMPUS',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: attendance.isPresentToday
                                      ? AppColors.successGreen
                                      : AppColors.alertRed,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Attendance Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildAttendanceInfoTile(
                            label: 'Location',
                            value: attendance.todayLocation,
                            icon: Icons.location_on_rounded,
                            iconColor: attendance.isPresentToday
                                ? AppColors.brightCyan
                                : AppColors.alertRed,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: AppColors.borderLight,
                        ),
                        Expanded(
                          child: _buildAttendanceInfoTile(
                            label: 'Time',
                            value: attendance.todayTime,
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.textGrey,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: AppColors.borderLight,
                        ),
                        Expanded(
                          child: _buildAttendanceInfoTile(
                            label: 'GPS Accuracy',
                            value: attendance.gpsAccuracy,
                            icon: Icons.gps_fixed_rounded,
                            iconColor: AppColors.brightGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Interactive Simulation Toggle Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          campusData.toggleLocationSimulation();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz_rounded,
                                size: 14,
                                color: AppColors.brightCyan.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Simulate ${attendance.isPresentToday ? 'Exit Geofence' : 'Enter Campus'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brightCyan.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // ---------------- FOCUSGUARD CLASSROOM MONITORING CARD ----------------
              const FocusGuardStudentCard().animate().fadeIn(delay: 280.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // ---------------- MAIN QUICK ACTION CARDS ----------------
              Text(
                'QUICK ACTIONS',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textGrey,
                  letterSpacing: 1.4,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 14),

              // ACTION CARD 1: Smart Attendance
              _buildMainActionCard(
                title: 'Smart Attendance',
                highlightText: '${attendance.percentageString} Attendance',
                actionLabel: 'View Attendance →',
                icon: Icons.calendar_month_rounded,
                gradient: AppColors.primaryGradient,
                glowColor: AppColors.brightCyan,
                onTap: () => onNavigateTab(1),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 16),

              // ACTION CARD 2: Blood Donor
              _buildMainActionCard(
                title: 'Blood Donor',
                highlightText: 'Find compatible blood donors quickly.',
                actionLabel: 'Find Donor →',
                icon: Icons.bloodtype_rounded,
                gradient: AppColors.purpleGradient,
                glowColor: AppColors.purple,
                onTap: () => onNavigateTab(2),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 16),

              // ACTION CARD 3: Campus Complaint
              _buildMainActionCard(
                title: 'Campus Complaint',
                highlightText: 'Report infrastructure problems.',
                actionLabel: 'Report Issue →',
                icon: Icons.report_problem_rounded,
                gradient: AppColors.orangeGradient,
                glowColor: AppColors.orange,
                onTap: () => onNavigateTab(3),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withOpacity(0.2),
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
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
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

  Widget _buildAttendanceInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionCard({
    required String title,
    required String highlightText,
    required String actionLabel,
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
              // Decorative background low opacity icon
              Positioned(
                right: -10,
                bottom: -15,
                child: Opacity(
                  opacity: 0.14,
                  child: Icon(
                    icon,
                    size: 130,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Row(
                  children: [
                    // Large Circular Icon on Left
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            highlightText,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                actionLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
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
