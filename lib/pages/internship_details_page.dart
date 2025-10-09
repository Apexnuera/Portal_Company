import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header_clean.dart';
import '../data/post_store.dart';

class InternshipDetailsPage extends StatelessWidget {
  final String internshipId;
  const InternshipDetailsPage({super.key, required this.internshipId});

  @override
  Widget build(BuildContext context) {
    final data = PostStore.I.getInternshipById(internshipId);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 900;
                final maxWidth = isSmall ? 760.0 : 1000.0;
                if (data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text('Internship not found: $internshipId', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/internships'),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                            child: const Text('Back to Internships'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

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
                              Text(
                                data.title,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),

                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _chip(Icons.calendar_today_outlined, 'Posted: ${data.postingDate}'),
                              ),
                              const SizedBox(height: 16),

                              _labelValue('Skill', data.skill),
                              const SizedBox(height: 10),
                              _labelValue('Qualification', data.qualification),
                              const SizedBox(height: 10),
                              _labelValue('Duration', data.duration),
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

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF782B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF782B).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF782B)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
