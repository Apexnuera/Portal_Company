import 'package:flutter/material.dart';
import 'widgets/app_header_clean.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
                final spacing = 16.0;
                final availableForCards = (maxW - horizontalPadding * 2 - spacing);
                final cardWidth = (availableForCards / 2).clamp(240.0, 420.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 1000,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isSmallScreen ? 12 : 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                              },
                              icon: const Icon(Icons.arrow_back, color: Color(0xFFFF782B)),
                              label: const Text('Back', style: TextStyle(color: Color(0xFFFF782B))),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.login_outlined,
                            color: const Color(0xFFFF782B).withValues(alpha: 0.8),
                          ),
                          Text(
                            'Choose Login Type',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select your role to continue',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 15,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _buildLoginCard(
                                  context: context,
                                  title: 'Employee Login',
                                  subtitle: 'Access your employee portal',
                                  icon: Icons.person_outline,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login/employee');
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildLoginCard(
                                  context: context,
                                  title: 'HR Login',
                                  subtitle: 'Access HR management portal',
                                  icon: Icons.admin_panel_settings_outlined,
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login/hr');
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFFF782B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF782B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 28 : 34,
                  color: const Color(0xFFFF782B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFFFF782B).withValues(alpha: 0.7),
                size: isSmallScreen ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
