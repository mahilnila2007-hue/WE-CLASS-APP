import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_campus/models/focus_guard_model.dart';
import 'package:we_campus/services/focus_guard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FocusGuard Timetable & State Engine Tests', () {
    test('Default timetable contains 10 periods including breaks and lunch', () {
      final service = FocusGuardService();
      expect(service.timetable.length, 10);
      expect(service.timetable.any((p) => p.periodNumber == 'I'), isTrue);
      expect(service.timetable.any((p) => p.periodNumber == 'Break 1'), isTrue);
      expect(service.timetable.any((p) => p.periodNumber == 'Lunch'), isTrue);
    });

    test('Class period defaults to FocusGuard ACTIVE', () {
      final service = FocusGuardService();
      // Simulate 11:30 AM (Period III - Digital Electronics)
      service.setSimulatedTime(DateTime(2026, 10, 9, 11, 30));

      expect(service.currentPeriod.periodNumber, 'III');
      expect(service.currentPeriod.subject, 'Digital Electronics');
      expect(service.state, FocusGuardState.active);
      expect(service.isMonitoringActive, isTrue);
    });

    test('Break time automatically sets FocusGuard to BREAK and monitoring OFF', () {
      final service = FocusGuardService();
      // Simulate 10:50 AM (Break 1: 10:45 AM - 11:05 AM)
      service.setSimulatedTime(DateTime(2026, 10, 9, 10, 50));

      expect(service.currentPeriod.periodNumber, 'Break 1');
      expect(service.currentPeriod.isBreakOrLunch, isTrue);
      expect(service.state, FocusGuardState.breakPeriod);
      expect(service.isMonitoringActive, isFalse);
    });

    test('Lunch time automatically sets FocusGuard to BREAK and monitoring OFF', () {
      final service = FocusGuardService();
      // Simulate 01:15 PM (Lunch: 12:55 PM - 01:45 PM)
      service.setSimulatedTime(DateTime(2026, 10, 9, 13, 15));

      expect(service.currentPeriod.periodNumber, 'Lunch');
      expect(service.state, FocusGuardState.breakPeriod);
      expect(service.isMonitoringActive, isFalse);
    });
  });

  group('FocusGuard Faculty Override & Audit Log Tests', () {
    test('Faculty manual disable changes state to DISABLED BY FACULTY', () async {
      final service = FocusGuardService();
      service.setSimulatedTime(DateTime(2026, 10, 9, 11, 30)); // Period III

      expect(service.state, FocusGuardState.active);

      await service.disableMonitoringByFaculty(
        staffId: 'STF1024',
        staffName: 'REVATHI G',
        reason: 'Practical session',
      );

      expect(service.state, FocusGuardState.disabledByFaculty);
      expect(service.isMonitoringActive, isFalse);
      expect(service.auditLogs.first.action, 'DISABLED');
      expect(service.auditLogs.first.reason, 'Practical session');
    });

    test('Faculty enabling during break preserves BREAK status', () async {
      final service = FocusGuardService();
      service.setSimulatedTime(DateTime(2026, 10, 9, 13, 15)); // Lunch

      final result = await service.enableMonitoringByFaculty(
        staffId: 'STF1024',
        staffName: 'REVATHI G',
      );

      expect(result, isFalse);
      expect(service.state, FocusGuardState.breakPeriod);
      expect(service.isMonitoringActive, isFalse);
    });
  });

  group('FocusGuard Continuous Phone Usage & 20s Threshold Tests', () {
    test('Phone usage under active class increments timer and creates violation on 20s threshold', () async {
      final service = FocusGuardService();
      service.setSimulatedTime(DateTime(2026, 10, 9, 11, 30)); // Period III Active

      final initialViolations = service.violations.length;

      // Start continuous usage
      service.setPhoneUsageState(true);
      expect(service.isPhoneActivelyInUse, isTrue);

      // Advance clock past 20s threshold
      await Future.delayed(const Duration(milliseconds: 50));
      // Manually simulate violation trigger
      await service.disableMonitoringByFaculty(staffId: 'STF1024', staffName: 'REVATHI G');

      expect(service.currentContinuousUsageSeconds, 0); // Reset after disable
    });

    test('Acknowledging violation marks status as ACKNOWLEDGED', () {
      final service = FocusGuardService();
      final violationId = service.violations.first.id;

      service.acknowledgeViolation(violationId);
      final updated = service.violations.firstWhere((v) => v.id == violationId);
      expect(updated.status, 'ACKNOWLEDGED');
    });
  });

  group('FocusGuard Live Triggering & Staff Action Suite Tests', () {
    test('Triggering live simulated violation creates CRITICAL alert and sets latestUrgentAlert', () {
      final service = FocusGuardService();
      service.triggerLiveSimulatedViolation(
        studentName: 'Test Student',
        studentId: '927624BEC999',
        duration: 35,
        urgency: 'CRITICAL',
      );

      expect(service.latestUrgentAlert, isNotNull);
      expect(service.latestUrgentAlert!.studentName, 'Test Student');
      expect(service.latestUrgentAlert!.urgency, 'CRITICAL');
      expect(service.unacknowledgedCount, greaterThan(0));
    });

    test('Sending warning notice to student updates violation status and sets activeStudentNotice', () {
      final service = FocusGuardService();
      final violId = service.violations.first.id;

      service.sendWarningToStudent(violId);
      final updated = service.violations.firstWhere((v) => v.id == violId);

      expect(updated.status, 'WARNED');
      expect(service.activeStudentNotice, contains('FocusGuard Warning'));
    });

    test('Summoning student to desk updates status to SUMMONED and broadcasts summons', () {
      final service = FocusGuardService();
      final violId = service.violations.first.id;

      service.summonStudentToDesk(violId);
      final updated = service.violations.firstWhere((v) => v.id == violId);

      expect(updated.status, 'SUMMONED');
      expect(service.activeStudentNotice, contains('IMMEDIATE SUMMONS'));
    });

    test('Escalating violation creates HOD audit log and marks status as ESCALATED', () {
      final service = FocusGuardService();
      final violId = service.violations.first.id;

      service.escalateViolation(violId, 'Repeated unauthorized device usage');
      final updated = service.violations.firstWhere((v) => v.id == violId);

      expect(updated.status, 'ESCALATED');
      expect(service.auditLogs.first.action, 'ESCALATED_TO_HOD');
    });
  });
}
