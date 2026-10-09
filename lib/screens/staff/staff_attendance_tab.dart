import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/attendance_model.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/gradient_card.dart';

class StaffAttendanceTab extends StatefulWidget {
  const StaffAttendanceTab({super.key});

  @override
  State<StaffAttendanceTab> createState() => _StaffAttendanceTabState();
}

class _StaffAttendanceTabState extends State<StaffAttendanceTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDept = 'ALL';
  String _selectedStatus = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campusData = Provider.of<CampusDataService>(context);
    final allStudents = campusData.studentAttendanceList;

    final filteredStudents = allStudents.where((student) {
      final matchesSearch = _searchController.text.isEmpty ||
          student.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesDept = _selectedDept == 'ALL' || student.department == _selectedDept;
      final matchesStatus = _selectedStatus == 'ALL' ||
          (_selectedStatus == 'PRESENT' && student.isPresentToday) ||
          (_selectedStatus == 'ABSENT' && !student.isPresentToday);

      return matchesSearch && matchesDept && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Overview Stats
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Monitor',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Campus-wide check-in logs & roll call analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Today's Campus Roll Overview Card
                  GradientCard(
                    gradient: AppColors.primaryGradient,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Present', '982', AppColors.brightGreen),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
                        _buildStatColumn('Absent', '263', AppColors.alertRed),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
                        _buildStatColumn('Total', '1245', Colors.white),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
                        _buildStatColumn('Ratio', '78.8%', AppColors.brightCyan),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by student name or ID...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brightCyan, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.textGrey, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filters Row: Dept & Status
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('ALL DEPTS', 'ALL', _selectedDept, (v) => setState(() => _selectedDept = v)),
                        const SizedBox(width: 8),
                        _buildFilterChip('ECE', 'ECE', _selectedDept, (v) => setState(() => _selectedDept = v)),
                        const SizedBox(width: 8),
                        _buildFilterChip('CSE', 'CSE', _selectedDept, (v) => setState(() => _selectedDept = v)),
                        const SizedBox(width: 8),
                        _buildFilterChip('MECH', 'MECH', _selectedDept, (v) => setState(() => _selectedDept = v)),
                        const SizedBox(width: 16),
                        _buildFilterChip('ALL STATUS', 'ALL', _selectedStatus, (v) => setState(() => _selectedStatus = v)),
                        const SizedBox(width: 8),
                        _buildFilterChip('PRESENT', 'PRESENT', _selectedStatus, (v) => setState(() => _selectedStatus = v)),
                        const SizedBox(width: 8),
                        _buildFilterChip('ABSENT', 'ABSENT', _selectedStatus, (v) => setState(() => _selectedStatus = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Student Cards List
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'No student records match filter criteria',
                        style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return _buildStudentCard(student, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricBlue : AppColors.deepNavy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.brightCyan : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendanceItem student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: student.isPresentToday
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppColors.alertRed.withOpacity(0.8),
                        AppColors.alertRed.withOpacity(0.4),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${student.studentId} • ${student.department} (${student.year} - Sec ${student.section})',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Overall Attendance: ${student.attendancePercentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: student.attendancePercentage >= 75
                        ? AppColors.brightGreen
                        : AppColors.alertRed,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: student.isPresentToday
                      ? AppColors.brightGreen.withOpacity(0.15)
                      : AppColors.alertRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: student.isPresentToday ? AppColors.brightGreen : AppColors.alertRed,
                    width: 1,
                  ),
                ),
                child: Text(
                  student.isPresentToday ? 'PRESENT' : 'ABSENT',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: student.isPresentToday ? AppColors.brightGreen : AppColors.alertRed,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student.checkInTime,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.secondaryGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (60 * (index % 6)).ms).slideY(begin: 0.04, end: 0);
  }
}
