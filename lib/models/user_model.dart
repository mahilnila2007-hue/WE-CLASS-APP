enum UserRole { student, staff, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String profileImage;
  
  // Student Specific
  final String? studentId;
  final String? department;
  final String? year;
  final String? batch;
  final String? bloodGroup;

  // Staff Specific
  final String? staffId;
  final String? designation;
  final String? assignedArea;
  final String? joiningYear;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage = '',
    this.studentId,
    this.department,
    this.year,
    this.batch,
    this.bloodGroup,
    this.staffId,
    this.designation,
    this.assignedArea,
    this.joiningYear,
  });

  bool get isStudent => role == UserRole.student;
  bool get isStaff => role == UserRole.staff;
  bool get isAdmin => role == UserRole.admin;

  String get displayId => isStudent ? (studentId ?? '') : (staffId ?? '');

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'profileImage': profileImage,
      'studentId': studentId,
      'department': department,
      'year': year,
      'batch': batch,
      'bloodGroup': bloodGroup,
      'staffId': staffId,
      'designation': designation,
      'assignedArea': assignedArea,
      'joiningYear': joiningYear,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
      profileImage: map['profileImage'] ?? '',
      studentId: map['studentId'],
      department: map['department'],
      year: map['year'],
      batch: map['batch'],
      bloodGroup: map['bloodGroup'],
      staffId: map['staffId'],
      designation: map['designation'],
      assignedArea: map['assignedArea'],
      joiningYear: map['joiningYear'],
    );
  }
}
