import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html; // For web file picker
import 'dart:typed_data';
import '../services/auth_service.dart';

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
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  _EmployeeMenu _selected = _EmployeeMenu.personalDetails; // initial: personal details
  String? _profileImageUrl; // State for profile image URL
  String _employeeName = 'John Doe'; // State for employee name
  Uint8List? _profileImageBytes; // State for profile image bytes

  @override
  Widget build(BuildContext context) {
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
                        onProfileImageUpdated: (url) {
                          setState(() => _profileImageUrl = url);
                        },
                        onProfileImageBytesUpdated: (bytes) {
                          setState(() => _profileImageBytes = bytes);
                        },
                        onEmployeeNameUpdated: (name) {
                          setState(() => _employeeName = name);
                        },
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
                      onProfileImageUpdated: (url) {
                        setState(() => _profileImageUrl = url);
                      },
                      onProfileImageBytesUpdated: (bytes) {
                        setState(() => _profileImageBytes = bytes);
                      },
                      onEmployeeNameUpdated: (name) {
                        setState(() => _employeeName = name);
                      },
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

  const _EmployeeDashboardHeader({
    required this.onLogout,
    this.profileImageUrl,
    this.profileImageBytes,
    required this.employeeName,
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

            // Logout Button
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
  final Function(String?) onProfileImageUpdated;
  final Function(Uint8List?) onProfileImageBytesUpdated;
  final Function(String) onEmployeeNameUpdated;

  const _ContentPanel({
    required this.selected,
    required this.onProfileImageUpdated,
    required this.onProfileImageBytesUpdated,
    required this.onEmployeeNameUpdated,
  });

  @override
  Widget build(BuildContext context) {
    switch (selected) {
      case _EmployeeMenu.personalDetails:
        return _PersonalDetailsContent(
          onProfileImageUpdated: onProfileImageUpdated,
          onProfileImageBytesUpdated: onProfileImageBytesUpdated,
          onEmployeeNameUpdated: onEmployeeNameUpdated,
        );
      case _EmployeeMenu.professionalProfile:
        return _ProfessionalProfileContent();
      case _EmployeeMenu.compensation:
        return _CompensationContent();
      case _EmployeeMenu.taxInformation:
        return _TaxInformationContent();
      case _EmployeeMenu.timeSheet:
        return _TimeSheetContent();
      case _EmployeeMenu.faqs:
        return _FAQsContent();
    }
  }
}

// Personal Details Content Component
class _PersonalDetailsContent extends StatefulWidget {
  final Function(String?) onProfileImageUpdated;
  final Function(Uint8List?) onProfileImageBytesUpdated;
  final Function(String) onEmployeeNameUpdated;

  const _PersonalDetailsContent({
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

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _fullName.text = 'John Doe';
    _familyName.text = 'Robert Doe (Father), Jane Doe (Mother), Mary Doe (Spouse)'; // Combined family names
    _email.text = 'john.doe@apexnuera.com';
    _personalEmail.text = 'john.doe@gmail.com';
    _mobile.text = '+91 98765 43210';
    _alternateMobile.text = '+91 98765 43211';
    _currentAddress.text = '123 Main Street, Tech City, State - 123456';
    _permanentAddress.text = '456 Home Street, Hometown, State - 654321';
    _panId.text = 'ABCDE1234F';
    _aadharId.text = '1234 5678 9012';
    _selectedDateOfBirth = DateTime(1990, 5, 15);
    _selectedBloodGroup = 'O+';
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

                            setState(() {
                              _isEditMode = false; // Switch back to view mode
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

class _ProfessionalProfileContent extends StatefulWidget {
  @override
  State<_ProfessionalProfileContent> createState() => _ProfessionalProfileContentState();
}

class _ProfessionalProfileContentState extends State<_ProfessionalProfileContent> {
  final _formKey = GlobalKey<FormState>();

  // Core Employment Details Controllers
  final _position = TextEditingController();
  final _employeeId = TextEditingController();
  final _department = TextEditingController();
  final _managerName = TextEditingController();
  final _employmentType = TextEditingController();
  final _location = TextEditingController();
  final _workSpace = TextEditingController();
  final _jobLevel = TextEditingController();

  // Education Details
  final List<_EducationEntry> _educationEntries = [];

  // Skills
  final _skills = TextEditingController();

  // Employment History
  final List<_EmploymentEntry> _employmentEntries = [];

  // State variables
  DateTime? _startDate;
  DateTime? _confirmationDate;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _position.text = 'Senior Software Engineer';
    _employeeId.text = 'EMP001';
    _department.text = 'Engineering';
    _managerName.text = 'John Smith';
    _employmentType.text = 'Full time';
    _location.text = 'New York, NY';
    _workSpace.text = 'Hybrid';
    _jobLevel.text = 'Level 5';
    _startDate = DateTime(2022, 1, 15);
    _confirmationDate = DateTime(2022, 7, 15);
    _skills.text = 'Flutter, Dart, React, Node.js, Python, AWS';

    // Initialize with sample education entries
    _educationEntries.add(_EducationEntry(
      level: 'Highest Graduation',
      institution: 'MIT',
      degree: 'Bachelor of Computer Science',
      year: '2020',
      grade: 'A+',
    ));

    // Initialize with sample employment history
    _employmentEntries.add(_EmploymentEntry(
      companyName: 'Tech Corp',
      designation: 'Software Developer',
      fromDate: DateTime(2020, 6, 1),
      toDate: DateTime(2022, 1, 14),
    ));
  }

  @override
  void dispose() {
    _position.dispose();
    _employeeId.dispose();
    _department.dispose();
    _managerName.dispose();
    _employmentType.dispose();
    _location.dispose();
    _workSpace.dispose();
    _jobLevel.dispose();
    _skills.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectConfirmationDate(BuildContext context) async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _confirmationDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _confirmationDate) {
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

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditMode || readOnly,
      decoration: InputDecoration(
        labelText: label,
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

  Widget _buildDateField(String label, DateTime? date, Function(BuildContext) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isEditMode ? () => onTap(context) : null,
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
                  date != null ? '${date.day}/${date.month}/${date.year}' : 'Select $label',
                  style: TextStyle(
                    color: date != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Professional Profile',
                              style: TextStyle(
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
                      ],
                    ),
                  ),
                ],
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

              // Education Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Education Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isEditMode)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _educationEntries.add(_EducationEntry());
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Education'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF782B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Education Entries
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _educationEntries.length,
                itemBuilder: (context, index) {
                  return _EducationEntryWidget(
                    entry: _educationEntries[index],
                    isEditMode: _isEditMode,
                    onChanged: (updatedEntry) {
                      setState(() {
                        _educationEntries[index] = updatedEntry;
                      });
                    },
                    onRemove: _isEditMode ? () {
                      setState(() {
                        _educationEntries.removeAt(index);
                      });
                    } : null,
                  );
                },
              ),

              if (_educationEntries.isEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'No education details added yet. Click "Add Education" to get started.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ],

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

              // Employment History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Employment History',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isEditMode)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _employmentEntries.add(_EmploymentEntry());
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Employment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF782B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Employment History Entries
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _employmentEntries.length,
                itemBuilder: (context, index) {
                  return _EmploymentEntryWidget(
                    entry: _employmentEntries[index],
                    isEditMode: _isEditMode,
                    onChanged: (updatedEntry) {
                      setState(() {
                        _employmentEntries[index] = updatedEntry;
                      });
                    },
                    onRemove: _isEditMode ? () {
                      setState(() {
                        _employmentEntries.removeAt(index);
                      });
                    } : null,
                  );
                },
              ),

              if (_employmentEntries.isEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'No employment history added yet. Click "Add Employment" to get started.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ],

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
                        setState(() {
                          _isEditMode = false; // Switch back to view mode
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
      ),
    );
  }
}

// Education Entry Model
class _EducationEntry {
  String level;
  String institution;
  String degree;
  String year;
  String grade;
  Uint8List? documentBytes;
  String? documentName;

  _EducationEntry({
    this.level = '',
    this.institution = '',
    this.degree = '',
    this.year = '',
    this.grade = '',
    this.documentBytes,
    this.documentName,
  });
}

// Education Entry Widget
class _EducationEntryWidget extends StatefulWidget {
  final _EducationEntry entry;
  final bool isEditMode;
  final Function(_EducationEntry) onChanged;
  final VoidCallback? onRemove;

  const _EducationEntryWidget({
    required this.entry,
    required this.isEditMode,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_EducationEntryWidget> createState() => _EducationEntryWidgetState();
}

class _EducationEntryWidgetState extends State<_EducationEntryWidget> {
  late TextEditingController _levelController;
  late TextEditingController _institutionController;
  late TextEditingController _degreeController;
  late TextEditingController _yearController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(text: widget.entry.level);
    _institutionController = TextEditingController(text: widget.entry.institution);
    _degreeController = TextEditingController(text: widget.entry.degree);
    _yearController = TextEditingController(text: widget.entry.year);
    _gradeController = TextEditingController(text: widget.entry.grade);
  }

  @override
  void dispose() {
    _levelController.dispose();
    _institutionController.dispose();
    _degreeController.dispose();
    _yearController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _updateEntry() {
    final updatedEntry = _EducationEntry(
      level: _levelController.text,
      institution: _institutionController.text,
      degree: _degreeController.text,
      year: _yearController.text,
      grade: _gradeController.text,
    );
    widget.onChanged(updatedEntry);
  }

  Widget _buildDocumentLink(BuildContext context, String documentName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Document:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening "$documentName" for review...')),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                documentName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onRemove != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove this entry',
                  ),
                ],
              ),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Column(
                  children: [
                    if (isWide) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _levelController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Education Level',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _institutionController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Institution',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _degreeController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Degree/Program',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Year of Completion',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _gradeController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Grade/Percentage',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: widget.isEditMode ? () async {
                                  // Create file input element using the correct HTML API
                                  final input = html.FileUploadInputElement();
                                  input.accept = 'image/*,.pdf,.doc,.docx,.txt'; // Accept common document types
                                  input.multiple = false; // Single file selection

                                  // Show file picker
                                  input.click();

                                  // Wait for user to select a file
                                  await input.onChange.first;

                                  // Process selected file
                                  if (input.files != null && input.files!.isNotEmpty) {
                                    final file = input.files![0];
                                    final reader = html.FileReader();

                                    reader.onLoadEnd.listen((e) {
                                      final Uint8List fileBytes = reader.result as Uint8List;
                                      final String fileName = file.name;
                                      final int fileSize = file.size ?? 0;

                                      // Validate file size (10MB limit)
                                      if (fileSize > 10 * 1024 * 1024) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('File size must be less than 10MB')),
                                        );
                                        return;
                                      }

                                      // Show success message with file details
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Document "$fileName" (${(fileSize / 1024).toStringAsFixed(1)} KB) uploaded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      // Store the file for the entry
                                      final updatedEntry = _EducationEntry(
                                        level: _levelController.text,
                                        institution: _institutionController.text,
                                        degree: _degreeController.text,
                                        year: _yearController.text,
                                        grade: _gradeController.text,
                                        documentBytes: fileBytes,
                                        documentName: fileName,
                                      );
                                      widget.onChanged(updatedEntry);
                                    });

                                    reader.readAsArrayBuffer(file);
                                  }
                                } : null,
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: const Text('Upload Docs'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade400,
                                  foregroundColor: widget.isEditMode ? Colors.white : Colors.grey.shade600,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Container()), // Spacer for layout balance
                        ],
                      ),
                      // Display uploaded document if exists
                      if (widget.entry.documentName != null && widget.entry.documentName!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDocumentLink(context, widget.entry.documentName!),
                      ],
                    ] else ...[
                      TextFormField(
                        controller: _levelController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Education Level',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _institutionController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Institution',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _degreeController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Degree/Program',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Year of Completion',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gradeController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Grade/Percentage',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: widget.isEditMode ? () async {
                            // Create file input element using the correct HTML API
                            final input = html.FileUploadInputElement();
                            input.accept = 'image/*,.pdf,.doc,.docx,.txt'; // Accept common document types
                            input.multiple = false; // Single file selection

                            // Show file picker
                            input.click();

                            // Wait for user to select a file
                            await input.onChange.first;

                            // Process selected file
                            if (input.files != null && input.files!.isNotEmpty) {
                              final file = input.files![0];
                              final reader = html.FileReader();

                              reader.onLoadEnd.listen((e) {
                                final Uint8List fileBytes = reader.result as Uint8List;
                                final String fileName = file.name;
                                final int fileSize = file.size ?? 0;

                                // Validate file size (10MB limit)
                                if (fileSize > 10 * 1024 * 1024) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('File size must be less than 10MB')),
                                  );
                                  return;
                                }

                                // Show success message with file details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Document "$fileName" (${(fileSize / 1024).toStringAsFixed(1)} KB) uploaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Store the file for the entry
                                final updatedEntry = _EducationEntry(
                                  level: _levelController.text,
                                  institution: _institutionController.text,
                                  degree: _degreeController.text,
                                  year: _yearController.text,
                                  grade: _gradeController.text,
                                  documentBytes: fileBytes,
                                  documentName: fileName,
                                );
                                widget.onChanged(updatedEntry);
                              });

                              reader.readAsArrayBuffer(file);
                            }
                          } : null,
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Upload Docs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade400,
                            foregroundColor: widget.isEditMode ? Colors.white : Colors.grey.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      // Display uploaded document if exists
                      if (widget.entry.documentName != null && widget.entry.documentName!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDocumentLink(context, widget.entry.documentName!),
                      ],
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Employment Entry Model
class _EmploymentEntry {
  String companyName;
  String designation;
  DateTime? fromDate;
  DateTime? toDate;
  Uint8List? documentBytes;
  String? documentName;

