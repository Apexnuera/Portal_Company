import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header_clean.dart';

class InternshipDetailsPage extends StatelessWidget {
  final String internshipId;
  const InternshipDetailsPage({super.key, required this.internshipId});

  @override
  Widget build(BuildContext context) {
    final data = _internshipById(internshipId);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 800;
                final maxWidth = isSmall ? 700.0 : 900.0;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title row with small id chip
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF782B).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.25)),
                                    ),
                                    child: Text(
                                      data.id,
                                      style: const TextStyle(color: Color(0xFFFF782B), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Simple details blocks
                              _labelValue('Skill', data.skill),
                              const SizedBox(height: 10),
                              _labelValue('Qualification', data.qualification),
                              const SizedBox(height: 10),
                              _labelValue('Description', data.description),

                              const SizedBox(height: 20),

                              SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: () => context.push('/jobs/apply/${data.id}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF782B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
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

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  _Internship _internshipById(String id) {
    final idx = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _Internship(
      id: id,
      title: 'Software Intern ${idx % 50 + 1}',
      skill: 'Flutter, Dart, Git',
      qualification: 'Pursuing CS/IT or related field',
      description: 'A short internship focused on building Flutter features and learning modern development practices.',
    );
  }
}

class _Internship {
  final String id;
  final String title;
  final String skill;
  final String qualification;
  final String description;

  const _Internship({
    required this.id,
    required this.title,
    required this.skill,
    required this.qualification,
    required this.description,
  });
}
