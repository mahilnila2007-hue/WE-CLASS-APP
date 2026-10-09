import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../services/auth_service.dart';
import '../../services/campus_data_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/complaint_photo_viewer.dart';

class StudentComplaintsTab extends StatefulWidget {
  const StudentComplaintsTab({super.key});

  @override
  State<StudentComplaintsTab> createState() => _StudentComplaintsTabState();
}

class _StudentComplaintsTabState extends State<StudentComplaintsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  bool _isSubmitting = false;

  String? _capturedImageBase64;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _locController.dispose();
    super.dispose();
  }

  void _showAIAnalysisDialog(CampusComplaint complaint) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
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

        return Dialog(
          backgroundColor: AppColors.darkNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.brightCyan, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top AI Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI ANALYSIS',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: severityColor, width: 1),
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

                const SizedBox(height: 18),
                const Divider(color: AppColors.borderLight, height: 1),
                const SizedBox(height: 16),

                _buildAIDialogRow('Ticket ID', complaint.id, AppColors.brightCyan),
                const SizedBox(height: 10),
                _buildAIDialogRow('Category', complaint.category, Colors.white),
                const SizedBox(height: 10),
                _buildAIDialogRow('Priority', complaint.priority, severityColor),
                const SizedBox(height: 10),
                _buildAIDialogRow('Assigned Department', complaint.assignedDepartment, Colors.white),
                const SizedBox(height: 14),

                Text(
                  'Recommended Action:',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    complaint.recommendedAction,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                GlowingButton(
                  text: 'VIEW TICKET TRACKING',
                  gradient: AppColors.primaryGradient,
                  height: 48,
                  fontSize: 13,
                  onPressed: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1); // Switch to tracking tab
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIDialogRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _capturedImageBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _locController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all complaint details',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final campusData = Provider.of<CampusDataService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser ?? AuthService.defaultStudent;

    final createdComplaint = await campusData.submitComplaint(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      location: _locController.text.trim(),
      reporterName: user.name,
      reporterId: user.displayId,
      imagePath: _capturedImageBase64,
    );

    setState(() {
      _isSubmitting = false;
      _titleController.clear();
      _descController.clear();
      _locController.clear();
      _capturedImageBase64 = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });

    if (mounted) {
      _showAIAnalysisDialog(createdComplaint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusData = Provider.of<CampusDataService>(context);

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Tabs
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Complaints',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered rapid infrastructure ticketing',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Tabs
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brightCyan.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textGrey,
                      labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Report Issue'),
                        Tab(text: 'My Complaints'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReportIssueTab(),
                  _buildMyComplaintsTab(campusData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Report Issue Form
  Widget _buildReportIssueTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Photo Area
            Text(
              'PHOTO EVIDENCE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brightCyan,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            if (_selectedImageBytes != null)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.brightCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brightCyan.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageBytes = null;
                            _selectedImageName = null;
                            _capturedImageBase64 = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.brightGreen.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.brightGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _selectedImageName ?? 'Photo attached',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showPhotoPickerModal,
                              child: Text(
                                'Change',
                                style: GoogleFonts.poppins(
                                  color: AppColors.brightCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms)
            else
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showPhotoPickerModal,
                    borderRadius: BorderRadius.circular(22),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.brightCyan,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+ Add Photo Evidence',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Take Photo or Choose from Gallery',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // Problem Title
            Text(
              'PROBLEM TITLE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brightCyan,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'e.g. Electrical switchboard sparking in Lab 304',
                prefixIcon: Icon(Icons.title_rounded, color: AppColors.brightCyan, size: 20),
              ),
            ),

            const SizedBox(height: 18),

            // Description
            Text(
              'DESCRIPTION',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brightCyan,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Describe the issue, frequency, and safety impact...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_rounded, color: AppColors.brightCyan, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Location
            Text(
              'LOCATION',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brightCyan,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'e.g. Block 4, 3rd Floor, Lab 304',
                prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.brightCyan, size: 20),
              ),
            ),

            const SizedBox(height: 26),

            // ANALYZE & SUBMIT BUTTON
            GlowingButton(
              text: 'ANALYZE & SUBMIT',
              isLoading: _isSubmitting,
              icon: Icons.auto_awesome,
              gradient: AppColors.primaryGradient,
              glowColor: AppColors.brightCyan,
              onPressed: _handleSubmit,
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _showPhotoPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Evidence Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.brightCyan),
                  ),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Use device camera to snap issue',
                    style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.violet),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Select existing campus photo',
                    style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: My Complaints Tracking
  Widget _buildMyComplaintsTab(CampusDataService campusData) {
    final complaints = campusData.myComplaints;

    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.secondaryGrey.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'No complaints reported yet',
              style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return _buildComplaintTrackingCard(complaint, index);
      },
    );
  }

  Widget _buildComplaintTrackingCard(CampusComplaint complaint, int index) {
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: ID, Category & Severity Badge
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
                    complaint.priority,
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

            // Location & Date
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    complaint.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),

            if (complaint.imagePath != null && complaint.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 14),
              ComplaintPhotoViewer(
                imagePath: complaint.imagePath,
                height: 160,
              ),
            ],

            const SizedBox(height: 16),

            // Horizontal Status Timeline
            _buildStatusTimeline(complaint.status),

            const SizedBox(height: 16),

            // Assigned Department banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkNavy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering_rounded, color: AppColors.brightCyan, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Assigned to: ${complaint.assignedDepartment}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStatusTimeline(ComplaintStatus currentStatus) {
    final stages = [
      ComplaintStatus.submitted,
      ComplaintStatus.analyzing,
      ComplaintStatus.assigned,
      ComplaintStatus.inProgress,
      ComplaintStatus.resolved,
      ComplaintStatus.closed,
    ];

    final currentIndex = stages.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESS TIMELINE',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryGrey,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              currentStatus.displayName.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.brightCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(stages.length, (index) {
            final isReached = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: isReached ? AppColors.primaryGradient : null,
                        color: isReached ? null : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Container(
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReached ? AppColors.brightCyan : AppColors.secondaryGrey,
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: index < currentIndex ? AppColors.primaryGradient : null,
                          color: index < currentIndex ? null : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