  _EmploymentEntry({
    this.companyName = '',
    this.designation = '',
    this.fromDate,
    this.toDate,
    this.documentBytes,
    this.documentName,
  });
}

// Employment Entry Widget
class _EmploymentEntryWidget extends StatefulWidget {
  final _EmploymentEntry entry;
  final bool isEditMode;
  final Function(_EmploymentEntry) onChanged;
  final VoidCallback? onRemove;

  const _EmploymentEntryWidget({
    required this.entry,
    required this.isEditMode,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_EmploymentEntryWidget> createState() => _EmploymentEntryWidgetState();
}

class _EmploymentEntryWidgetState extends State<_EmploymentEntryWidget> {
  late TextEditingController _companyNameController;
  late TextEditingController _designationController;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.entry.companyName);
    _designationController = TextEditingController(text: widget.entry.designation);
    _fromDate = widget.entry.fromDate;
    _toDate = widget.entry.toDate;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _updateEntry() {
    final updatedEntry = _EmploymentEntry(
      companyName: _companyNameController.text,
      designation: _designationController.text,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    widget.onChanged(updatedEntry);
  }

  Widget _buildDocumentLink(BuildContext context, String documentName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Document:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening "$documentName" for review...')),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                documentName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    if (!widget.isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
      _updateEntry();
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    if (!widget.isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
      _updateEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onRemove != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove this entry',
                  ),
                ],
              ),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Column(
                  children: [
                    if (isWide) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _companyNameController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                              validator: (value) {
                                if (widget.isEditMode && (value == null || value.trim().isEmpty)) {
                                  return 'Please enter company name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _designationController,
                              readOnly: !widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: 'Designation',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: !widget.isEditMode,
                                fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                              ),
                              onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                              validator: (value) {
                                if (widget.isEditMode && (value == null || value.trim().isEmpty)) {
                                  return 'Please enter designation';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: widget.isEditMode ? () => _selectFromDate(context) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                  color: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _fromDate != null ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}' : 'From Date',
                                      style: TextStyle(
                                        color: _fromDate != null ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: widget.isEditMode ? () => _selectToDate(context) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                  color: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _toDate != null ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}' : 'To Date',
                                      style: TextStyle(
                                        color: _toDate != null ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: widget.isEditMode ? () async {
                                  // Create file input element using the correct HTML API
                                  final input = html.FileUploadInputElement();
                                  input.accept = 'image/*,.pdf,.doc,.docx,.txt'; // Accept common document types
                                  input.multiple = false; // Single file selection

                                  // Show file picker
                                  input.click();

                                  // Wait for user to select a file
                                  await input.onChange.first;

                                  // Process selected file
                                  if (input.files != null && input.files!.isNotEmpty) {
                                    final file = input.files![0];
                                    final reader = html.FileReader();

                                    reader.onLoadEnd.listen((e) {
                                      final Uint8List fileBytes = reader.result as Uint8List;
                                      final String fileName = file.name;
                                      final int fileSize = file.size ?? 0;

                                      // Validate file size (10MB limit)
                                      if (fileSize > 10 * 1024 * 1024) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('File size must be less than 10MB')),
                                        );
                                        return;
                                      }

                                      // Show success message with file details
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Document "$fileName" (${(fileSize / 1024).toStringAsFixed(1)} KB) uploaded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      // Store the file for the entry
                                      final updatedEntry = _EmploymentEntry(
                                        companyName: _companyNameController.text,
                                        designation: _designationController.text,
                                        fromDate: _fromDate,
                                        toDate: _toDate,
                                        documentBytes: fileBytes,
                                        documentName: fileName,
                                      );
                                      widget.onChanged(updatedEntry);
                                    });

                                    reader.readAsArrayBuffer(file);
                                  }
                                } : null,
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: const Text('Upload Docs'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade400,
                                  foregroundColor: widget.isEditMode ? Colors.white : Colors.grey.shade600,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Container()), // Spacer for layout balance
                        ],
                      ),
                      // Display uploaded document if exists
                      if (widget.entry.documentName != null && widget.entry.documentName!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDocumentLink(context, widget.entry.documentName!),
                      ],
                    ] else ...[
                      TextFormField(
                        controller: _companyNameController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                        validator: (value) {
                          if (widget.isEditMode && (value == null || value.trim().isEmpty)) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _designationController,
                        readOnly: !widget.isEditMode,
                        decoration: InputDecoration(
                          labelText: 'Designation',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: !widget.isEditMode,
                          fillColor: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                        ),
                        onChanged: widget.isEditMode ? (_) => _updateEntry() : null,
                        validator: (value) {
                          if (widget.isEditMode && (value == null || value.trim().isEmpty)) {
                            return 'Please enter designation';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: widget.isEditMode ? () => _selectFromDate(context) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _fromDate != null ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}' : 'From Date',
                                style: TextStyle(
                                  color: _fromDate != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: widget.isEditMode ? () => _selectToDate(context) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: !widget.isEditMode ? Colors.grey.shade50 : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _toDate != null ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}' : 'To Date',
                                style: TextStyle(
                                  color: _toDate != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: widget.isEditMode ? () async {
                            // Create file input element using the correct HTML API
                            final input = html.FileUploadInputElement();
                            input.accept = 'image/*,.pdf,.doc,.docx,.txt'; // Accept common document types
                            input.multiple = false; // Single file selection

                            // Show file picker
                            input.click();

                            // Wait for user to select a file
                            await input.onChange.first;

                            // Process selected file
                            if (input.files != null && input.files!.isNotEmpty) {
                              final file = input.files![0];
                              final reader = html.FileReader();

                              reader.onLoadEnd.listen((e) {
                                final Uint8List fileBytes = reader.result as Uint8List;
                                final String fileName = file.name;
                                final int fileSize = file.size ?? 0;

                                // Validate file size (10MB limit)
                                if (fileSize > 10 * 1024 * 1024) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('File size must be less than 10MB')),
                                  );
                                  return;
                                }

                                // Show success message with file details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Document "$fileName" (${(fileSize / 1024).toStringAsFixed(1)} KB) uploaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Store the file for the entry
                                final updatedEntry = _EmploymentEntry(
                                  companyName: _companyNameController.text,
                                  designation: _designationController.text,
                                  fromDate: _fromDate,
                                  toDate: _toDate,
                                  documentBytes: fileBytes,
                                  documentName: fileName,
                                );
                                widget.onChanged(updatedEntry);
                              });

                              reader.readAsArrayBuffer(file);
                            }
                          } : null,
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Upload Docs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isEditMode ? const Color(0xFFFF782B) : Colors.grey.shade400,
                            foregroundColor: widget.isEditMode ? Colors.white : Colors.grey.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      // Display uploaded document if exists
                      if (widget.entry.documentName != null && widget.entry.documentName!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Document: ${widget.entry.documentName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Simulate opening document in new tab or modal
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Opening document for review...')),
                                  );
                                  // TODO: Implement actual document viewing logic (e.g., open in new tab)
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF782B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompensationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ContentPlaceholder(
      title: 'Compensation',
      description: 'Access your salary information, benefits, and compensation details.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}

class _TaxInformationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ContentPlaceholder(
      title: 'Tax Information',
      description: 'View your tax documents, deductions, and tax-related information.',
      icon: Icons.assignment_outlined,
    );
  }
}

class _TimeSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ContentPlaceholder(
      title: 'Time Sheet',
      description: 'Track your work hours, attendance, and time-related activities.',
      icon: Icons.access_time_outlined,
    );
  }
}

class _FAQsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ContentPlaceholder(
      title: "FAQ's",
      description: 'Find answers to frequently asked questions about company policies and procedures.',
      icon: Icons.help_outline,
    );
  }
}

// Generic Placeholder Content Widget
class _ContentPlaceholder extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ContentPlaceholder({
    required this.title,
    required this.description,
    required this.icon,
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
