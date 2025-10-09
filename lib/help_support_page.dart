import 'package:flutter/material.dart';
import 'widgets/app_header_clean.dart';
import 'data/support_store.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Store in shared SupportStore so HR dashboard reflects immediately
      SupportStore.I.addQuery(
        SupportQuery(
          email: _emailController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      // Feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form
      _emailController.clear();
      _descriptionController.clear();
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Compact mode if height is limited
          final compact = constraints.maxHeight < 620;
          final cardMaxWidth = 640.0; // keep the form card at original width on wide screens
          final containerMaxWidth = isSmallScreen ? constraints.maxWidth - 24 : 980.0; // allow room for right sidebar

          // Contact info section (outside the main form content)
          final infoSection = Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF782B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.6), width: 1.2),
            ),
            padding: EdgeInsets.all(compact ? 12 : (isSmallScreen ? 14 : 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFFF782B).withOpacity(0.9),
                  size: compact ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For any queries or immediate help, please contact us: mail us to: hr@apexnuera.com',
                    style: TextStyle(
                      fontSize: compact ? 12.5 : (isSmallScreen ? 13 : 14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF782B),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );

          // Original simple centered form card
          final formCard = Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 16.0 : (isSmallScreen ? 18.0 : 24.0)),
              child: _submitted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: compact ? 56 : (isSmallScreen ? 64 : 72),
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your Query Submitted Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Our team will review your request and get back to you soon.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _submitted = false),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Submit another query'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF782B),
                            side: const BorderSide(color: Color(0xFFFF782B)),
                          ),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Icon and Title
                          Icon(
                            Icons.support_agent_outlined,
                            size: compact ? 44 : (isSmallScreen ? 48 : 56),
                            color: const Color(0xFFFF782B).withOpacity(0.8),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'How can we help you?',
                            style: TextStyle(
                              fontSize: compact ? 20 : (isSmallScreen ? 22 : 24),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fill out the form below and we\'ll get back to you soon',
                            style: TextStyle(
                              fontSize: compact ? 13 : (isSmallScreen ? 14 : 15),
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email ID',
                              hintText: 'Enter your email address',
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: compact ? 4 : (isSmallScreen ? 5 : 6),
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Describe your issue or question...',
                              prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFF782B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                              ),
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              if (value.length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Submit Button
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF782B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );

          return Column(
            children: [
              const AppHeader(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: containerMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                      child: isSmallScreen
                          // Stack vertically on small screens: centered form then right-aligned info
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 640),
                                    child: formCard,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 320),
                                    child: infoSection,
                                  ),
                                ),
                              ],
                            )
                          // Place form centered-left and info on the right on wider screens
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 640),
                                      child: formCard,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 300),
                                  child: infoSection,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
