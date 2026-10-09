import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/focus_guard_model.dart';
import '../services/auth_service.dart';
import '../services/focus_guard_service.dart';
import 'gradient_card.dart';

class FocusGuardStaffCard extends StatelessWidget {
  const FocusGuardStaffCard({super.key});

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);
    final auth = Provider.of<AuthService>(context);
    final staff = auth.currentUser ?? AuthService.defaultStaff;
    final period = focusGuard.currentPeriod;
    final state = focusGuard.state;

    return GradientCard(
      solidColor: AppColors.deepNavy,
      borderRadius: 26,
      padding: const EdgeInsets.all(22),
      border: Border.all(
        color: state == FocusGuardState.active
            ? AppColors.violet.withOpacity(0.4)
            : AppColors.borderLight,
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FocusGuard Control',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              _buildStatePill(state),
            ],
          ),

          const SizedBox(height: 16),

          // Current Class Info Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.subject,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${period.room} • Period ${period.periodNumber} (${period.timeRange})',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${focusGuard.violations.where((v) => v.status == "NEW").length} Alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.alertRed,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dynamic Action / Status State Rendering
          if (state == FocusGuardState.active) ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '🟢 Monitoring active for all student devices in ${period.room}.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brightGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      label: 'PAUSE',
                      gradient: AppColors.orangeGradient,
                      onTap: () => _showDisableDialog(context, focusGuard, staff.displayId, staff.name),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          focusGuard.triggerLiveSimulatedViolation(
                            studentName: 'Mahil Ram E K',
                            studentId: '927624BEC121',
                            duration: 25,
                            urgency: 'HIGH',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.alertRed,
                              content: Text('🚨 25s mobile usage violation triggered on faculty screen!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_active_rounded, size: 14),
                        label: const Text('Test Live Alert Siren', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed.withOpacity(0.2),
                          foregroundColor: AppColors.alertRed,
                          side: const BorderSide(color: AppColors.alertRed),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else if (state == FocusGuardState.disabledByFaculty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring temporarily paused by faculty (${focusGuard.manualDisableReason.isNotEmpty ? focusGuard.manualDisableReason : "Faculty decision"}).',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    label: 'START CLASS MONITORING',
                    gradient: AppColors.primaryGradient,
                    onTap: () async {
                      final enabled = await focusGuard.enableMonitoringByFaculty(
                        staffId: staff.displayId,
                        staffName: staff.name,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              enabled ? '🟢 Classroom monitoring active across student devices.' : 'Break time active.',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: enabled ? AppColors.brightGreen : AppColors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ] else if (state == FocusGuardState.breakPeriod) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.coffee_rounded, color: AppColors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monitoring automatically disabled during break',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Resumes: ${period.endTimeFormatted}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatePill(FocusGuardState state) {
    Color color;
    String text;

    switch (state) {
      case FocusGuardState.active:
        color = AppColors.brightGreen;
        text = '● ACTIVE';
        break;
      case FocusGuardState.breakPeriod:
        color = AppColors.orange;
        text = '○ BREAK';
        break;
      case FocusGuardState.disabledByFaculty:
        color = AppColors.secondaryGrey;
        text = '○ DISABLED BY FACULTY';
        break;
      case FocusGuardState.inactive:
        color = AppColors.secondaryGrey;
        text = '○ INACTIVE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDisableDialog(
    BuildContext context,
    FocusGuardService focusGuard,
    String staffId,
    String staffName,
  ) {
    String selectedReason = 'Educational activity';
    final reasons = [
      'Educational activity',
      'Practical session',
      'Guest lecture',
      'Examination',
      'Faculty decision',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              title: Text(
                'Disable FocusGuard?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disable mobile usage monitoring for this class?',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SELECT REASON:',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brightCyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    dropdownColor: AppColors.darkNavy,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: reasons.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedReason = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    focusGuard.disableMonitoringByFaculty(
                      staffId: staffId,
                      staffName: staffName,
                      reason: selectedReason,
                    );
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(
                    'DISABLE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
