import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/focus_guard_model.dart';
import '../services/focus_guard_service.dart';

class FocusGuardAdminModal extends StatelessWidget {
  const FocusGuardAdminModal({super.key});

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FocusGuard Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 16),

              // Setting 1: Global Monitoring Enable/Disable
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.brightCyan,
                title: Text(
                  'Global FocusGuard Monitoring',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Master switch for campus-wide phone usage monitoring',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                ),
                value: focusGuard.isGlobalEnabled,
                onChanged: (val) {
                  focusGuard.updateAdminConfig(isGlobalEnabled: val);
                },
              ),

              const SizedBox(height: 14),

              // Setting 2: Phone Usage Threshold (Default 20s)
              Text(
                'CONTINUOUS USAGE THRESHOLD: ${focusGuard.phoneUsageThreshold} SECONDS',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brightCyan,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Slider(
                value: focusGuard.phoneUsageThreshold.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                activeColor: AppColors.brightCyan,
                inactiveColor: AppColors.darkNavy,
                label: '${focusGuard.phoneUsageThreshold}s',
                onChanged: (val) {
                  focusGuard.updateAdminConfig(phoneUsageThreshold: val.toInt());
                },
              ),

              const SizedBox(height: 16),

              // Setting 3: Live Time Simulation for Timetable Testing
              Text(
                'TESTING: TIMETABLE PERIOD SIMULATOR',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Simulate Period:',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                        ),
                        if (focusGuard.simulatedTime != null)
                          TextButton(
                            onPressed: () => focusGuard.setSimulatedTime(null),
                            child: Text(
                              'Reset to Live Clock',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.brightCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTimeChip(
                          label: 'Period I (09:00 AM)',
                          onTap: () => focusGuard.setSimulatedTime(DateTime(2026, 10, 9, 9, 0)),
                          isSelected: focusGuard.effectiveCurrentTime.hour == 9 && focusGuard.effectiveCurrentTime.minute < 45,
                        ),
                        _buildTimeChip(
                          label: 'Break 1 (10:50 AM)',
                          onTap: () => focusGuard.setSimulatedTime(DateTime(2026, 10, 9, 10, 50)),
                          isSelected: focusGuard.effectiveCurrentTime.hour == 10 && focusGuard.effectiveCurrentTime.minute >= 45,
                        ),
                        _buildTimeChip(
                          label: 'Period III (11:30 AM)',
                          onTap: () => focusGuard.setSimulatedTime(DateTime(2026, 10, 9, 11, 30)),
                          isSelected: focusGuard.effectiveCurrentTime.hour == 11 && focusGuard.effectiveCurrentTime.minute >= 5,
                        ),
                        _buildTimeChip(
                          label: 'Lunch (01:15 PM)',
                          onTap: () => focusGuard.setSimulatedTime(DateTime(2026, 10, 9, 13, 15)),
                          isSelected: focusGuard.effectiveCurrentTime.hour == 13,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Timetable Roster Schedule
              Text(
                'COLLEGE TIMETABLE SCHEDULE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textGrey,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              ...focusGuard.timetable.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: p.isBreakOrLunch
                          ? AppColors.orange.withOpacity(0.3)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Period ${p.periodNumber}: ${p.subject}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${p.timeRange} • ${p.room}',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.isBreakOrLunch
                              ? AppColors.orange.withOpacity(0.15)
                              : AppColors.brightGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.isBreakOrLunch ? 'OFF' : 'ON',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: p.isBreakOrLunch ? AppColors.orange : AppColors.brightGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip({
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brightCyan : AppColors.deepNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brightCyan : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.darkNavy : Colors.white,
          ),
        ),
      ),
    );
  }
}
