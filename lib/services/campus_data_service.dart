import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attendance_model.dart';
import '../models/blood_donor_model.dart';
import '../models/complaint_model.dart';

class CampusDataService extends ChangeNotifier {
  // ---------------- ATTENDANCE DATA ----------------
  bool _isInsideCampus = true;
  final int _presentCount = 42;
  final int _absentCount = 6;
  final double _requiredPercentage = 75.0;

  bool get isInsideCampus => _isInsideCampus;
  int get presentCount => _presentCount;
  int get absentCount => _absentCount;
  int get totalClasses => _presentCount + _absentCount;
  double get attendancePercentage =>
      totalClasses > 0 ? (_presentCount / totalClasses) * 100 : 87.5;

  void toggleLocationSimulation() {
    _isInsideCampus = !_isInsideCampus;
    notifyListeners();
  }

  StudentAttendanceOverview get studentAttendanceOverview {
    final now = DateTime.now();
    final List<DailyAttendanceRecord> sampleDays = [];

    for (int i = 1; i <= 28; i++) {
      final date = DateTime(now.year, now.month, i);
      final weekday = date.weekday;
      DayAttendanceStatus status;

      if (weekday == DateTime.sunday) {
        status = DayAttendanceStatus.holiday;
      } else if (weekday == DateTime.saturday && (i <= 7 || (i > 14 && i <= 21))) {
        status = DayAttendanceStatus.holiday;
      } else if (i == 4 || i == 18) {
        status = DayAttendanceStatus.absent;
      } else if (i == 12) {
        status = DayAttendanceStatus.leave;
      } else {
        status = DayAttendanceStatus.present;
      }

      sampleDays.add(DailyAttendanceRecord(date: date, status: status));
    }

    return StudentAttendanceOverview(
      present: _presentCount,
      absent: _absentCount,
      total: totalClasses,
      requiredPercentage: _requiredPercentage,
      isPresentToday: _isInsideCampus,
      todayLocation: _isInsideCampus ? 'Inside Campus' : 'Outside Campus Area',
      todayTime: _isInsideCampus ? '09:12 AM' : '--:--',
      gpsAccuracy: _isInsideCampus ? '12 m' : '38 m',
      riskLevel: attendancePercentage >= 75 ? 'LOW RISK' : 'HIGH RISK',
      predictionMessage: attendancePercentage >= 75
          ? 'You are currently above the required attendance percentage.'
          : 'Warning: You need more attendances to reach 75%.',
      classesRequiredFor75: attendancePercentage >= 75 ? 0 : 4,
      monthlyRecords: sampleDays,
    );
  }

  // ---------------- BLOOD DONORS ----------------
  String _selectedBloodFilter = 'ALL';
  String _searchDonorQuery = '';

  String get selectedBloodFilter => _selectedBloodFilter;
  String get searchDonorQuery => _searchDonorQuery;

  final List<BloodDonor> _bloodDonors = [
    const BloodDonor(
      id: 'bd_1',
      name: 'ARUN KUMAR',
      department: 'ECE',
      year: 'III YEAR',
      bloodGroup: 'O+',
      isAvailable: true,
      phone: '+919840123456',
      lastDonationDate: '4 months ago',
    ),
    const BloodDonor(
      id: 'bd_2',
      name: 'PRIYA SHARMA',
      department: 'CSE',
      year: 'IV YEAR',
      bloodGroup: 'A+',
      isAvailable: true,
      phone: '+919840234567',
      lastDonationDate: '2 months ago',
    ),
    const BloodDonor(
      id: 'bd_3',
      name: 'KARTHIK RAJAN',
      department: 'MECH',
      year: 'III YEAR',
      bloodGroup: 'B+',
      isAvailable: false,
      phone: '+919840345678',
      lastDonationDate: '1 month ago',
    ),
    const BloodDonor(
      id: 'bd_4',
      name: 'DIVYA BALAN',
      department: 'IT',
      year: 'II YEAR',
      bloodGroup: 'AB+',
      isAvailable: true,
      phone: '+919840456789',
      lastDonationDate: '5 months ago',
    ),
    const BloodDonor(
      id: 'bd_5',
      name: 'SURESH MENON',
      department: 'EEE',
      year: 'IV YEAR',
      bloodGroup: 'O-',
      isAvailable: true,
      phone: '+919840567890',
      lastDonationDate: '3 months ago',
    ),
    const BloodDonor(
      id: 'bd_6',
      name: 'ANANYA IYER',
      department: 'AIDS',
      year: 'III YEAR',
      bloodGroup: 'A-',
      isAvailable: true,
      phone: '+919840678901',
      lastDonationDate: '6 months ago',
    ),
    const BloodDonor(
      id: 'bd_7',
      name: 'VIKRAM VARMA',
      department: 'CIVIL',
      year: 'IV YEAR',
      bloodGroup: 'B-',
      isAvailable: false,
      phone: '+919840789012',
      lastDonationDate: '2 weeks ago',
    ),
    const BloodDonor(
      id: 'bd_8',
      name: 'SNEHA REDDY',
      department: 'BIOTECH',
      year: 'II YEAR',
      bloodGroup: 'AB-',
      isAvailable: true,
      phone: '+919840890123',
      lastDonationDate: '4 months ago',
    ),
  ];

