1→import 'package:flutter/material.dart';
 2→import 'widgets/app_header_clean.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
{{ ... }}
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Header Section (Unified)
              const AppHeader(),
              
              // Centered Welcome Text
              Expanded(
                child: Center(
                  child: Text(
{{ ... }}
            ],
          ),
        ],
      ),
    );
  double _getResponsiveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 32; // Mobile
    } else if (width < 1200) {
      return 48; // Tablet
{{ ... }}
      return 64; // Desktop
    }
  }
}
