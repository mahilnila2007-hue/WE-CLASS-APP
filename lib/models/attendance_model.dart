enum DayAttendanceStatus {
  present,
  absent,
  holiday,
  leave,
}

class DailyAttendanceRecord {
  final DateTime date;
  final DayAttendanceStatus status;
  final String note;

  const DailyAttendanceRecord({
    required this.date,
    required this.status,
    this.note = '',
  });
}

class StudentAttendanceOverview {
  final int present;
  final int absent;
  final int total;
  final double requiredPercentage;
  final bool isPresentToday;
  final String todayLocation;
  final String todayTime;
  final String gpsAccuracy;
  final String riskLevel;
  final String predictionMessage;
  final int classesRequiredFor75;
  final List<DailyAttendanceRecord> monthlyRecords;

  const StudentAttendanceOverview({
    required this.present,
    required this.absent,
    required this.total,
    this.requiredPercentage = 75.0,
    required this.isPresentToday,
    required this.todayLocation,
    required this.todayTime,
    required this.gpsAccuracy,
    required this.riskLevel,
    required this.predictionMessage,
    required this.classesRequiredFor75,
    required this.monthlyRecords,
  });

  double get percentage => total > 0 ? (present / total) * 100 : 0.0;
  String get percentageString => '${percentage.toStringAsFixed(0)}%';
}

class StudentAttendanceItem {
  final String studentId;
  final String name;
  final String department;
  final String year;
  final String section;
  final double attendancePercentage;
  final bool isPresentToday;
  final String checkInTime;

  const StudentAttendanceItem({
    required this.studentId,
    required this.name,
    required this.department,
    required this.year,
    required this.section,
    required this.attendancePercentage,
    required this.isPresentToday,
    required this.checkInTime,
  });
}
