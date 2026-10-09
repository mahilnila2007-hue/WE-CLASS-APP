import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/focus_guard_model.dart';
import '../services/focus_guard_service.dart';

class FocusGuardViolationStaffCard extends StatelessWidget {
  final PhoneViolation violation;
  final FocusGuardService focusGuard;

  const FocusGuardViolationStaffCard({
    super.key,
    required this.violation,
    required this.focusGuard,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = violation.status == 'NEW';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isNew
              ? AppColors.alertRed.withOpacity(0.5)
              : AppColors.borderLight,
          width: isNew ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isNew
                ? AppColors.alertRed.withOpacity(0.2)
                : Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Alert Type & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phonelink_erase_rounded,
                      color: AppColors.alertRed,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phone Usage Alert',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNew
                      ? AppColors.alertRed.withOpacity(0.15)
                      : AppColors.brightGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isNew ? AppColors.alertRed : AppColors.brightGreen,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  violation.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isNew ? AppColors.alertRed : AppColors.brightGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Student Info
          Text(
            violation.studentName,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '${violation.department} • ${violation.year} (${violation.studentId})',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.brightCyan),
          ),

          const SizedBox(height: 8),

          // Classroom & Duration Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subject:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      violation.subject,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room / Period:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      '${violation.room} (Period ${violation.period})',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Usage Duration:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      '${violation.usageDuration} seconds (≥ ${violation.threshold}s limit)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(violation.timestamp),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: [ VIEW ], [ ACKNOWLEDGE ]
          Row(
            children: [
              Expanded(
                child: _buildOutlineButton(
                  label: 'VIEW',
                  icon: Icons.visibility_outlined,
                  color: AppColors.brightCyan,
                  onTap: () => _showDetailedViolationModal(context),
                ),
              ),
              const SizedBox(width: 10),
              if (isNew)
                Expanded(
                  child: _buildOutlineButton(
                    label: 'ACKNOWLEDGE',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.brightGreen,
                    onTap: () {
                      focusGuard.acknowledgeViolation(violation.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Violation #${violation.id} marked as acknowledged.'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedViolationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Violation Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${violation.usageDuration}s ACTIVE',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Student: ${violation.studentName} (${violation.studentId})',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Class: ${violation.subject} in Room ${violation.room} (Period ${violation.period})',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                'Detected at: ${DateFormat('dd MMM yyyy, hh:mm a').format(violation.timestamp)}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Continuous mobile phone screen interaction exceeded the ${violation.threshold}-second classroom threshold.',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey, height: 1.3),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class FocusGuardStudentHistoryCard extends StatelessWidget {
  final PhoneViolation violation;

  const FocusGuardStudentHistoryCard({
    super.key,
    required this.violation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phone Usage Violation',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recorded',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.alertRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Subject: ${violation.subject}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
          ),
          Text(
            'Room: ${violation.room}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
          ),
          Text(
            'Duration: ${violation.usageDuration} seconds',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brightCyan),
          ),
          Text(
            'Date: ${DateFormat('dd MMMM yyyy').format(violation.timestamp)}',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryGrey),
          ),
        ],
      ),
    );
  }
}