  List<BloodDonor> get filteredDonors {
    return _bloodDonors.where((donor) {
      final matchesGroup = _selectedBloodFilter == 'ALL' ||
          donor.bloodGroup == _selectedBloodFilter;
      final matchesQuery = _searchDonorQuery.isEmpty ||
          donor.name.toLowerCase().contains(_searchDonorQuery.toLowerCase()) ||
          donor.department.toLowerCase().contains(_searchDonorQuery.toLowerCase());
      return matchesGroup && matchesQuery;
    }).toList();
  }

  void setBloodFilter(String group) {
    _selectedBloodFilter = group;
    notifyListeners();
  }

  void setSearchDonorQuery(String query) {
    _searchDonorQuery = query;
    notifyListeners();
  }

  Future<bool> callDonor(BloodDonor donor) async {
    final Uri telUri = Uri(scheme: 'tel', path: donor.phone);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
        return true;
      } else {
        // In simulation/desktop environments, launch url directly or log
        await launchUrl(telUri);
        return true;
      }
    } catch (e) {
      debugPrint('Could not launch dialer: $e');
      return false;
    }
  }

  // ---------------- CAMPUS COMPLAINTS ----------------
  final List<CampusComplaint> _complaints = [
    CampusComplaint(
      id: '#WE1024',
      title: 'Electrical Switchboard Sparking',
      description: 'Main switchboard in Lab 304 sparks when power supplies are turned on.',
      location: 'Block 4, 3rd Floor, Lab 304',
      category: 'Electrical',
      severity: 'HIGH',
      priority: 'CRITICAL',
      assignedDepartment: 'Electrical Maintenance',
      recommendedAction: 'Immediate inspection required. Isolate breaker #4B.',
      status: ComplaintStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      reporterName: 'Mahil Ram E K',
      reporterId: '927624BEC121',
    ),
    CampusComplaint(
      id: '#WE1019',
      title: 'Water Pipe Leakage in Restroom',
      description: 'Continuous leaking from washbasin faucet creating water puddle.',
      location: 'Main Block, 2nd Floor East Wing',
      category: 'Plumbing',
      severity: 'MEDIUM',
      priority: 'HIGH',
      assignedDepartment: 'Civil & Plumbing Maintenance',
      recommendedAction: 'Replace internal valve cartridge and washer gasket.',
      status: ComplaintStatus.assigned,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      reporterName: 'Mahil Ram E K',
      reporterId: '927624BEC121',
    ),
    CampusComplaint(
      id: '#WE0992',
      title: 'Wi-Fi Access Point Offline',
      description: 'Hostel Block C 2nd floor router is blinking red with no connectivity.',
      location: 'Hostel Block C, Corridor 2',
      category: 'Wi-Fi & IT',
      severity: 'LOW',
      priority: 'MEDIUM',
      assignedDepartment: 'Campus IT Infrastructure',
      recommendedAction: 'Reboot PoE switch port and check DHCP lease table.',
      status: ComplaintStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      reporterName: 'Mahil Ram E K',
      reporterId: '927624BEC121',
    ),
  ];

  List<CampusComplaint> get allComplaints => List.unmodifiable(_complaints);

  List<CampusComplaint> get myComplaints =>
      _complaints.where((c) => c.reporterId == '927624BEC121').toList();

  int get activeComplaintsCount =>
      _complaints.where((c) => c.status != ComplaintStatus.resolved && c.status != ComplaintStatus.closed).length;

  int get criticalComplaintsCount =>
      _complaints.where((c) => c.priority == 'CRITICAL' && c.status != ComplaintStatus.closed).length;

  // AI Complaint Analyzer
  AIAnalysisResult analyzeComplaint({
    required String title,
    required String description,
    required String location,
  }) {
    final combined = '$title $description $location'.toLowerCase();

    String category = 'General Infrastructure';
    String severity = 'MEDIUM';
    String priority = 'HIGH';
    String assignedDept = 'Campus Facility Services';
    String recommendedAction = 'Schedule routine site evaluation.';

    if (combined.contains('spark') ||
        combined.contains('electric') ||
        combined.contains('wire') ||
        combined.contains('switch') ||
        combined.contains('power') ||
        combined.contains('short circuit') ||
        combined.contains('shock') ||
        combined.contains('ac') ||
        combined.contains('light')) {
      category = 'Electrical';
      if (combined.contains('spark') || combined.contains('smoke') || combined.contains('shock')) {
        severity = 'HIGH';
        priority = 'CRITICAL';
        recommendedAction = 'Immediate inspection required. Isolate power breaker.';
      } else {
        severity = 'MEDIUM';
        priority = 'HIGH';
        recommendedAction = 'Inspect electrical fixture and test voltage load.';
      }
      assignedDept = 'Electrical Maintenance';
    } else if (combined.contains('water') ||
        combined.contains('leak') ||
        combined.contains('tap') ||
        combined.contains('pipe') ||
        combined.contains('toilet') ||
        combined.contains('drain') ||
        combined.contains('flush')) {
      category = 'Plumbing';
      severity = combined.contains('flood') || combined.contains('burst') ? 'HIGH' : 'MEDIUM';
      priority = severity == 'HIGH' ? 'CRITICAL' : 'HIGH';
      assignedDept = 'Civil & Plumbing Maintenance';
      recommendedAction = 'Inspect plumbing joints and seal pressure valves.';
    } else if (combined.contains('wifi') ||
        combined.contains('internet') ||
        combined.contains('router') ||
        combined.contains('lan') ||
        combined.contains('projector') ||
        combined.contains('pc') ||
        combined.contains('network')) {
      category = 'Wi-Fi & IT';
      severity = 'LOW';
      priority = 'MEDIUM';
      assignedDept = 'Campus IT Infrastructure';
      recommendedAction = 'Inspect network gateway and reset connected AP node.';
    } else if (combined.contains('broken') ||
        combined.contains('bench') ||
        combined.contains('desk') ||
        combined.contains('door') ||
        combined.contains('window') ||
        combined.contains('wall') ||
        combined.contains('tile')) {
      category = 'Civil & Carpentry';
      severity = 'LOW';
      priority = 'MEDIUM';
      assignedDept = 'Civil Works & Carpentry';
      recommendedAction = 'Dispatch carpentry technician for hardware repair.';
    }

    return AIAnalysisResult(
      category: category,
      severity: severity,
      priority: priority,
      assignedDepartment: assignedDept,
      recommendedAction: recommendedAction,
    );
  }

  Future<CampusComplaint> submitComplaint({
    required String title,
    required String description,
    required String location,
    required String reporterName,
    required String reporterId,
    String? imagePath,
  }) async {
    final aiResult = analyzeComplaint(
      title: title,
      description: description,
      location: location,
    );

    final newId = '#WE${1025 + _complaints.length}';
    final complaint = CampusComplaint(
      id: newId,
      title: title,
      description: description,
      location: location,
      category: aiResult.category,
      severity: aiResult.severity,
      priority: aiResult.priority,
      assignedDepartment: aiResult.assignedDepartment,
      recommendedAction: aiResult.recommendedAction,
      status: ComplaintStatus.analyzing,
      createdAt: DateTime.now(),
      reporterName: reporterName,
      reporterId: reporterId,
      imagePath: imagePath,
    );

    _complaints.insert(0, complaint);
    notifyListeners();

    // Simulate automated AI transition to assigned
    Future.delayed(const Duration(seconds: 2), () {
      final index = _complaints.indexWhere((c) => c.id == newId);
      if (index != -1) {
        _complaints[index] = _complaints[index].copyWith(
          status: ComplaintStatus.assigned,
        );
        notifyListeners();
      }
    });

    return complaint;
  }

  void updateComplaintStatus(String id, ComplaintStatus newStatus) {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void reassignComplaint(String id, String newDepartment) {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(
        assignedDepartment: newDepartment,
        status: ComplaintStatus.inProgress,
      );
      notifyListeners();
    }
  }

  // ---------------- STAFF ATTENDANCE DIRECTORY ----------------
  final List<StudentAttendanceItem> _studentAttendanceList = [
    const StudentAttendanceItem(
      studentId: '927624BEC121',
      name: 'Mahil Ram E K',
      department: 'ECE',
      year: 'III Year',
      section: 'A',
      attendancePercentage: 87.5,
      isPresentToday: true,
      checkInTime: '09:12 AM',
    ),
    const StudentAttendanceItem(
      studentId: '927624BEC122',
      name: 'Aakash Verma',
      department: 'ECE',
      year: 'III Year',
      section: 'A',
      attendancePercentage: 92.0,
      isPresentToday: true,
      checkInTime: '08:58 AM',
    ),
    const StudentAttendanceItem(
      studentId: '927624BEC123',
      name: 'Deepika S',
      department: 'ECE',
      year: 'III Year',
      section: 'A',
      attendancePercentage: 74.2,
      isPresentToday: false,
      checkInTime: '--',
    ),
    const StudentAttendanceItem(
      studentId: '927624BCS045',
      name: 'Rohan Gupta',
      department: 'CSE',
      year: 'III Year',
      section: 'B',
      attendancePercentage: 88.4,
      isPresentToday: true,
      checkInTime: '09:05 AM',
    ),
    const StudentAttendanceItem(
      studentId: '927624BCS046',
      name: 'Shweta K',
      department: 'CSE',
      year: 'III Year',
      section: 'B',
      attendancePercentage: 68.0,
      isPresentToday: false,
      checkInTime: '--',
    ),
    const StudentAttendanceItem(
      studentId: '927624BME012',
      name: 'Vignesh M',
      department: 'MECH',
      year: 'IV Year',
      section: 'A',
      attendancePercentage: 81.5,
      isPresentToday: true,
      checkInTime: '09:15 AM',
    ),
  ];

  List<StudentAttendanceItem> get studentAttendanceList => _studentAttendanceList;
}
