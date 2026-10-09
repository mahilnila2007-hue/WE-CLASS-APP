import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/campus_data_service.dart';
import 'services/focus_guard_service.dart';
import 'screens/auth/login_selection_screen.dart';
import 'screens/student/student_main_screen.dart';
import 'screens/staff/staff_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for dark immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bottomNavBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(const WeCampusApp());
}

class WeCampusApp extends StatelessWidget {
  const WeCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CampusDataService()),
        ChangeNotifierProvider(create: (_) => FocusGuardService()),
      ],
      child: MaterialApp(
        title: 'WE - One Campus. One Connected System.',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGatekeeper(),
      ),
    );
  }
}

class AuthGatekeeper extends StatelessWidget {
  const AuthGatekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAuthenticated) {
      return const LoginSelectionScreen();
    }

    final user = authService.currentUser!;
    if (user.isStaff) {
      return const StaffMainScreen();
    } else {
      return const StudentMainScreen();
    }
  }
}
