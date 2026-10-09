import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_campus/services/auth_service.dart';
import 'package:we_campus/services/campus_data_service.dart';
import 'package:we_campus/models/complaint_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Student login authenticates default student profile', () async {
      final auth = AuthService();
      final ok = await auth.loginStudent(
        studentIdOrEmail: '927624BEC121',
        password: 'student@123',
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.name, 'Mahil Ram E K');
      expect(auth.currentUser?.studentId, '927624BEC121');
      expect(auth.currentUser?.isStudent, isTrue);
    });

    test('Staff login authenticates default staff profile', () async {
      final auth = AuthService();
      final ok = await auth.loginStaff(
        staffIdOrEmail: 'STF1024',
        password: 'staff@123',
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.name, 'REVATHI G');
      expect(auth.currentUser?.staffId, 'STF1024');
      expect(auth.currentUser?.isStaff, isTrue);
    });
  });

  group('CampusDataService Tests', () {
    test('Student attendance calculation & geofence simulation', () {
      final data = CampusDataService();
      final overview = data.studentAttendanceOverview;

      expect(overview.present, 42);
      expect(overview.absent, 6);
      expect(overview.total, 48);
      expect(overview.percentageString, '88%');
      expect(overview.riskLevel, 'LOW RISK');
      expect(overview.isPresentToday, isTrue);

      data.toggleLocationSimulation();
      final toggled = data.studentAttendanceOverview;
      expect(toggled.isPresentToday, isFalse);
      expect(toggled.todayLocation, 'Outside Campus Area');
    });

    test('Blood donor filters match exact blood group', () {
      final data = CampusDataService();
      data.setBloodFilter('O+');
      final oPlusDonors = data.filteredDonors;
      expect(oPlusDonors.every((d) => d.bloodGroup == 'O+'), isTrue);

      data.setBloodFilter('ALL');
      expect(data.filteredDonors.length, greaterThan(3));
    });

    test('AI Complaint Analyzer categorizes electrical and plumbing issues correctly', () {
      final data = CampusDataService();

      final aiElec = data.analyzeComplaint(
        title: 'Switchboard sparking in Lab 304',
        description: 'Smoke coming from socket',
        location: 'Block 4',
      );
      expect(aiElec.category, 'Electrical');
      expect(aiElec.severity, 'HIGH');
      expect(aiElec.priority, 'CRITICAL');
      expect(aiElec.assignedDepartment, 'Electrical Maintenance');

      final aiPlumb = data.analyzeComplaint(
        title: 'Water tap leaking',
        description: 'Continuous water drip in restroom',
        location: 'Main Block',
      );
      expect(aiPlumb.category, 'Plumbing');
      expect(aiPlumb.assignedDepartment, 'Civil & Plumbing Maintenance');
    });

    test('Submitting new complaint adds it to tracking list and retains photo evidence', () async {
      final data = CampusDataService();
      final countBefore = data.allComplaints.length;

      final newComplaint = await data.submitComplaint(
        title: 'Projector not powering on',
        description: 'HDMI cable and power socket unresponsive',
        location: 'Room 202',
        reporterName: 'Mahil Ram E K',
        reporterId: '927624BEC121',
        imagePath: 'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      expect(data.allComplaints.length, countBefore + 1);
      expect(newComplaint.status, ComplaintStatus.analyzing);
      expect(newComplaint.imagePath, isNotNull);
      expect(data.allComplaints.first.id, newComplaint.id);

      final map = newComplaint.toMap();
      final reconstituted = CampusComplaint.fromMap(map, newComplaint.id);
      expect(reconstituted.imagePath, newComplaint.imagePath);
      expect(reconstituted.title, newComplaint.title);
    });
  });
}
