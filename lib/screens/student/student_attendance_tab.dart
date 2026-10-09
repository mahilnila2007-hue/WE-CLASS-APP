import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/attendance_model.dart';
import '../../services/campus_data_service.dart';
import '../../services/focus_guard_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/focus_guard_violation_card.dart';

class StudentAttendanceTab extends StatefulWidget {
  const StudentAttendanceTab({super.key});

  @override
  State<StudentAttendanceTab> createState() => _StudentAttendanceTabState();
}

class _StudentAttendanceTabState extends State<StudentAttendanceTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final campusData = Provider.of<CampusDataService>(context);
    final overview = campusData.studentAttendanceOverview;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Heading
              Text(
                'Attendance',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 6),

              Text(
                'Live smart tracking & predictive analysis',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- MAIN CIRCULAR ATTENDANCE CARD ----------------
              GradientCard(
                gradient: AppColors.primaryGradient,
                borderRadius: 28,
                hasGlow: true,
                glowColor: AppColors.brightCyan,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Large Circular Indicator
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: CircularProgressIndicator(
                                  value: overview.percentage / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    overview.percentageString,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Attendance',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Breakdown Stats Grid
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetricRow('Present', '${overview.present}', AppColors.brightGreen),
                              const SizedBox(height: 8),
                              _buildMetricRow('Absent', '${overview.absent}', AppColors.alertRed),
                              const SizedBox(height: 8),
                              _buildMetricRow('Total Classes', '${overview.total}', Colors.white),
                              const SizedBox(height: 8),
                              _buildMetricRow('Required', '${overview.requiredPercentage.toInt()}%', AppColors.brightCyan),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // ---------------- ATTENDANCE PREDICTION CARD ----------------
              GradientCard(
                solidColor: AppColors.deepNavy,
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                border: Border.all(
                  color: AppColors.brightGreen.withOpacity(0.3),
                  width: 1.2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.brightCyan,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Attendance Prediction',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Risk Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brightGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.brightGreen,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            overview.riskLevel,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brightGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      overview.predictionMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkNavy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.brightCyan,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              overview.classesRequiredFor75 == 0
                                  ? '0 additional classes required to maintain 75% minimum limit.'
                                  : 'Must attend next ${overview.classesRequiredFor75} classes to restore 75%.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 26),

              // ---------------- MONTHLY CALENDAR SECTION ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MONTHLY LOG',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'October 2026',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brightCyan,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem('Present', AppColors.brightGreen),
                  _buildLegendItem('Absent', AppColors.alertRed),
                  _buildLegendItem('Holiday', AppColors.secondaryGrey),
                  _buildLegendItem('Leave', AppColors.orange),
                ],
              ),

              const SizedBox(height: 16),

              // Calendar Days Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    // Weekday Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                        return SizedBox(
                          width: 32,
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryGrey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Grid of 28 Days
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: overview.monthlyRecords.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final record = overview.monthlyRecords[index];
                        Color dotColor;
                        switch (record.status) {
                          case DayAttendanceStatus.present:
                            dotColor = AppColors.brightGreen;
                            break;
                          case DayAttendanceStatus.absent:
                            dotColor = AppColors.alertRed;
                            break;
                          case DayAttendanceStatus.holiday:
                            dotColor = AppColors.secondaryGrey;
                            break;
                          case DayAttendanceStatus.leave:
                            dotColor = AppColors.orange;
                            break;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkNavy,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dotColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 26),

              // ---------------- FOCUSGUARD VIOLATION HISTORY (READ-ONLY) ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FOCUSGUARD VIOLATIONS',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Read-Only Log',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.alertRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Consumer<FocusGuardService>(
                builder: (context, focusGuard, _) {
                  final studentViolations = focusGuard.violations
                      .where((v) => v.studentId == '927624BEC121')
                      .toList();

                  if (studentViolations.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'No classroom phone usage violations recorded.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: studentViolations.map((v) {
                      return FocusGuardStudentHistoryCard(violation: v);
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
