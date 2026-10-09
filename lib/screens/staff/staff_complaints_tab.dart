import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/glowing_button.dart';

class StaffComplaintsTab extends StatefulWidget {
  const StaffComplaintsTab({super.key});

  @override
  State<StaffComplaintsTab> createState() => _StaffComplaintsTabState();
}

class _StaffComplaintsTabState extends State<StaffComplaintsTab> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final campusData = Provider.of<CampusDataService>(context);
    final allComplaints = campusData.allComplaints;

    final filteredComplaints = allComplaints.where((c) {
      return _selectedCategory == 'ALL' || c.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaint Management',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Triage, assign, and resolve campus infrastructure issues',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['ALL', 'Electrical', 'Plumbing', 'Wi-Fi & IT', 'Civil & Carpentry'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.orangeGradient : null,
                              color: isSelected ? null : AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.orange : AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              cat.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textGrey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Complaint Cards List
            Expanded(
              child: filteredComplaints.isEmpty
                  ? Center(
                      child: Text(
                        'No complaints found for selected filter',
                        style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) {
                        final complaint = filteredComplaints[index];
                        return _buildStaffComplaintCard(complaint, campusData, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffComplaintCard(
    CampusComplaint complaint,
    CampusDataService campusData,
    int index,
  ) {
    Color severityColor;
    switch (complaint.severity) {
      case 'HIGH':
        severityColor = AppColors.alertRed;
        break;
      case 'MEDIUM':
        severityColor = AppColors.orange;
        break;
      default:
        severityColor = AppColors.brightGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: complaint.priority == 'CRITICAL'
              ? AppColors.alertRed.withOpacity(0.35)
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID, Category & Severity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    complaint.id,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brightCyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      complaint.category,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brightCyan,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: severityColor, width: 0.8),
                ),
                child: Text(
                  '${complaint.severity} SEVERITY',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            complaint.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  complaint.location,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details Grid (Assigned, Status)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assigned:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      complaint.assignedDepartment,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status:',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                    Text(
                      complaint.status.displayName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brightCyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: [ VIEW ], [ ASSIGN ], [ UPDATE STATUS ]
          Row(
            children: [
              // VIEW
              Expanded(
                child: _buildOutlineActionButton(
                  label: 'VIEW',
                  icon: Icons.visibility_outlined,
                  color: AppColors.brightCyan,
                  onTap: () => _showViewModal(complaint),
                ),
              ),
              const SizedBox(width: 8),
              // ASSIGN
              Expanded(
                child: _buildOutlineActionButton(
                  label: 'ASSIGN',
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppColors.violet,
                  onTap: () => _showAssignModal(complaint, campusData),
                ),
              ),
              const SizedBox(width: 8),
              // UPDATE STATUS
              Expanded(
                child: _buildOutlineActionButton(
                  label: 'UPDATE',
                  icon: Icons.update_rounded,
                  color: AppColors.brightGreen,
                  onTap: () => _showUpdateStatusModal(complaint, campusData),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (80 * (index % 5)).ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildOutlineActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showViewModal(CampusComplaint complaint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticket ${complaint.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    complaint.status.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brightCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                complaint.title,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                complaint.description,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey, height: 1.3),
              ),
              const SizedBox(height: 14),
              Text(
                'Reported by: ${complaint.reporterName} (${complaint.reporterId})',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.brightCyan),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAssignModal(CampusComplaint complaint, CampusDataService campusData) {
    final depts = [
      'Electrical Maintenance',
      'Civil & Plumbing Maintenance',
      'Campus IT Infrastructure',
      'Civil Works & Carpentry',
      'Campus Facility Services',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reassign Ticket Department',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              ...depts.map((d) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                  trailing: complaint.assignedDepartment == d
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.brightCyan)
                      : null,
                  onTap: () {
                    campusData.reassignComplaint(complaint.id, d);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ticket re-assigned to $d'),
                        backgroundColor: AppColors.electricBlue,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateStatusModal(CampusComplaint complaint, CampusDataService campusData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Ticket Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              ...ComplaintStatus.values.map((status) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    status.displayName,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  trailing: complaint.status == status
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.brightGreen)
                      : null,
                  onTap: () {
                    campusData.updateComplaintStatus(complaint.id, status);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to ${status.displayName}'),
                        backgroundColor: AppColors.successGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
