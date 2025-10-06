import 'package:flutter/material.dart';
import 'app_header.dart';

class BuzzPage extends StatelessWidget {
  const BuzzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: _getResponsiveIconSize(context),
                      color: const Color(0xFFFF782B).withOpacity(0.7),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The Buzz feature is under development',
                      style: TextStyle(
                        fontSize: _getResponsiveSubtitleSize(context),
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 32; // Mobile
    } else if (width < 1200) {
      return 42; // Tablet
    } else {
      return 56; // Desktop
    }
  }

  double _getResponsiveSubtitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 14; // Mobile
    } else if (width < 1200) {
      return 16; // Tablet
    } else {
      return 18; // Desktop
    }
  }

  double _getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 64; // Mobile
    } else if (width < 1200) {
      return 80; // Tablet
    } else {
      return 96; // Desktop
    }
  }
}
