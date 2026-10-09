import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/focus_guard_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'student_home_tab.dart';
import 'student_attendance_tab.dart';
import 'student_blood_tab.dart';
import 'student_complaints_tab.dart';
import 'student_profile_tab.dart';

class StudentMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const StudentMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> with WidgetsBindingObserver {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final focusGuard = Provider.of<FocusGuardService>(context, listen: false);
      final user = auth.currentUser ?? AuthService.defaultStudent;
      final sid = user.studentId;
      final dept = user.department ?? 'ECE';
      focusGuard.setActiveStudent(
        studentId: (sid != null && sid.isNotEmpty) ? sid : user.displayId,
        name: user.name,
        dept: dept,
      );
      // Auto-start active in-app phone usage tracking
      focusGuard.setPhoneUsageState(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final focusGuard = Provider.of<FocusGuardService>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      focusGuard.setPhoneUsageState(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      focusGuard.setPhoneUsageState(false);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      StudentHomeTab(onNavigateTab: _onTabTapped),
      const StudentAttendanceTab(),
      const StudentBloodTab(),
      const StudentComplaintsTab(),
      const StudentProfileTab(),
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
          CustomNavItem(icon: Icons.bloodtype_rounded, label: 'Blood'),
          CustomNavItem(icon: Icons.report_problem_rounded, label: 'Complaints'),
          CustomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
