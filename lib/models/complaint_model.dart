enum ComplaintStatus {
  submitted,
  analyzing,
  assigned,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'Submitted';
      case ComplaintStatus.analyzing:
        return 'Analyzing';
      case ComplaintStatus.assigned:
        return 'Assigned';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }
}

class AIAnalysisResult {
  final String category;
  final String severity; // HIGH, MEDIUM, LOW
  final String priority; // CRITICAL, HIGH, MEDIUM, LOW
  final String assignedDepartment;
  final String recommendedAction;
  final double confidenceScore;

  const AIAnalysisResult({
    required this.category,
    required this.severity,
    required this.priority,
    required this.assignedDepartment,
    required this.recommendedAction,
    this.confidenceScore = 0.94,
  });
}

class CampusComplaint {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String severity;
  final String priority;
  final String assignedDepartment;
  final String recommendedAction;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String reporterName;
  final String reporterId;
  final String? imagePath;

  const CampusComplaint({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.severity,
    required this.priority,
    required this.assignedDepartment,
    required this.recommendedAction,
    required this.status,
    required this.createdAt,
    required this.reporterName,
    required this.reporterId,
    this.imagePath,
  });

  CampusComplaint copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? category,
    String? severity,
    String? priority,
    String? assignedDepartment,
    String? recommendedAction,
    ComplaintStatus? status,
    DateTime? createdAt,
    String? reporterName,
    String? reporterId,
    String? imagePath,
  }) {
    return CampusComplaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      priority: priority ?? this.priority,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reporterName: reporterName ?? this.reporterName,
      reporterId: reporterId ?? this.reporterId,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'severity': severity,
      'priority': priority,
      'assignedDepartment': assignedDepartment,
      'recommendedAction': recommendedAction,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'reporterName': reporterName,
      'reporterId': reporterId,
      'imagePath': imagePath,
    };
  }

  factory CampusComplaint.fromMap(Map<String, dynamic> map, String id) {
    return CampusComplaint(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? 'General',
      severity: map['severity'] ?? 'LOW',
      priority: map['priority'] ?? 'MEDIUM',
      assignedDepartment: map['assignedDepartment'] ?? 'Maintenance',
      recommendedAction: map['recommendedAction'] ?? 'Inspection required',
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.submitted,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      reporterName: map['reporterName'] ?? '',
      reporterId: map['reporterId'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}
