class BloodDonor {
  final String id;
  final String name;
  final String department;
  final String year;
  final String bloodGroup;
  final bool isAvailable;
  final String phone;
  final String lastDonationDate;

  const BloodDonor({
    required this.id,
    required this.name,
    required this.department,
    required this.year,
    required this.bloodGroup,
    required this.isAvailable,
    required this.phone,
    this.lastDonationDate = '3 months ago',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'year': year,
      'bloodGroup': bloodGroup,
      'isAvailable': isAvailable,
      'phone': phone,
      'lastDonationDate': lastDonationDate,
    };
  }

  factory BloodDonor.fromMap(Map<String, dynamic> map, String id) {
    return BloodDonor(
      id: id,
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      bloodGroup: map['bloodGroup'] ?? 'O+',
      isAvailable: map['isAvailable'] ?? true,
      phone: map['phone'] ?? '',
      lastDonationDate: map['lastDonationDate'] ?? 'Recent',
    );
  }
}
