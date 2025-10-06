import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
                // Placeholder color while image loads or if image is not found
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          
          // Content
          Column(
            children: [
              // Header Section
              _buildHeader(context),
              
              // Centered Welcome Text
              Expanded(
                child: Center(
                  child: Text(
                    'Welcome to apexnuera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getResponsiveFontSize(context),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isSmallScreen
          ? _buildMobileHeader(context)
          : _buildDesktopHeader(context),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        _buildLogo(),
        
        // Navigation Menu
        _buildNavigationMenu(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        _buildLogo(),
        
        // Hamburger Menu
        IconButton(
          icon: Icon(Icons.menu, size: 30),
          onPressed: () {
            _showMobileMenu(context);
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 50,
      child: Row(
        children: [
          // Placeholder for logo image
          Image.asset(
            'assets/images/logo.png',
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if logo image is not found
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
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
    final menuItems = [
      'Home',
      'Alerts',
      'Campus Commune',
      'Buzz',
      'Help & Support',
      'Career',
      'Login',
    ];

    return Row(
      children: menuItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextButton(
            onPressed: () {
              // Handle navigation
              _handleNavigation(context, item);
            },
            child: Text(
              item,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showMobileMenu(BuildContext context) {
    final menuItems = [
      'Home',
      'Alerts',
      'Campus Commune',
      'Buzz',
      'Help & Support',
      'Career',
      'Login',
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menuItems.map((item) {
              return ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleNavigation(context, item);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, String item) {
    // Handle navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $item'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 32; // Mobile
    } else if (width < 1200) {
      return 48; // Tablet
    } else {
      return 64; // Desktop
    }
  }
}
