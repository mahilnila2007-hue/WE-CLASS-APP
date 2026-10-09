import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/blood_donor_model.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/gradient_card.dart';

class StudentBloodTab extends StatefulWidget {
  const StudentBloodTab({super.key});

  @override
  State<StudentBloodTab> createState() => _StudentBloodTabState();
}

class _StudentBloodTabState extends State<StudentBloodTab> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _bloodGroups = [
    'ALL',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campusData = Provider.of<CampusDataService>(context);
    final donors = campusData.filteredDonors;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Blood Donor',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Verified student & faculty volunteer network',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      campusData.setSearchDonorQuery(val);
                    },
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by donor name or dept...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.brightCyan,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.textGrey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                campusData.setSearchDonorQuery('');
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Blood Group Filter Chips
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _bloodGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final group = _bloodGroups[index];
                        final isSelected = campusData.selectedBloodFilter == group;

                        return GestureDetector(
                          onTap: () {
                            campusData.setBloodFilter(group);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.redGradient : null,
                              color: isSelected ? null : AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.alertRed
                                    : AppColors.borderLight,
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.alertRed.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                group,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.textGrey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Donors List
            Expanded(
              child: donors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bloodtype_outlined,
                            size: 64,
                            color: AppColors.secondaryGrey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No donors found for selected filter',
                            style: GoogleFonts.poppins(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: donors.length,
                      itemBuilder: (context, index) {
                        final donor = donors[index];
                        return _buildDonorCard(donor, campusData, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(BloodDonor donor, CampusDataService campusData, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: donor.isAvailable
              ? AppColors.alertRed.withOpacity(0.2)
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                // Left: Circular Blood Group Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.alertRed.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      donor.bloodGroup,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Center: Name, Department, Year
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${donor.department} • ${donor.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brightCyan,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last donated: ${donor.lastDonationDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Available Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: donor.isAvailable
                        ? AppColors.brightGreen.withOpacity(0.15)
                        : AppColors.secondaryGrey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: donor.isAvailable
                          ? AppColors.brightGreen
                          : AppColors.secondaryGrey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: donor.isAvailable
                              ? AppColors.brightGreen
                              : AppColors.secondaryGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        donor.isAvailable ? 'Available' : 'Resting',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: donor.isAvailable
                              ? AppColors.brightGreen
                              : AppColors.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom: [ CALL DONOR ] Button (Launches Dialer, Number Hidden)
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: donor.isAvailable
                    ? AppColors.greenTealGradient
                    : LinearGradient(
                        colors: [
                          AppColors.secondaryGrey.withOpacity(0.3),
                          AppColors.secondaryGrey.withOpacity(0.2),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: donor.isAvailable
                    ? [
                        BoxShadow(
                          color: AppColors.teal.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: donor.isAvailable
                      ? () async {
                          final called = await campusData.callDonor(donor);
                          if (!called && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Connecting call to verified donor...',
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                                backgroundColor: AppColors.electricBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded,
                        color: donor.isAvailable ? Colors.white : AppColors.textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CALL DONOR',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: donor.isAvailable ? Colors.white : AppColors.textGrey,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * (index % 5)).ms).slideY(begin: 0.05, end: 0);
  }
}
