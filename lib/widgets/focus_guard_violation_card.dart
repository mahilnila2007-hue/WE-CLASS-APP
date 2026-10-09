import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final isCritical = violation.urgency == 'CRITICAL' || violation.usageDuration >= 35;
    final isWarned = violation.status == 'WARNED';
    final isSummoned = violation.status == 'SUMMONED';
    final isEscalated = violation.status == 'ESCALATED';
    final isAcknowledged = violation.status == 'ACKNOWLEDGED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCritical
              ? AppColors.alertRed.withOpacity(0.8)
              : (isNew ? AppColors.alertRed.withOpacity(0.5) : AppColors.borderLight),
          width: isCritical ? 1.6 : (isNew ? 1.4 : 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: isCritical
                ? AppColors.alertRed.withOpacity(0.3)
                : (isNew ? AppColors.alertRed.withOpacity(0.15) : Colors.black.withOpacity(0.3)),
            blurRadius: isCritical ? 18 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Alert Type, Urgency Badge & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: (isCritical ? AppColors.alertRed : AppColors.electricBlue).withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCritical ? AppColors.alertRed : AppColors.electricBlue,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.phonelink_erase_rounded,
                      color: isCritical ? AppColors.alertRed : AppColors.brightCyan,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Usage Violation',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${violation.room} • ${violation.subject}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCritical
                          ? AppColors.alertRed
                          : (isAcknowledged ? AppColors.brightGreen : AppColors.electricBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCritical ? '🚨 CRITICAL' : violation.status,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('hh:mm a').format(violation.timestamp),
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Student Info Row with Quick Call Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.electricBlue.withOpacity(0.2),
                  child: Text(
                    violation.studentName.isNotEmpty ? violation.studentName[0] : 'S',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brightCyan,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        violation.studentName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${violation.department} • ${violation.year} (${violation.studentId})',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.brightCyan),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.brightGreen, size: 20),
                  tooltip: 'Call Student',
                  onPressed: () async {
                    final uri = Uri.parse('tel:${violation.studentPhone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Classroom & Telemetry Details
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
                      'Continuous Usage:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      '${violation.usageDuration} seconds (Limit: ${violation.threshold}s)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isCritical ? AppColors.alertRed : AppColors.brightCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Action Status:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      violation.actionTaken == 'NONE' ? 'Pending Action' : violation.actionTaken,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isWarned
                            ? Colors.amber
                            : (isSummoned
                                ? AppColors.alertRed
                                : (isEscalated ? Colors.purpleAccent : AppColors.brightGreen)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Grid: [ SUMMON DESK ], [ WARN ], [ ACKNOWLEDGE / ESCALATE ]
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                label: 'Summon Desk',
                icon: Icons.person_pin_circle_rounded,
                color: AppColors.alertRed,
                onTap: () {
                  focusGuard.summonStudentToDesk(violation.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.alertRed,
                      content: Text('🚨 Urgent summon notice sent to ${violation.studentName}'),
                    ),
                  );
                },
              ),
              _buildActionButton(
                label: 'Send Warning',
                icon: Icons.warning_amber_rounded,
                color: Colors.amber,
                onTap: () {
                  focusGuard.sendWarningToStudent(violation.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.deepNavy,
                      content: Text('⚠️ Screen warning sent to ${violation.studentName}'),
                    ),
                  );
                },
              ),
              if (isNew || isWarned || isSummoned)
                _buildActionButton(
                  label: 'Acknowledge',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.brightGreen,
                  onTap: () {
                    focusGuard.acknowledgeViolation(violation.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Violation #${violation.id} marked as acknowledged.'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  },
                ),
              _buildActionButton(
                label: 'Escalate HOD',
                icon: Icons.shield_outlined,
                color: Colors.purpleAccent,
                onTap: () => _showEscalateModal(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
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
    );
  }

  void _showEscalateModal(BuildContext context) {
    final noteController = TextEditingController(text: 'Repeated classroom mobile usage violation.');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escalate Violation to HOD',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Formal disciplinary escalation for ${violation.studentName} (${violation.studentId})',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Faculty Escalation Note',
                  labelStyle: const TextStyle(color: AppColors.brightCyan),
                  filled: true,
                  fillColor: AppColors.darkNavy,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    focusGuard.escalateViolation(violation.id, noteController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔺 Violation escalated to Head of Department.'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Confirm Escalation to HOD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
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
