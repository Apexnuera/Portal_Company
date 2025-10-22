import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
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
    final routeName = currentRoute ?? ModalRoute.of(context)?.settings.name ?? '/home';
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              overlayColor: activeColor.withOpacity(0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForLabel(label),
                  color: isActive ? activeColor : baseColor,
                  size: 18,
                ),
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
            Navigator.pushNamed(context, '/jobs');
          } else if (value == 'Internships') {
            Navigator.pushNamed(context, '/internships');
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
                      Navigator.pushNamed(context, '/jobs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
                    title: const Text('Internships'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/internships');
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

  void _handleNavigation(BuildContext context, String label) {
    switch (label) {
      case 'Home':
        Navigator.pushNamed(context, '/home');
        break;
      case 'Campus Commune':
        Navigator.pushNamed(context, '/campus-commune');
        break;
      case 'Help & Support':
        Navigator.pushNamed(context, '/help-support');
        break;
      case 'Login':
        Navigator.pushNamed(context, '/login');
        break;
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
}
