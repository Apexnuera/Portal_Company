import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header_clean.dart';
import '../data/application_store.dart';
import '../utils/resume_picker_stub.dart'
    if (dart.library.html) '../utils/resume_picker_web.dart';

class JobApplicationFormPage extends StatefulWidget {
  final String jobId;
  const JobApplicationFormPage({super.key, required this.jobId});

  @override
  State<JobApplicationFormPage> createState() => _JobApplicationFormPageState();
}

class _JobApplicationFormPageState extends State<JobApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _fileName;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final name = await pickResume(context);
    if (name != null && mounted) {
      setState(() => _fileName = name);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume')),
      );
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _submitting = false);

    // Record application for HR dashboard
    final email = _emailController.text.trim();
    final resume = _fileName!;
    final now = DateTime.now();
    if (widget.jobId.startsWith('INT-')) {
      ApplicationStore.I.addInternshipApplication(
        InternshipApplication(
          internshipId: widget.jobId,
          email: email,
          resumeName: resume,
          createdAt: now,
        ),
      );
    } else {
      ApplicationStore.I.addJobApplication(
        JobApplication(
          jobId: widget.jobId,
          email: email,
          resumeName: resume,
          createdAt: now,
        ),
      );
    }

    context.go('/jobs/apply/${widget.jobId}/success');
  }

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
                final cardWidth = isSmall ? constraints.maxWidth - 24 : 520.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 12 : 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: EdgeInsets.all(isSmall ? 18 : 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.assignment_outlined, color: Color(0xFFFF782B)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 12 : 16),

                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email ID',
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your email' : null,
                                ),
                                const SizedBox(height: 12),

                                // Resume upload area
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFFF782B).withOpacity(0.05),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Resume Upload', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: _pickResume,
                                            icon: const Icon(Icons.upload_file),
                                            label: const Text('Choose File'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFFF782B),
                                              side: BorderSide(color: const Color(0xFFFF782B).withOpacity(0.6)),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _fileName ?? 'No file selected (PDF, DOC, DOCX)',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _submitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF782B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    _submitting ? 'Submitting...' : 'Apply',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
