import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/focus_guard_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/focus_guard_violation_card.dart';
import '../../widgets/focus_guard_admin_modal.dart';

class StaffAlertsTab extends StatefulWidget {
  const StaffAlertsTab({super.key});

  @override
  State<StaffAlertsTab> createState() => _StaffAlertsTabState();
}

class _StaffAlertsTabState extends State<StaffAlertsTab> {
  String _selectedFilter = 'ALL'; // 'ALL', 'UNACK', 'CRITICAL', 'RESOLVED'

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);
    final allViolations = focusGuard.violations;

    final filteredViolations = allViolations.where((v) {
      if (_selectedFilter == 'UNACK') return v.status != 'ACKNOWLEDGED';
      if (_selectedFilter == 'CRITICAL') return v.urgency == 'CRITICAL' || v.usageDuration >= 30;
      if (_selectedFilter == 'RESOLVED') return v.status == 'ACKNOWLEDGED';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Trigger Settings & Sound Toggles
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
                          'Classroom phone violations & live telemetry',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Haptic / Sound Toggle Button
                      GestureDetector(
                        onTap: () {
                          focusGuard.toggleHaptic(!focusGuard.hapticEnabled);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(focusGuard.hapticEnabled ? '📳 Haptic trigger alerts enabled' : '📴 Haptic trigger alerts muted'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.deepNavy,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: focusGuard.hapticEnabled
                                ? AppColors.alertRed.withOpacity(0.18)
                                : AppColors.deepNavy,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: focusGuard.hapticEnabled
                                  ? AppColors.alertRed
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Icon(
                            focusGuard.hapticEnabled
                                ? Icons.vibration_rounded
                                : Icons.phonelink_ring_rounded,
                            color: focusGuard.hapticEnabled
                                ? AppColors.alertRed
                                : AppColors.textGrey,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                ],
              ),

              const SizedBox(height: 18),

              // ---------------- LIVE TRIGGER & SIREN TEST CARD ----------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F0C2C), Color(0xFF0F1B3B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.electricBlue.withOpacity(0.5), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      blurRadius: 16,
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.brightCyan.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt_rounded, color: AppColors.brightCyan, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instant Alert Trigger Center',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brightGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brightGreen, width: 0.8),
                          ),
                          child: Text(
                            'TELEMETRY LIVE',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brightGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test faculty siren alarms or dispatch instant simulated phone violations across classroom ECE-204.',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey, height: 1.3),
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
                                duration: 36,
                                urgency: 'CRITICAL',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.alertRed,
                                  content: Text('🚨 Live 36s violation triggered! Heads-up banner & haptic siren dispatched.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.warning_amber_rounded, size: 16),
                            label: const Text('Trigger Test Siren', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.alertRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            focusGuard.setPhoneUsageState(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.deepNavy,
                                content: Text('📱 Continuous 20s counter started on student device.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.timer_outlined, size: 16),
                          label: const Text('Start 20s', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricBlue.withOpacity(0.3),
                            foregroundColor: AppColors.brightCyan,
                            side: const BorderSide(color: AppColors.brightCyan),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 20),

              // ---------------- FILTER CHIPS ROW ----------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All (${allViolations.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('UNACK', '🚨 Pending (${focusGuard.unacknowledgedCount})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('CRITICAL', '🔥 Critical'),
                    const SizedBox(width: 8),
                    _buildFilterChip('RESOLVED', '✔️ Resolved'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- VIOLATIONS LIST ----------------
              if (filteredViolations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.brightGreen, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'No violations matching this filter.',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        Text(
                          'Use the Trigger Center above to simulate a live event.',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredViolations.map((violation) {
                  return FocusGuardViolationStaffCard(
                    violation: violation,
                    focusGuard: focusGuard,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.04, end: 0);
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

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (key == 'UNACK'
                  ? AppColors.alertRed
                  : (key == 'CRITICAL' ? Colors.purpleAccent : AppColors.electricBlue))
              : AppColors.deepNavy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (key == 'UNACK' ? AppColors.alertRed : AppColors.electricBlue).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}
