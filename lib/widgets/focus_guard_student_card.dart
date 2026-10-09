import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/focus_guard_model.dart';
import '../services/focus_guard_service.dart';
import 'gradient_card.dart';

class FocusGuardStudentCard extends StatelessWidget {
  const FocusGuardStudentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);
    final period = focusGuard.currentPeriod;
    final state = focusGuard.state;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (state) {
      case FocusGuardState.active:
        statusColor = AppColors.brightGreen;
        statusText = 'ACTIVE';
        statusIcon = Icons.sensors_rounded;
        break;
      case FocusGuardState.breakPeriod:
        statusColor = AppColors.orange;
        statusText = 'BREAK';
        statusIcon = Icons.coffee_rounded;
        break;
      case FocusGuardState.disabledByFaculty:
        statusColor = AppColors.textGrey;
        statusText = 'DISABLED BY FACULTY';
        statusIcon = Icons.do_not_disturb_on_rounded;
        break;
      case FocusGuardState.inactive:
        statusColor = AppColors.secondaryGrey;
        statusText = 'INACTIVE';
        statusIcon = Icons.nightlight_round;
        break;
    }

    return GradientCard(
      solidColor: AppColors.deepNavy,
      borderRadius: 26,
      padding: const EdgeInsets.all(22),
      border: Border.all(
        color: state == FocusGuardState.active
            ? AppColors.brightCyan.withOpacity(0.35)
            : AppColors.borderLight,
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: state == FocusGuardState.active
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [
                                statusColor.withOpacity(0.4),
                                statusColor.withOpacity(0.2),
                              ],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: state == FocusGuardState.active
                          ? [
                              BoxShadow(
                                color: AppColors.brightCyan.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FocusGuard',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Classroom Mobile Monitoring',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Current Class Details Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                _buildDetailRow('Subject:', period.subject, isHighlight: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow('Room:', period.room),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailRow('Period:', period.periodNumber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Time:', period.timeRange, valueColor: AppColors.brightCyan),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Continuous Usage Live Status Banner
          if (state == FocusGuardState.active) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: focusGuard.isPhoneActivelyInUse
                    ? AppColors.alertRed.withOpacity(0.12)
                    : AppColors.deepNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: focusGuard.isPhoneActivelyInUse
                      ? AppColors.alertRed.withOpacity(0.5)
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        focusGuard.isPhoneActivelyInUse
                            ? Icons.phone_android_rounded
                            : Icons.lock_clock_rounded,
                        size: 18,
                        color: focusGuard.isPhoneActivelyInUse
                            ? AppColors.alertRed
                            : AppColors.brightCyan,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          focusGuard.isPhoneActivelyInUse
                              ? 'Active Classroom Usage: ${focusGuard.currentContinuousUsageSeconds}s / ${focusGuard.phoneUsageThreshold}s limit'
                              : 'Monitoring phone usage in active class session.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: focusGuard.isPhoneActivelyInUse
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: focusGuard.isPhoneActivelyInUse
                                ? AppColors.alertRed
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (focusGuard.isPhoneActivelyInUse) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (focusGuard.currentContinuousUsageSeconds / focusGuard.phoneUsageThreshold).clamp(0.0, 1.0),
                        backgroundColor: AppColors.darkNavy,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          focusGuard.currentContinuousUsageSeconds >= focusGuard.phoneUsageThreshold
                              ? AppColors.alertRed
                              : AppColors.brightCyan,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else if (state == FocusGuardState.breakPeriod) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Break/Lunch: Monitoring automatically disabled.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Simulation Phone Usage Testing Trigger
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                focusGuard.setPhoneUsageState(!focusGuard.isPhoneActivelyInUse);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      focusGuard.isPhoneActivelyInUse
                          ? Icons.stop_circle_rounded
                          : Icons.play_circle_fill_rounded,
                      size: 14,
                      color: AppColors.brightCyan.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      focusGuard.isPhoneActivelyInUse
                          ? 'Stop Phone Screen Simulation'
                          : 'Simulate Active Phone Usage (${focusGuard.phoneUsageThreshold}s Test)',
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
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
