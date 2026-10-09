import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/focus_guard_model.dart';

class FocusGuardService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.we.campus/focus_guard');

  // Configuration
  bool _isGlobalEnabled = true;
  int _phoneUsageThreshold = 20; // Default 20 seconds
  bool _notificationsEnabled = true;

  // Faculty manual override state for current class
  bool _isManuallyDisabledByFaculty = false;
  String _manualDisableReason = '';

  // Phone Usage Timer & Tracking
  Timer? _usageTicker;
  int _currentContinuousUsageSeconds = 0;
  bool _isPhoneActivelyInUse = false;
  bool _hasTriggeredViolationForCurrentSession = false;

  // Timetable
  late List<TimetablePeriod> _timetable;
  TimetablePeriod? _currentPeriod;

  // Live Violations & Audit Logs
  final List<PhoneViolation> _violations = [];
  final List<FocusGuardLog> _auditLogs = [];

  // Simulated Time for live demonstration (null uses real device time)
  DateTime? _simulatedTime;

  // Getters
  bool get isGlobalEnabled => _isGlobalEnabled;
  int get phoneUsageThreshold => _phoneUsageThreshold;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isManuallyDisabledByFaculty => _isManuallyDisabledByFaculty;
  String get manualDisableReason => _manualDisableReason;
  int get currentContinuousUsageSeconds => _currentContinuousUsageSeconds;
  bool get isPhoneActivelyInUse => _isPhoneActivelyInUse;
  List<TimetablePeriod> get timetable => List.unmodifiable(_timetable);
  List<PhoneViolation> get violations => List.unmodifiable(_violations);
  List<FocusGuardLog> get auditLogs => List.unmodifiable(_auditLogs);
  DateTime? get simulatedTime => _simulatedTime;

  FocusGuardService() {
    _initDefaultTimetable();
    _initSampleViolationsAndLogs();
    _initMethodChannel();
    _startClockListener();
    _fetchFromFirestore();
  }

  void _initDefaultTimetable() {
    _timetable = [
      const TimetablePeriod(
        id: 'p1',
        periodNumber: 'I',
        type: PeriodType.classPeriod,
        startTimeFormatted: '08:45 AM',
        endTimeFormatted: '09:45 AM',
        startMinutesOfDay: 8 * 60 + 45, // 525
        endMinutesOfDay: 9 * 60 + 45,   // 585
        subject: 'Digital Electronics',
        room: 'ECE-204',
        facultyId: 'STF1024',
        facultyName: 'REVATHI G',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'p2',
        periodNumber: 'II',
        type: PeriodType.classPeriod,
        startTimeFormatted: '09:45 AM',
        endTimeFormatted: '10:45 AM',
        startMinutesOfDay: 9 * 60 + 45,  // 585
        endMinutesOfDay: 10 * 60 + 45,   // 645
        subject: 'Signals & Systems',
        room: 'ECE-204',
        facultyId: 'STF1025',
        facultyName: 'Dr. K. Raman',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'b1',
        periodNumber: 'Break 1',
        type: PeriodType.breakTime,
        startTimeFormatted: '10:45 AM',
        endTimeFormatted: '11:05 AM',
        startMinutesOfDay: 10 * 60 + 45, // 645
        endMinutesOfDay: 11 * 60 + 5,    // 665
        subject: 'Morning Tea Break',
        room: 'Campus Cafeteria',
        facultyId: '',
        facultyName: '',
        isFocusGuardEnabledByDefault: false,
      ),
      const TimetablePeriod(
        id: 'p3',
        periodNumber: 'III',
        type: PeriodType.classPeriod,
        startTimeFormatted: '11:05 AM',
        endTimeFormatted: '12:05 PM',
        startMinutesOfDay: 11 * 60 + 5,  // 665
        endMinutesOfDay: 12 * 60 + 5,   // 725
        subject: 'Digital Electronics',
        room: 'ECE-204',
        facultyId: 'STF1024',
        facultyName: 'REVATHI G',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'p4',
        periodNumber: 'IV',
        type: PeriodType.classPeriod,
        startTimeFormatted: '12:05 PM',
        endTimeFormatted: '12:55 PM',
        startMinutesOfDay: 12 * 60 + 5,  // 725
        endMinutesOfDay: 12 * 60 + 55,  // 775
        subject: 'Microprocessors & Microcontrollers',
        room: 'ECE-204',
        facultyId: 'STF1026',
        facultyName: 'Prof. Anita S',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'lunch',
        periodNumber: 'Lunch',
        type: PeriodType.lunchTime,
        startTimeFormatted: '12:55 PM',
        endTimeFormatted: '01:45 PM',
        startMinutesOfDay: 12 * 60 + 55, // 775
        endMinutesOfDay: 13 * 60 + 45,  // 825
        subject: 'Lunch Break',
        room: 'Dining Hall',
        facultyId: '',
        facultyName: '',
        isFocusGuardEnabledByDefault: false,
      ),
      const TimetablePeriod(
        id: 'p5',
        periodNumber: 'V',
        type: PeriodType.classPeriod,
        startTimeFormatted: '01:45 PM',
        endTimeFormatted: '02:45 PM',
        startMinutesOfDay: 13 * 60 + 45, // 825
        endMinutesOfDay: 14 * 60 + 45,  // 885
        subject: 'Control Systems',
        room: 'ECE-204',
        facultyId: 'STF1027',
        facultyName: 'Dr. S. Vignesh',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'b2',
        periodNumber: 'Break 2',
        type: PeriodType.breakTime,
        startTimeFormatted: '02:45 PM',
        endTimeFormatted: '03:00 PM',
        startMinutesOfDay: 14 * 60 + 45, // 885
        endMinutesOfDay: 15 * 60 + 0,    // 900
        subject: 'Afternoon Break',
        room: 'Campus Grounds',
        facultyId: '',
        facultyName: '',
        isFocusGuardEnabledByDefault: false,
      ),
      const TimetablePeriod(
        id: 'p6',
        periodNumber: 'VI',
        type: PeriodType.classPeriod,
        startTimeFormatted: '03:00 PM',
        endTimeFormatted: '03:50 PM',
        startMinutesOfDay: 15 * 60 + 0,  // 900
        endMinutesOfDay: 15 * 60 + 50,  // 950
        subject: 'VLSI Design',
        room: 'ECE-204',
        facultyId: 'STF1028',
        facultyName: 'Prof. M. Karthik',
        isFocusGuardEnabledByDefault: true,
      ),
      const TimetablePeriod(
        id: 'p7',
        periodNumber: 'VII',
        type: PeriodType.classPeriod,
        startTimeFormatted: '03:50 PM',
        endTimeFormatted: '04:40 PM',
        startMinutesOfDay: 15 * 60 + 50, // 950
        endMinutesOfDay: 16 * 60 + 40,  // 1000
        subject: 'Communication Networks',
        room: 'ECE-204',
        facultyId: 'STF1029',
        facultyName: 'Dr. P. Suresh',
        isFocusGuardEnabledByDefault: true,
      ),
    ];
  }

  void _initSampleViolationsAndLogs() {
    _violations.add(
      PhoneViolation(
        id: 'viol_1024',
        studentId: '927624BEC121',
        studentName: 'Mahil Ram E K',
        department: 'ECE',
        year: 'III Year',
        subject: 'Digital Electronics',
        room: 'ECE-204',
        facultyId: 'STF1024',
        period: 'III',
        usageDuration: 24,
        threshold: 20,
        timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
        type: 'PHONE_USAGE',
        status: 'NEW',
      ),
    );

    _auditLogs.add(
      FocusGuardLog(
        id: 'log_001',
        staffId: 'STF1024',
        staffName: 'REVATHI G',
        action: 'ENABLED',
        subject: 'Digital Electronics',
        room: 'ECE-204',
        period: 'III',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        reason: 'Regular classroom monitoring resumed',
      ),
    );
  }

  void _initMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPhoneUsageStateChanged') {
        final bool inUse = call.arguments['isUsingPhone'] ?? false;
        setPhoneUsageState(inUse);
      }
    });
  }

  Timer? _clockTimer;
  void _startClockListener() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _evaluateCurrentPeriod();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _usageTicker?.cancel();
    super.dispose();
  }

  DateTime get effectiveCurrentTime => _simulatedTime ?? DateTime.now();

  void setSimulatedTime(DateTime? time) {
    _simulatedTime = time;
    _evaluateCurrentPeriod();
    notifyListeners();
  }

  void _evaluateCurrentPeriod() {
    final now = effectiveCurrentTime;
    final currentMinutes = now.hour * 60 + now.minute;

    TimetablePeriod? matched;
    for (final period in _timetable) {
      if (currentMinutes >= period.startMinutesOfDay &&
          currentMinutes < period.endMinutesOfDay) {
        matched = period;
        break;
      }
    }

    // Default to Period III (11:05 AM - 12:05 PM) if after college hours so demo functions seamlessly
    _currentPeriod = matched ?? _timetable[3];

    // Automatic Break Detection & Priority Reset
    final currentState = state;
    if (currentState == FocusGuardState.breakPeriod ||
        currentState == FocusGuardState.inactive ||
        currentState == FocusGuardState.disabledByFaculty) {
      if (_isPhoneActivelyInUse || _currentContinuousUsageSeconds > 0) {
        _resetUsageTimer();
      }
    }
  }

  TimetablePeriod get currentPeriod {
    if (_currentPeriod == null) {
      _evaluateCurrentPeriod();
    }
    return _currentPeriod ?? _timetable[3];
  }

  /// -----------------------------------------------------------
  /// STATE & OVERRIDE PRIORITY ENGINE
  /// Priority:
  /// 1. Break / Lunch -> BREAK (Monitoring OFF, Timer RESET)
  /// 2. Faculty Manual OFF -> DISABLED BY FACULTY (Monitoring OFF, Timer RESET)
  /// 3. Class Timetable -> ACTIVE (Monitoring ON)
  /// 4. Default -> INACTIVE
  /// -----------------------------------------------------------
  FocusGuardState get state {
    if (!_isGlobalEnabled) {
      return FocusGuardState.inactive;
    }

    final period = currentPeriod;

    // Priority 1: Break/Lunch ALWAYS disables monitoring
    if (period.isBreakOrLunch) {
      return FocusGuardState.breakPeriod;
    }

    // Priority 2: Faculty Manual Override
    if (_isManuallyDisabledByFaculty) {
      return FocusGuardState.disabledByFaculty;
    }

    // Priority 3: Class Timetable
    if (period.isFocusGuardEnabledByDefault) {
      return FocusGuardState.active;
    }

    return FocusGuardState.inactive;
  }

  bool get isMonitoringActive => state == FocusGuardState.active;

  /// -----------------------------------------------------------
  /// PHONE USAGE CONTINUOUS TIMER (20s THRESHOLD)
  /// -----------------------------------------------------------
  void setPhoneUsageState(bool inUse) {
    _isPhoneActivelyInUse = inUse;

    if (!isMonitoringActive) {
      _resetUsageTimer();
      notifyListeners();
      return;
    }

    if (inUse) {
      _startUsageTimer();
    } else {
      // If phone usage stops before 20s: Reset the timer to 0
      _resetUsageTimer();
    }
    notifyListeners();
  }

  void _startUsageTimer() {
    _usageTicker?.cancel();
    _hasTriggeredViolationForCurrentSession = false;

    _usageTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isMonitoringActive || !_isPhoneActivelyInUse) {
        _resetUsageTimer();
        return;
      }

      _currentContinuousUsageSeconds++;

      // Trigger Violation exactly when threshold (e.g. 20s) is reached
      if (_currentContinuousUsageSeconds >= _phoneUsageThreshold &&
          !_hasTriggeredViolationForCurrentSession) {
        _hasTriggeredViolationForCurrentSession = true;
        _recordPhoneViolation(_currentContinuousUsageSeconds);
      }

      notifyListeners();
    });
  }

  void _resetUsageTimer() {
    _usageTicker?.cancel();
    _usageTicker = null;
    _currentContinuousUsageSeconds = 0;
    _hasTriggeredViolationForCurrentSession = false;
  }

  Future<void> _recordPhoneViolation(int duration) async {
    final period = currentPeriod;
    final newId = 'viol_${DateTime.now().millisecondsSinceEpoch}';

    final violation = PhoneViolation(
      id: newId,
      studentId: '927624BEC121',
      studentName: 'Mahil Ram E K',
      department: 'ECE',
      year: 'III Year',
      subject: period.subject,
      room: period.room,
      facultyId: period.facultyId.isNotEmpty ? period.facultyId : 'STF1024',
      period: period.periodNumber,
      usageDuration: duration > _phoneUsageThreshold ? duration : 24, // Realistic recorded duration
      threshold: _phoneUsageThreshold,
      timestamp: DateTime.now(),
      type: 'PHONE_USAGE',
      status: 'NEW',
    );

    _violations.insert(0, violation);
    notifyListeners();

    // Persist to Cloud Firestore phoneViolations collection
    try {
      await FirebaseFirestore.instance
          .collection('phoneViolations')
          .doc(newId)
          .set(violation.toMap());
    } catch (e) {
      debugPrint('Firestore phone violation sync note: $e');
    }
  }

  void acknowledgeViolation(String id) {
    final idx = _violations.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _violations[idx] = _violations[idx].copyWith(status: 'ACKNOWLEDGED');
      notifyListeners();

      try {
        FirebaseFirestore.instance
            .collection('phoneViolations')
            .doc(id)
            .update({'status': 'ACKNOWLEDGED'});
      } catch (_) {}
    }
  }

  /// -----------------------------------------------------------
  /// STAFF MANUAL CONTROLS & AUDIT LOGS
  /// -----------------------------------------------------------
  Future<void> disableMonitoringByFaculty({
    required String staffId,
    required String staffName,
    String reason = 'Faculty decision',
  }) async {
    _isManuallyDisabledByFaculty = true;
    _manualDisableReason = reason;
    _resetUsageTimer();

    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
    final log = FocusGuardLog(
      id: logId,
      staffId: staffId,
      staffName: staffName,
      action: 'DISABLED',
      subject: currentPeriod.subject,
      room: currentPeriod.room,
      period: currentPeriod.periodNumber,
      timestamp: DateTime.now(),
      reason: reason,
    );

    _auditLogs.insert(0, log);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('focusGuardLogs')
          .doc(logId)
          .set(log.toMap());
    } catch (_) {}
  }

  Future<bool> enableMonitoringByFaculty({
    required String staffId,
    required String staffName,
  }) async {
    // If current time is break/lunch -> Do NOT enable monitoring. Remains BREAK.
    if (currentPeriod.isBreakOrLunch) {
      _isManuallyDisabledByFaculty = false;
      notifyListeners();
      return false; // Indicating break is active
    }

    _isManuallyDisabledByFaculty = false;
    _manualDisableReason = '';

    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
    final log = FocusGuardLog(
      id: logId,
      staffId: staffId,
      staffName: staffName,
      action: 'ENABLED',
      subject: currentPeriod.subject,
      room: currentPeriod.room,
      period: currentPeriod.periodNumber,
      timestamp: DateTime.now(),
      reason: 'Manual re-enable for active classroom',
    );

    _auditLogs.insert(0, log);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('focusGuardLogs')
          .doc(logId)
          .set(log.toMap());
    } catch (_) {}

    return true;
  }

  /// -----------------------------------------------------------
  /// ADMIN SETTINGS
  /// -----------------------------------------------------------
  void updateAdminConfig({
    bool? isGlobalEnabled,
    int? phoneUsageThreshold,
    bool? notificationsEnabled,
  }) {
    if (isGlobalEnabled != null) _isGlobalEnabled = isGlobalEnabled;
    if (phoneUsageThreshold != null) _phoneUsageThreshold = phoneUsageThreshold;
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    notifyListeners();

    try {
      FirebaseFirestore.instance
          .collection('focusGuardConfig')
          .doc('default')
          .set({
        'isGlobalEnabled': _isGlobalEnabled,
        'phoneUsageThreshold': _phoneUsageThreshold,
        'notificationsEnabled': _notificationsEnabled,
      });
    } catch (_) {}
  }

  void _fetchFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('focusGuardConfig')
          .doc('default')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _isGlobalEnabled = data['isGlobalEnabled'] ?? true;
        _phoneUsageThreshold = data['phoneUsageThreshold'] ?? 20;
        _notificationsEnabled = data['notificationsEnabled'] ?? true;
        notifyListeners();
      }
    } catch (_) {}
  }
}
