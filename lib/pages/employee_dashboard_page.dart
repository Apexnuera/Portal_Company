import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html; // For web file picker
import 'dart:typed_data';
import '../services/auth_service.dart';
import '../state/employee_directory.dart';

// Employee Dashboard Navigation Menu Items
enum _EmployeeMenu {
  personalDetails,
  professionalProfile,
  compensation,
  taxInformation,
  timeSheet,
  faqs
}

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({
    super.key,
    this.employeeId,
    this.forceEdit = false,
    this.showLogoutAction = true,
    this.onExit,
  });

  final String? employeeId;
  final bool forceEdit;
  final bool showLogoutAction;
  final VoidCallback? onExit;

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  _EmployeeMenu _selected = _EmployeeMenu.personalDetails; // initial: personal details
  String? _profileImageUrl; // State for profile image URL
  String _employeeName = 'John Doe'; // State for employee name
  Uint8List? _profileImageBytes; // State for profile image bytes
  EmployeeRecord? _employeeRecord;

  void _handleProfileImageUpdate(Uint8List? bytes) {
    final record = _employeeRecord;
    if (record == null) return;
    context.read<EmployeeDirectory>().updateProfileImage(record.id, bytes);
  }

  void _handlePersonalDetailsSaved(EmployeePersonalDetails details) {
    final record = _employeeRecord;
    if (record == null) return;
    context.read<EmployeeDirectory>().updatePersonalDetails(record.id, details);
  }

  void _handleProfessionalProfileSaved(EmployeeProfessionalProfile profile) {
    final record = _employeeRecord;
    if (record == null) return;
    context.read<EmployeeDirectory>().updateProfessionalProfile(record.id, profile);
  }

  void _handleGlobalSave() {
    final record = _employeeRecord;
    if (record == null) return;
    context.read<EmployeeDirectory>().touchEmployee(record.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All changes saved.')),
    );
    widget.onExit?.call();
  }

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<EmployeeDirectory>();
    final activeEmployeeId = widget.employeeId ?? directory.primaryEmployeeId;
    _employeeRecord = directory.tryGetById(activeEmployeeId);
    if (_employeeRecord != null) {
      _employeeName = _employeeRecord!.personal.fullName;
      _profileImageBytes = _employeeRecord!.personal.profileImageBytes;
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          _EmployeeDashboardHeader(
            onLogout: () {
              AuthService.instance.logout();
              context.go('/home');
            },
            profileImageUrl: _profileImageUrl,
            profileImageBytes: _profileImageBytes,
            employeeName: _employeeName,
            showLogoutAction: widget.showLogoutAction,
            showSaveAction: widget.forceEdit,
            onSave: widget.forceEdit ? _handleGlobalSave : null,
          ),
          // Main Content Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    children: [
                      _Sidebar(
                        selected: _selected,
                        onSelect: (m) => setState(() => _selected = m),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _ContentPanel(
                        selected: _selected,
                        employeeRecord: _employeeRecord,
                        forceEditMode: widget.forceEdit,
                        onProfileImageUpdated: (url) {
                          setState(() => _profileImageUrl = url);
                        },
                        onProfileImageBytesUpdated: (bytes) {
                          _handleProfileImageUpdate(bytes);
                        },
                        onEmployeeNameUpdated: (name) {
                          setState(() => _employeeName = name);
                        },
                        onPersonalDetailsSaved: _handlePersonalDetailsSaved,
                        onProfessionalProfileSaved: _handleProfessionalProfileSaved,
                      )),
                    ],
                  );
                }
                return Column(
                  children: [
                    _MobileNav(
                      selected: _selected,
                      onSelect: (m) => setState(() => _selected = m),
                    ),
                    const Divider(height: 1),
                    Expanded(child: _ContentPanel(
                      selected: _selected,
                      employeeRecord: _employeeRecord,
                      forceEditMode: widget.forceEdit,
                      onProfileImageUpdated: (url) {
                        setState(() => _profileImageUrl = url);
                      },
                      onProfileImageBytesUpdated: (bytes) {
                        _handleProfileImageUpdate(bytes);
                      },
                      onEmployeeNameUpdated: (name) {
                        setState(() => _employeeName = name);
                      },
                      onPersonalDetailsSaved: _handlePersonalDetailsSaved,
                      onProfessionalProfileSaved: _handleProfessionalProfileSaved,
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDashboardHeader extends StatelessWidget {
  final VoidCallback onLogout;
  final String? profileImageUrl;
  final Uint8List? profileImageBytes;
  final String employeeName;
  final bool showLogoutAction;
  final bool showSaveAction;
  final VoidCallback? onSave;

  const _EmployeeDashboardHeader({
    required this.onLogout,
    this.profileImageUrl,
    this.profileImageBytes,
    required this.employeeName,
    this.showLogoutAction = true,
    this.showSaveAction = false,
    this.onSave,
  });

  void _showProfilePictureDialog(BuildContext context, String? profileImageUrl, Uint8List? profileImageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile Picture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile picture display
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color(0xFFFF782B),
                        width: 4,
                      ),
                      image: (profileImageBytes != null)
                          ? DecorationImage(
                              image: MemoryImage(profileImageBytes),
                              fit: BoxFit.cover,
                            )
                          : (profileImageUrl != null)
                              ? DecorationImage(
                                  image: NetworkImage(profileImageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (profileImageUrl == null && profileImageBytes == null)
                        ? const Icon(
                            Icons.person_outline,
                            color: Color(0xFFFF782B),
                            size: 80,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Logo/Brand
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF782B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ApexNuera',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Search Bar
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search dashboard...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Alerts Icon
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alerts feature coming soon!')),
                );
              },
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.grey),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Alerts',
            ),

            // Contact Link
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact feature coming soon!')),
                );
              },
              icon: const Icon(Icons.contact_support_outlined, color: Color(0xFFFF782B)),
              label: const Text(
                'Contact',
                style: TextStyle(color: Color(0xFFFF782B)),
              ),
            ),

            // Profile Section
            InkWell(
              onTap: () {
                if (profileImageUrl != null || profileImageBytes != null) {
                  _showProfilePictureDialog(context, profileImageUrl, profileImageBytes);
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (profileImageUrl != null || profileImageBytes != null)
                          ? Colors.transparent
                          : const Color(0xFFFF782B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF782B),
                        width: 2,
                      ),
                      image: (profileImageBytes != null)
                          ? DecorationImage(
                              image: MemoryImage(profileImageBytes!),
                              fit: BoxFit.cover,
                            )
                          : (profileImageUrl != null)
                              ? DecorationImage(
                                  image: NetworkImage(profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (profileImageUrl == null && profileImageBytes == null)
                        ? const Icon(
                            Icons.person_outline,
                            color: Color(0xFFFF782B),
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Employee ID: EMP001', // TODO: Get from user data
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            if (showSaveAction)
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF782B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (showLogoutAction) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Sidebar Component
class _Sidebar extends StatelessWidget {
  final _EmployeeMenu selected;
  final ValueChanged<_EmployeeMenu> onSelect;

  const _Sidebar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          // Personal Details
          _SidebarItem(
            icon: Icons.person_outline,
            title: 'Personal Details',
            isSelected: selected == _EmployeeMenu.personalDetails,
            onTap: () => onSelect(_EmployeeMenu.personalDetails),
          ),

          // Professional Profile
          _SidebarItem(
            icon: Icons.work_outline,
            title: 'Professional Profile',
            isSelected: selected == _EmployeeMenu.professionalProfile,
            onTap: () => onSelect(_EmployeeMenu.professionalProfile),
          ),

          // Compensation
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Compensation',
            isSelected: selected == _EmployeeMenu.compensation,
            onTap: () => onSelect(_EmployeeMenu.compensation),
          ),

          // Tax Information
          _SidebarItem(
            icon: Icons.assignment_outlined,
            title: 'Tax Information',
            isSelected: selected == _EmployeeMenu.taxInformation,
            onTap: () => onSelect(_EmployeeMenu.taxInformation),
          ),

          // Time Sheet
          _SidebarItem(
            icon: Icons.access_time_outlined,
            title: 'Time Sheet',
            isSelected: selected == _EmployeeMenu.timeSheet,
            onTap: () => onSelect(_EmployeeMenu.timeSheet),
          ),

          // FAQ's
          _SidebarItem(
            icon: Icons.help_outline,
            title: "FAQ's",
            isSelected: selected == _EmployeeMenu.faqs,
            onTap: () => onSelect(_EmployeeMenu.faqs),
          ),
        ],
      ),
    );
  }
}

// Sidebar Item Component
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF782B).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF782B) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFFF782B) : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF782B) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

