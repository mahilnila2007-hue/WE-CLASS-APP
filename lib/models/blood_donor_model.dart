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
}
