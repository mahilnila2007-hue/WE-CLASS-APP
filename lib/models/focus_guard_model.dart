enum PeriodType {
  classPeriod,
  breakTime,
  lunchTime,
}

enum FocusGuardState {
  active,
  inactive,
  breakPeriod,
  disabledByFaculty,
}

class TimetablePeriod {
  final String id;
  final String periodNumber;
  final PeriodType type;
  final String startTimeFormatted;
  final String endTimeFormatted;
  final int startMinutesOfDay; // e.g. 8:45 -> 8*60 + 45 = 525
  final int endMinutesOfDay;   // e.g. 9:45 -> 9*60 + 45 = 585
  final String subject;
  final String room;
  final String facultyId;
  final String facultyName;
  final bool isFocusGuardEnabledByDefault;

  const TimetablePeriod({
    required this.id,
    required this.periodNumber,
    required this.type,
    required this.startTimeFormatted,
    required this.endTimeFormatted,
    required this.startMinutesOfDay,
    required this.endMinutesOfDay,
    required this.subject,
    required this.room,
    required this.facultyId,
    required this.facultyName,
    this.isFocusGuardEnabledByDefault = true,
  });

  bool get isBreakOrLunch =>
      type == PeriodType.breakTime || type == PeriodType.lunchTime;

  String get timeRange => '$startTimeFormatted - $endTimeFormatted';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodNumber': periodNumber,
      'type': type.name,
      'startTimeFormatted': startTimeFormatted,
      'endTimeFormatted': endTimeFormatted,
      'startMinutesOfDay': startMinutesOfDay,
      'endMinutesOfDay': endMinutesOfDay,
      'subject': subject,
      'room': room,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'isFocusGuardEnabledByDefault': isFocusGuardEnabledByDefault,
    };
  }

  factory TimetablePeriod.fromMap(Map<String, dynamic> map) {
    return TimetablePeriod(
      id: map['id'] ?? '',
      periodNumber: map['periodNumber'] ?? '',
      type: PeriodType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PeriodType.classPeriod,
      ),
      startTimeFormatted: map['startTimeFormatted'] ?? '',
      endTimeFormatted: map['endTimeFormatted'] ?? '',
      startMinutesOfDay: map['startMinutesOfDay'] ?? 0,
      endMinutesOfDay: map['endMinutesOfDay'] ?? 0,
      subject: map['subject'] ?? '',
      room: map['room'] ?? '',
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? '',
      isFocusGuardEnabledByDefault: map['isFocusGuardEnabledByDefault'] ?? true,
    );
  }
}

class PhoneViolation {
  final String id;
  final String studentId;
  final String studentName;
  final String department;
  final String year;
  final String subject;
  final String room;
  final String facultyId;
  final String period;
  final int usageDuration;
  final int threshold;
  final DateTime timestamp;
  final String type;
  final String status; // 'NEW', 'ACKNOWLEDGED', 'WARNED', 'SUMMONED', 'ESCALATED'
  final String urgency; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String actionTaken;
  final String studentPhone;

  const PhoneViolation({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.department,
    required this.year,
    required this.subject,
    required this.room,
    required this.facultyId,
    required this.period,
    required this.usageDuration,
    this.threshold = 20,
    required this.timestamp,
    this.type = 'PHONE_USAGE',
    this.status = 'NEW',
    this.urgency = 'HIGH',
    this.actionTaken = 'NONE',
    this.studentPhone = '+91 98401 23456',
  });

  PhoneViolation copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? department,
    String? year,
    String? subject,
    String? room,
    String? facultyId,
    String? period,
    int? usageDuration,
    int? threshold,
    DateTime? timestamp,
    String? type,
    String? status,
    String? urgency,
    String? actionTaken,
    String? studentPhone,
  }) {
    return PhoneViolation(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      department: department ?? this.department,
      year: year ?? this.year,
      subject: subject ?? this.subject,
      room: room ?? this.room,
      facultyId: facultyId ?? this.facultyId,
      period: period ?? this.period,
      usageDuration: usageDuration ?? this.usageDuration,
      threshold: threshold ?? this.threshold,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      actionTaken: actionTaken ?? this.actionTaken,
      studentPhone: studentPhone ?? this.studentPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'department': department,
      'year': year,
      'subject': subject,
      'room': room,
      'facultyId': facultyId,
      'period': period,
      'usageDuration': usageDuration,
      'threshold': threshold,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'status': status,
      'urgency': urgency,
      'actionTaken': actionTaken,
      'studentPhone': studentPhone,
    };
  }

  factory PhoneViolation.fromMap(Map<String, dynamic> map, String id) {
    return PhoneViolation(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      subject: map['subject'] ?? '',
      room: map['room'] ?? '',
      facultyId: map['facultyId'] ?? '',
      period: map['period'] ?? '',
      usageDuration: map['usageDuration'] ?? 20,
      threshold: map['threshold'] ?? 20,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      type: map['type'] ?? 'PHONE_USAGE',
      status: map['status'] ?? 'NEW',
      urgency: map['urgency'] ?? 'HIGH',
      actionTaken: map['actionTaken'] ?? 'NONE',
      studentPhone: map['studentPhone'] ?? '+91 98401 23456',
    );
  }
}

class FocusGuardLog {
  final String id;
  final String staffId;
  final String staffName;
  final String action; // 'DISABLED' or 'ENABLED'
  final String subject;
  final String room;
  final String period;
  final DateTime timestamp;
  final String reason;

  const FocusGuardLog({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.action,
    required this.subject,
    required this.room,
    required this.period,
    required this.timestamp,
    this.reason = 'Faculty decision',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'action': action,
      'subject': subject,
      'room': room,
      'period': period,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }

  factory FocusGuardLog.fromMap(Map<String, dynamic> map, String id) {
    return FocusGuardLog(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      action: map['action'] ?? '',
      subject: map['subject'] ?? '',
      room: map['room'] ?? '',
      period: map['period'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      reason: map['reason'] ?? '',
    );
  }
}
