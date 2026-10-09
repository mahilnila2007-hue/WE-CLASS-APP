import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/focus_guard_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'staff_home_tab.dart';
import 'staff_attendance_tab.dart';
import 'staff_complaints_tab.dart';
import 'staff_alerts_tab.dart';
import 'staff_profile_tab.dart';

class StaffMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const StaffMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusGuard = Provider.of<FocusGuardService>(context);
    final unreadCount = focusGuard.unacknowledgedCount;
    final urgentAlert = focusGuard.latestUrgentAlert;

    final List<Widget> tabs = [
      StaffHomeTab(onNavigateTab: _onTabTapped),
      const StaffAttendanceTab(),
      const StaffComplaintsTab(),
      const StaffAlertsTab(),
      const StaffProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),

          // 🚨 GLOBAL HEADS-UP TRIGGER ALERT BANNER
          if (urgentAlert != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A0808), Color(0xFF1A0A2A), Color(0xFF0F1535)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.alertRed.withOpacity(0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.alertRed.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.alertRed),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.alertRed,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'PHONE VIOLATION TRIGGERED',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.alertRed,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.alertRed,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${urgentAlert.usageDuration}s Active',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${urgentAlert.studentName} (${urgentAlert.studentId})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${urgentAlert.room} • ${urgentAlert.subject}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () => focusGuard.dismissUrgentAlert(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                focusGuard.summonStudentToDesk(urgentAlert.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.alertRed,
                                    content: Text('🚨 Summon notice dispatched to ${urgentAlert.studentName}'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_pin_circle_rounded, size: 14),
                              label: const Text('Summon Desk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.alertRed.withOpacity(0.25),
                                foregroundColor: AppColors.alertRed,
                                elevation: 0,
                                side: BorderSide(color: AppColors.alertRed.withOpacity(0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                focusGuard.sendWarningToStudent(urgentAlert.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.deepNavy,
                                    content: Text('⚠️ Warning broadcast sent to ${urgentAlert.studentName}'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.warning_amber_rounded, size: 14),
                              label: const Text('Warn Student', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.electricBlue.withOpacity(0.25),
                                foregroundColor: AppColors.brightCyan,
                                elevation: 0,
                                side: BorderSide(color: AppColors.brightCyan.withOpacity(0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              focusGuard.dismissUrgentAlert();
                              _onTabTapped(3); // Jump to Alerts tab
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -0.5, end: 0, duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const CustomNavItem(icon: Icons.home_rounded, label: 'Home'),
          const CustomNavItem(icon: Icons.calendar_month_rounded, label: 'Attendance'),
          const CustomNavItem(icon: Icons.handyman_rounded, label: 'Complaints'),
          CustomNavItem(
            icon: Icons.notifications_active_rounded,
            label: 'Alerts',
            badgeCount: unreadCount,
          ),
          const CustomNavItem(icon: Icons.badge_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
