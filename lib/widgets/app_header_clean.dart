import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16.0 : 40.0,
        vertical: 20.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSmallScreen ? _buildMobileHeader(context) : _buildDesktopHeader(context),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final location = GoRouter.of(context).routeInformationProvider.value.location;
    final showSearch =
        location.startsWith('/career/jobs') ||
        location.startsWith('/career/internships') ||
        location.startsWith('/jobs') ||
        location.startsWith('/internships');

    return Row(
      children: [
        _buildLogo(),
        if (showSearch) const SizedBox(width: 16),
        if (showSearch)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildSearchBar(context, location),
            ),
          ),
        if (!showSearch) const Spacer(),
        _buildNavigationMenu(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => _showMobileMenu(context),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF782B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LOGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context) {
    final items = [
      'Home',
      'Campus Commune',
      'Help & Support',
      'Career',
      'Login',
    ];
    final routeName = GoRouter.of(context).routeInformationProvider.value.location;
    const activeColor = Color(0xFFFF782B);
    const baseColor = Colors.black87;
    return Row(
      children: items.map((label) {
        if (label == 'Career') {
          return _buildCareerDropdown(context);
        }
        final isActive = _isLabelActive(label, routeName);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextButton(
            onPressed: () => _handleNavigation(context, label),
            child: Row(
              children: [
                Icon(_iconForLabel(label), color: isActive ? activeColor : baseColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : baseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: isActive ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: activeColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCareerDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.work_outline, color: Colors.black87, size: 18),
              SizedBox(width: 6),
              Text(
                'Career',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.black87, size: 18),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'Jobs',
            child: Row(
              children: const [
                Icon(Icons.work_outline, color: Color(0xFFFF782B), size: 20),
                SizedBox(width: 12),
                Text('Jobs'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Internships',
            child: Row(
              children: const [
                Icon(Icons.school_outlined, color: Color(0xFFFF782B), size: 20),
                SizedBox(width: 12),
                Text('Internships'),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'Jobs') {
            context.push('/jobs');
          } else if (value == 'Internships') {
            context.push('/internships');
          }
        },
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final label in ['Home', 'Campus Commune', 'Help & Support'])
                ListTile(
                  leading: Icon(_iconForLabel(label), color: const Color(0xFFFF782B)),
                  title: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleNavigation(context, label);
                  },
                ),
              ExpansionTile(
                title: const Text('Career', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                children: [
                  ListTile(
                    leading: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
                    title: const Text('Jobs'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/jobs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
                    title: const Text('Internships'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/internships');
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.login, color: Color(0xFFFF782B)),
                title: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _handleNavigation(context, 'Login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, String item) {
    switch (item) {
      case 'Campus Commune':
        context.push('/campus-commune');
        break;
      case 'Help & Support':
        context.push('/help-support');
        break;
      case 'Login':
        context.push('/login');
        break;
      case 'Home':
        context.go('/home');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon'), duration: Duration(seconds: 1)),
        );
    }
  }

  IconData _iconForLabel(String label) {
    switch (label) {
      case 'Home':
        return Icons.home_outlined;
      case 'Campus Commune':
        return Icons.people_alt_outlined;
      case 'Help & Support':
        return Icons.help_outline;
      case 'Login':
        return Icons.login;
      default:
        return Icons.circle_outlined;
    }
  }

  bool _isLabelActive(String label, String routeName) {
    switch (label) {
      case 'Home':
        return routeName == '/home' || routeName == Navigator.defaultRouteName;
      case 'Campus Commune':
        return routeName == '/campus-commune';
      case 'Help & Support':
        return routeName == '/help-support';
      case 'Login':
        return routeName.startsWith('/login');
      default:
        return false;
    }
  }

  Widget _buildSearchBar(BuildContext context, String location) {
    final isJobs = location.startsWith('/career/jobs') || location.startsWith('/jobs');
    final isInternships = location.startsWith('/career/internships') || location.startsWith('/internships');
    final hint = isJobs ? 'Search ' : (isInternships ? 'Search ' : 'Search');
    final controller = TextEditingController();

    void submit(String q) {
      final encoded = Uri.encodeQueryComponent(q.trim());
      if (encoded.isEmpty) return;
      if (isJobs) {
        final target = location.startsWith('/career') ? '/career/jobs' : '/jobs';
        context.go('$target?q=$encoded');
      } else if (isInternships) {
        final target = location.startsWith('/career') ? '/career/internships' : '/internships';
        context.go('$target?q=$encoded');
      }
    }

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onSubmitted: submit,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFFFF782B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: const Color(0xFFFF782B).withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: const Color(0xFFFF782B).withOpacity(0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
