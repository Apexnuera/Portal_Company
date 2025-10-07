1→ import 'package:flutter/material.dart';
import 'widgets/app_header_clean.dart';

class HRLoginPage extends StatefulWidget {
  const HRLoginPage({super.key});

  @override
{{ ... }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                final cardWidth = isSmall ? constraints.maxWidth - 24 : 420.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 12 : 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmall ? 18 : 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Back Button
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back, color: Color(0xFFFF782B)),
                                    label: const Text('Back', style: TextStyle(color: Color(0xFFFF782B))),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.admin_panel_settings_outlined,
                                      color: const Color(0xFFFF782B), size: isSmall ? 28 : 32),
                                    const SizedBox(width: 8),
                                    Text(
                                      'HR Login',
{{ ... }}
                              onPressed: () {
                                Navigator.pushNamed(context, '/change-password');
                              },
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                              child: const Text('Forgot Password?'),
            ),
          ),
        ],
      ),
    );
  }
}