// Mobile Navigation (for small screens)
class _MobileNav extends StatelessWidget {
  final _EmployeeMenu selected;
  final ValueChanged<_EmployeeMenu> onSelect;

  const _MobileNav({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Personal Details', Icons.person_outline, _EmployeeMenu.personalDetails),
      ('Professional Profile', Icons.work_outline, _EmployeeMenu.professionalProfile),
      ('Compensation', Icons.account_balance_wallet_outlined, _EmployeeMenu.compensation),
      ('Tax Information', Icons.assignment_outlined, _EmployeeMenu.taxInformation),
      ('Time Sheet', Icons.access_time_outlined, _EmployeeMenu.timeSheet),
      ("FAQ's", Icons.help_outline, _EmployeeMenu.faqs),
    ];

    return Container(
      height: 60,
      color: Colors.grey.shade50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final (title, icon, menu) = items[index];
          final isSelected = selected == menu;

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF782B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF782B) : Colors.grey.shade300,
              ),
            ),
            child: TextButton.icon(
              onPressed: () => onSelect(menu),
              icon: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              label: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Content Panel Component
class _ContentPanel extends StatelessWidget {
  final _EmployeeMenu selected;
  final EmployeeRecord? employeeRecord;
  final bool forceEditMode;
  final Function(String?) onProfileImageUpdated;
  final Function(Uint8List?) onProfileImageBytesUpdated;
  final Function(String) onEmployeeNameUpdated;
  final ValueChanged<EmployeePersonalDetails> onPersonalDetailsSaved;
  final ValueChanged<EmployeeProfessionalProfile> onProfessionalProfileSaved;

  const _ContentPanel({
    required this.selected,
    required this.employeeRecord,
    required this.forceEditMode,
    required this.onProfileImageUpdated,
    required this.onProfileImageBytesUpdated,
    required this.onEmployeeNameUpdated,
    required this.onPersonalDetailsSaved,
    required this.onProfessionalProfileSaved,
  });

  @override
  Widget build(BuildContext context) {
    final record = employeeRecord;
    if (record == null) {
      return const Center(child: Text('Employee data unavailable'));
    }
    switch (selected) {
      case _EmployeeMenu.personalDetails:
        return _PersonalDetailsContent(
          initialDetails: record.personal,
          onProfileImageUpdated: onProfileImageUpdated,
          onProfileImageBytesUpdated: onProfileImageBytesUpdated,
          onEmployeeNameUpdated: onEmployeeNameUpdated,
          onSaved: onPersonalDetailsSaved,
          forceEditMode: forceEditMode,
        );
      case _EmployeeMenu.professionalProfile:
        return _ProfessionalProfileContent(
          employeeId: record.id,
          initialProfile: record.professional,
          onSaved: onProfessionalProfileSaved,
          forceEditMode: forceEditMode,
        );
      case _EmployeeMenu.compensation:
        return _CompensationContent(forceEditMode: forceEditMode);
      case _EmployeeMenu.taxInformation:
        return _TaxInformationContent(forceEditMode: forceEditMode);
      case _EmployeeMenu.timeSheet:
        return _TimeSheetContent(forceEditMode: forceEditMode);
      case _EmployeeMenu.faqs:
        return _FAQsContent(forceEditMode: forceEditMode);
    }
  }
}

// Personal Details Content Component
class _PersonalDetailsContent extends StatefulWidget {
  final EmployeePersonalDetails initialDetails;
  final ValueChanged<EmployeePersonalDetails> onSaved;
  final bool forceEditMode;
  final Function(String?) onProfileImageUpdated;
  final Function(Uint8List?) onProfileImageBytesUpdated;
  final Function(String) onEmployeeNameUpdated;

  const _PersonalDetailsContent({
    required this.initialDetails,
    required this.onSaved,
    required this.forceEditMode,
    required this.onProfileImageUpdated,
    required this.onProfileImageBytesUpdated,
    required this.onEmployeeNameUpdated,
  });

  @override
  State<_PersonalDetailsContent> createState() => _PersonalDetailsContentState();
}

class _PersonalDetailsContentState extends State<_PersonalDetailsContent> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _fullName = TextEditingController();
  final _familyName = TextEditingController(); // Combined Father/Mother/Spouse Name
  final _email = TextEditingController();
  final _personalEmail = TextEditingController();
  final _mobile = TextEditingController();
  final _alternateMobile = TextEditingController();
  final _currentAddress = TextEditingController();
  final _permanentAddress = TextEditingController();
  final _panId = TextEditingController();
  final _aadharId = TextEditingController();

  // State variables
  DateTime? _selectedDateOfBirth;
  String? _selectedBloodGroup;
  String? _profileImageUrl;
  Uint8List? _profileImageBytes;
  Uint8List? _tempProfileImageBytes; // Temporary storage for profile image until form is saved
  bool _isEditMode = false; // Controls whether form is in edit mode

  // Asset Details State Variables
  final List<String> _commonAssets = ['Laptop', 'Desktop', 'Monitor', 'Keyboard', 'Mouse', 'Headphones', 'Mobile Phone'];
  final Set<String> _selectedAssets = {};
  final TextEditingController _otherAssetsController = TextEditingController();
  bool _showOtherAssetsField = false;
  late EmployeePersonalDetails _workingDetails;

  @override
  void initState() {
    super.initState();
    _applyInitialDetails(widget.initialDetails);
    _isEditMode = widget.forceEditMode;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _familyName.dispose();
    _email.dispose();
    _personalEmail.dispose();
    _mobile.dispose();
    _alternateMobile.dispose();
    _currentAddress.dispose();
    _permanentAddress.dispose();
    _panId.dispose();
    _aadharId.dispose();
    _otherAssetsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    if (!_isEditMode) return; // Only allow editing in edit mode

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    if (!_isEditMode) return; // Prevent upload when not in edit mode

    try {
      // Create a file input element
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*'; // Only accept image files
      input.multiple = false; // Single file selection

      // Show file picker
      input.click();

      // Wait for user to select a file
      await input.onChange.first;

      if (input.files!.isNotEmpty) {
        final html.File file = input.files![0];

        // Validate file type
        if (!file.type.startsWith('image/')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a valid image file')),
          );
          return;
        }

        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image smaller than 5MB')),
          );
          return;
        }

        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading image...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Read file as bytes
        final html.FileReader reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        await reader.onLoad.first;

        final Uint8List bytes = reader.result as Uint8List;

        // Update temporary state with the image bytes (will be submitted on save)
        setState(() {
          _tempProfileImageBytes = bytes;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture selected. Click "Save Details" to apply changes.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _applyInitialDetails(EmployeePersonalDetails details) {
    _workingDetails = details.copy();
    _fullName.text = details.fullName;
    _familyName.text = details.familyName;
    _email.text = details.corporateEmail;
    _personalEmail.text = details.personalEmail;
    _mobile.text = details.mobileNumber;
    _alternateMobile.text = details.alternateMobileNumber;
    _currentAddress.text = details.currentAddress;
    _permanentAddress.text = details.permanentAddress;
    _panId.text = details.panId;
    _aadharId.text = details.aadharId;
    _selectedDateOfBirth = details.dateOfBirth;
    _selectedBloodGroup = details.bloodGroup.isEmpty ? null : details.bloodGroup;
    _selectedAssets.clear();
    _selectedAssets.addAll(details.assignedAssets);
    _otherAssetsController.text = details.otherAssets;
    _profileImageBytes = details.profileImageBytes;
    _showOtherAssetsField = details.otherAssets.isNotEmpty;
    _tempProfileImageBytes = null;
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initialDetails, widget.initialDetails)) {
      setState(() {
        _applyInitialDetails(widget.initialDetails);
        _isEditMode = widget.forceEditMode;
      });
    } else if (oldWidget.forceEditMode != widget.forceEditMode) {
      setState(() {
        _isEditMode = widget.forceEditMode;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String? hint, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: !_isEditMode || readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
        filled: !_isEditMode,
        fillColor: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isEditMode ? () => _selectDateOfBirth(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _isEditMode ? const Color(0xFFFF782B) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDateOfBirth != null
                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                  : 'Select Date of Birth',
              style: TextStyle(
                color: _selectedDateOfBirth != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: 'Blood Group',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
        filled: !_isEditMode,
        fillColor: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
      ),
      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((bloodGroup) => DropdownMenuItem(
                value: bloodGroup,
                child: Text(bloodGroup),
              ))
          .toList(),
      onChanged: _isEditMode ? (value) {
        setState(() {
          _selectedBloodGroup = value;
        });
      } : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select blood group';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile picture upload
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Personal Details',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_isEditMode) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit Mode',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditMode
                            ? 'You can now edit your personal information. Click "Save Details" when finished.'
                            : 'Manage your personal information, contact details, and profile settings.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),

            const SizedBox(height: 32),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  Text(
                    'Basic Information',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      return Column(
                        children: [
                          if (isWide) ...[
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Full Name', _fullName)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField('Father/Mother/Spouse Name', _familyName, hint: 'Enter family member names')),
                              ],
                            ),
                          ] else ...[
                            _buildTextField('Full Name', _fullName),
                            const SizedBox(height: 16),
                            _buildTextField('Father/Mother/Spouse Name', _familyName, hint: 'Enter family member names'),
                          ],
                          const SizedBox(height: 16),
                          if (isWide) ...[
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Email', _email)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField('Personal Email ID', _personalEmail)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Mobile Number', _mobile)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField('Alternate Number', _alternateMobile)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildDateField()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildBloodGroupDropdown()),
                              ],
                            ),
                          ] else ...[
                            _buildTextField('Email', _email),
                            const SizedBox(height: 16),
                            _buildTextField('Personal Email ID', _personalEmail),
                            const SizedBox(height: 16),
                            _buildTextField('Mobile Number', _mobile),
                            const SizedBox(height: 16),
                            _buildTextField('Alternate Number', _alternateMobile),
                            const SizedBox(height: 16),
                            _buildDateField(),
                            const SizedBox(height: 16),
                            _buildBloodGroupDropdown(),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Address Information
                  Text(
                    'Address Information',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      return Column(
                        children: [
                          if (isWide) ...[
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Current Address', _currentAddress, maxLines: 3)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField('Permanent Address', _permanentAddress, maxLines: 3)),
                              ],
                            ),
                          ] else ...[
                            _buildTextField('Current Address', _currentAddress, maxLines: 3),
                            const SizedBox(height: 16),
                            _buildTextField('Permanent Address', _permanentAddress, maxLines: 3),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Government IDs
                  Text(
                    'Government Identification',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      return Column(
                        children: [
                          if (isWide) ...[
                            Row(
                              children: [
                                Expanded(child: _buildTextField('PAN ID', _panId)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField('Aadhar ID', _aadharId)),
                              ],
                            ),
                          ] else ...[
                            _buildTextField('PAN ID', _panId),
                            const SizedBox(height: 16),
                            _buildTextField('Aadhar ID', _aadharId),
                          ],
                          // Add clear spacing between ID fields and upload button
                          const SizedBox(height: 24),
                          // Profile picture upload button in Government IDs section - Disabled in view mode, enabled in edit mode
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: _isEditMode ? _pickProfileImage : null,
                              icon: const Icon(Icons.upload, size: 18),
                              label: const Text('Upload Profile Picture'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade400,
                                foregroundColor: _isEditMode ? Colors.white : Colors.grey.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Asset Details
                  Text(
                    'Asset Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Common Assets
                        Text(
                          'Select Assigned Assets:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._commonAssets.map((asset) => InkWell(
                              onTap: _isEditMode ? () {
                                setState(() {
                                  if (_selectedAssets.contains(asset)) {
                                    _selectedAssets.remove(asset);
                                  } else {
                                    _selectedAssets.add(asset);
                                  }
                                });
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedAssets.contains(asset)
                                      ? const Color(0xFFFF782B)
                                      : Colors.white,
                                  border: Border.all(
                                    color: _selectedAssets.contains(asset)
                                        ? const Color(0xFFFF782B)
                                        : Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  asset,
                                  style: TextStyle(
                                    color: _selectedAssets.contains(asset)
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )),
                            // Others option
                            InkWell(
                              onTap: _isEditMode ? () {
                                setState(() {
                                  _showOtherAssetsField = !_showOtherAssetsField;
                                  if (!_showOtherAssetsField) {
                                    _otherAssetsController.clear();
                                  }
                                });
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _showOtherAssetsField
                                      ? const Color(0xFFFF782B)
                                      : Colors.white,
                                  border: Border.all(
                                    color: _showOtherAssetsField
                                        ? const Color(0xFFFF782B)
                                        : Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Others',
                                      style: TextStyle(
                                        color: _showOtherAssetsField
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showOtherAssetsField ? Icons.remove : Icons.add,
                                      size: 16,
                                      color: _showOtherAssetsField
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Other assets text field (shown when Others is selected)
                        if (_showOtherAssetsField) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otherAssetsController,
                            enabled: _isEditMode,
                            decoration: InputDecoration(
                              labelText: 'Specify Other Assets',
                              hintText: 'Enter additional assets (comma-separated)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                              ),
                              filled: !_isEditMode,
                              fillColor: !_isEditMode ? Colors.grey.shade100 : Colors.transparent,
                            ),
                            validator: (value) {
                              if (_showOtherAssetsField && (value == null || value.trim().isEmpty)) {
                                return 'Please specify other assets';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Display selected assets in view mode
                        if (!_isEditMode && (_selectedAssets.isNotEmpty || _otherAssetsController.text.isNotEmpty)) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Selected Assets:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._selectedAssets.map((asset) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF782B).withOpacity(0.1),
                                  border: Border.all(color: const Color(0xFFFF782B)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  asset,
                                  style: const TextStyle(
                                    color: Color(0xFFFF782B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                              if (_otherAssetsController.text.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF782B).withOpacity(0.1),
                                    border: Border.all(color: const Color(0xFFFF782B)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _otherAssetsController.text,
                                    style: const TextStyle(
                                      color: Color(0xFFFF782B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],

                        // Empty state message
                        if (!_isEditMode && _selectedAssets.isEmpty && _otherAssetsController.text.isEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'No assets assigned yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditMode) {
                          // Save mode - validate and save
                          if (_formKey.currentState!.validate()) {
                            // Update employee name in parent state
                            widget.onEmployeeNameUpdated(_fullName.text);

                            // Submit profile image if one was selected
                            if (_tempProfileImageBytes != null) {
                              widget.onProfileImageBytesUpdated(_tempProfileImageBytes);
                              setState(() {
                                _profileImageBytes = _tempProfileImageBytes;
                                _tempProfileImageBytes = null; // Clear temporary storage
                              });
                            }

                            _workingDetails
                              ..fullName = _fullName.text
                              ..familyName = _familyName.text
                              ..corporateEmail = _email.text
                              ..personalEmail = _personalEmail.text
                              ..mobileNumber = _mobile.text
                              ..alternateMobileNumber = _alternateMobile.text
                              ..currentAddress = _currentAddress.text
                              ..permanentAddress = _permanentAddress.text
                              ..panId = _panId.text
                              ..aadharId = _aadharId.text
                              ..dateOfBirth = _selectedDateOfBirth
                              ..bloodGroup = _selectedBloodGroup ?? ''
                              ..assignedAssets = Set<String>.from(_selectedAssets)
                              ..otherAssets = _otherAssetsController.text
                              ..profileImageBytes = _profileImageBytes;
                            widget.onSaved(_workingDetails);

                            setState(() {
                              _isEditMode = widget.forceEditMode;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Personal details saved successfully!')),
                            );
                          }
                        } else {
                          // Edit mode - switch to edit mode
                          _toggleEditMode();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditMode ? Colors.green : const Color(0xFFFF782B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditMode ? 'Save Details' : 'Edit Personal Details',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Professional Profile Content Component
class _ProfessionalProfileContent extends StatefulWidget {
  final String employeeId;
  final EmployeeProfessionalProfile initialProfile;
  final ValueChanged<EmployeeProfessionalProfile> onSaved;
  final bool forceEditMode;

  const _ProfessionalProfileContent({
    required this.employeeId,
    required this.initialProfile,
    required this.onSaved,
    required this.forceEditMode,
  });

  @override
  State<_ProfessionalProfileContent> createState() => _ProfessionalProfileContentState();
}

class _ProfessionalProfileContentState extends State<_ProfessionalProfileContent> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _position = TextEditingController();
  final _employeeId = TextEditingController();
  final _department = TextEditingController();
  final _managerName = TextEditingController();
  final _employmentType = TextEditingController();
  final _location = TextEditingController();
  final _jobLevel = TextEditingController();
  final _skills = TextEditingController();

  // State variables
  DateTime? _startDate;
  DateTime? _confirmationDate;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _applyInitialProfile(widget.initialProfile);
    _isEditMode = widget.forceEditMode;
  }

  @override
  void dispose() {
    _position.dispose();
    _employeeId.dispose();
    _department.dispose();
    _managerName.dispose();
    _employmentType.dispose();
    _location.dispose();
    _jobLevel.dispose();
    _skills.dispose();
    super.dispose();
  }

  void _applyInitialProfile(EmployeeProfessionalProfile profile) {
    _position.text = profile.position;
    _employeeId.text = profile.employeeId;
    _department.text = profile.department;
    _managerName.text = profile.managerName;
    _employmentType.text = profile.employmentType;
    _location.text = profile.location;
    _jobLevel.text = profile.jobLevel;
    _skills.text = profile.skills;
    _startDate = profile.startDate;
    _confirmationDate = profile.confirmationDate;
  }

  EmployeeProfessionalProfile _buildUpdatedProfile() {
    final updatedProfile = widget.initialProfile.copy();
    updatedProfile
      ..position = _position.text
      ..employeeId = _employeeId.text
      ..department = _department.text
      ..managerName = _managerName.text
      ..employmentType = _employmentType.text
      ..location = _location.text
      ..jobLevel = _jobLevel.text
      ..skills = _skills.text
      ..startDate = _startDate
      ..confirmationDate = _confirmationDate;
    return updatedProfile;
  }

  @override
  void didUpdateWidget(covariant _ProfessionalProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initialProfile, widget.initialProfile)) {
      setState(() {
        _applyInitialProfile(widget.initialProfile);
        _isEditMode = widget.forceEditMode;
      });
    } else if (oldWidget.forceEditMode != widget.forceEditMode) {
      setState(() {
        _isEditMode = widget.forceEditMode;
      });
    }
  }

  Future<void> _selectStartDate() async {
    if (!_isEditMode) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectConfirmationDate() async {
    if (!_isEditMode) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _confirmationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _confirmationDate = picked;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Not set',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Professional Profile',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_isEditMode) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Edit Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isEditMode
                  ? 'You can now edit your professional information. Click "Save Details" when finished.'
                  : 'View and manage your professional information, education, and employment history.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Core Employment Details
            Text(
              'Employment Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Column(
                  children: [
                    if (isWide) ...[
                      Row(
                        children: [
                          Expanded(child: _isEditMode ? _buildEditableField('Position', _position) : _buildReadOnlyField('Position', _position.text)),
                          const SizedBox(width: 16),
                          Expanded(child: _isEditMode ? _buildEditableField('Employee ID', _employeeId, readOnly: true) : _buildReadOnlyField('Employee ID', _employeeId.text)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _isEditMode ? _buildEditableField('Department', _department) : _buildReadOnlyField('Department', _department.text)),
                          const SizedBox(width: 16),
                          Expanded(child: _isEditMode ? _buildEditableField('Manager Name', _managerName) : _buildReadOnlyField('Manager Name', _managerName.text)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _employmentType.text.isEmpty ? null : _employmentType.text,
                              decoration: InputDecoration(
                                labelText: 'Employment Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                                ),
                                filled: !_isEditMode,
                                fillColor: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              items: ['Full time', 'Contract', 'Intern']
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: !_isEditMode ? null : (value) {
                                setState(() {
                                  _employmentType.text = value ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _isEditMode ? _buildEditableField('Location', _location) : _buildReadOnlyField('Location', _location.text)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDateField('Start Date', _startDate, _selectStartDate)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDateField('Confirmation Date', _confirmationDate, _selectConfirmationDate)),
                        ],
                      ),
                    ] else ...[
                      _isEditMode ? _buildEditableField('Position', _position) : _buildReadOnlyField('Position', _position.text),
                      const SizedBox(height: 16),
                      _isEditMode ? _buildEditableField('Employee ID', _employeeId, readOnly: true) : _buildReadOnlyField('Employee ID', _employeeId.text),
                      const SizedBox(height: 16),
                      _isEditMode ? _buildEditableField('Department', _department) : _buildReadOnlyField('Department', _department.text),
                      const SizedBox(height: 16),
                      _isEditMode ? _buildEditableField('Manager Name', _managerName) : _buildReadOnlyField('Manager Name', _managerName.text),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _employmentType.text.isEmpty ? null : _employmentType.text,
                        decoration: InputDecoration(
                          labelText: 'Employment Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                          ),
                          filled: !_isEditMode,
                          fillColor: !_isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        items: ['Full time', 'Contract', 'Intern']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: !_isEditMode ? null : (value) {
                          setState(() {
                            _employmentType.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _isEditMode ? _buildEditableField('Location', _location) : _buildReadOnlyField('Location', _location.text),
                      const SizedBox(height: 16),
                      _buildDateField('Start Date', _startDate, _selectStartDate),
                      const SizedBox(height: 16),
                      _buildDateField('Confirmation Date', _confirmationDate, _selectConfirmationDate),
                      const SizedBox(height: 16),
                      _isEditMode ? _buildEditableField('Job Level/Grade', _jobLevel) : _buildReadOnlyField('Job Level/Grade', _jobLevel.text),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Skills Section
            Text(
              'Skillset',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _isEditMode
                ? TextFormField(
                    controller: _skills,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Skills (comma-separated)',
                      hintText: 'e.g., Flutter, Dart, React, Node.js, Python, AWS',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _skills.text.isEmpty ? 'No skills added yet' : _skills.text,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditMode) {
                    // Save mode - validate and save
                    if (_formKey.currentState!.validate()) {
                      final updatedProfile = _buildUpdatedProfile();
                      widget.onSaved(updatedProfile);
                      setState(() {
                        _isEditMode = widget.forceEditMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Professional profile saved successfully!')),
                      );
                    }
                  } else {
                    // Edit mode - switch to edit mode
                    _toggleEditMode();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditMode ? Colors.green : const Color(0xFFFF782B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditMode ? 'Save Details' : 'Edit Professional Profile',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Content Widget
class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF782B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.3), width: 2),
            ),
            child: Icon(
              icon,
              size: 60,
              color: const Color(0xFFFF782B),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Content for $title goes here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Compensation Content Component
class _CompensationContent extends StatelessWidget {
  final bool forceEditMode;

  const _CompensationContent({required this.forceEditMode});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.attach_money,
      title: 'Compensation & Benefits',
      description: 'View your salary details, benefits, allowances, and tax information. This section will display your compensation structure and benefits package.',
    );
  }
}

// Tax Information Content Component
class _TaxInformationContent extends StatelessWidget {
  final bool forceEditMode;

  const _TaxInformationContent({required this.forceEditMode});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.account_balance,
      title: 'Tax Information',
      description: 'Manage your tax-related information, including tax declarations, exemptions, and tax-saving investments.',
    );
  }
}

// Time Sheet Content Component
class _TimeSheetContent extends StatelessWidget {
  final bool forceEditMode;

  const _TimeSheetContent({required this.forceEditMode});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.schedule,
      title: 'Time Sheet & Attendance',
      description: 'Track your work hours, manage leave requests, submit timesheets, and view attendance records.',
    );
  }
}

// FAQs Content Component
class _FAQsContent extends StatelessWidget {
  final bool forceEditMode;

  const _FAQsContent({required this.forceEditMode});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.help_center,
      title: 'FAQs & Support',
      description: 'Find answers to frequently asked questions about HR policies, procedures, and company benefits.',
    );
  }
}
