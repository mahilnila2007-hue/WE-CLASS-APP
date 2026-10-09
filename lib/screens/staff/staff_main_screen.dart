import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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
    final List<Widget> tabs = [
      StaffHomeTab(onNavigateTab: _onTabTapped),
      const StaffAttendanceTab(),
      const StaffComplaintsTab(),
      const StaffAlertsTab(),
      const StaffProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          CustomNavItem(icon: Icons.home_rounded, label: 'Home'),
          CustomNavItem(icon: Icons.calendar_month_rounded, label: 'Attendance'),
          CustomNavItem(icon: Icons.handyman_rounded, label: 'Complaints'),
          CustomNavItem(icon: Icons.notifications_active_rounded, label: 'Alerts'),
          CustomNavItem(icon: Icons.badge_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
