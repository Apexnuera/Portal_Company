import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header_clean.dart';
import '../data/post_store.dart';

class JobDetailsPage extends StatelessWidget {
  final String jobId;
  const JobDetailsPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final job = PostStore.I.getJobById(jobId);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1000;
                final horizontal = isWide ? 32.0 : 16.0;
                if (job == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text('Job not found: $jobId', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/jobs'),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                            child: const Text('Back to Jobs'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar with title and small report button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => debugPrint('Report job ${job.id}') ,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: const Text('Report'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Meta: experience, location, type
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _chip(icon: Icons.work_outline, label: job.experience),
                        _chip(icon: Icons.place_outlined, label: job.location),
                        _chip(icon: Icons.badge_outlined, label: job.contractType),
                        _chip(icon: Icons.calendar_today_outlined, label: 'Posted: ${job.postingDate}'),
                        _chip(icon: Icons.hourglass_bottom_outlined, label: 'Apply by: ${job.applicationDeadline}'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Job Description'),
                            Text(job.description, style: const TextStyle(color: Colors.black87, height: 1.4)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Experience + Skills + Qualifications + Responsibilities
                    if (!isWide)
                      ...[
                        _infoCard('Experience', Text(job.experience)),
                        const SizedBox(height: 12),
                        _infoCard('Skills', _bullets(job.skills)),
                        const SizedBox(height: 12),
                        _infoCard('Qualifications', _bullets(job.qualifications)),
                        const SizedBox(height: 12),
                        _infoCard('Responsibilities', _bullets(job.responsibilities)),
                      ]
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _infoCard('Experience', Text(job.experience))),
                          const SizedBox(width: 12),
                          Expanded(child: _infoCard('Skills', _bullets(job.skills))),
                          const SizedBox(width: 12),
                          Expanded(child: _infoCard('Qualifications', _bullets(job.qualifications))),
                        ],
                      ),
                    if (isWide) ...[
                      const SizedBox(height: 12),
                      _infoCard('Responsibilities', _bullets(job.responsibilities)),
                    ],

                    const SizedBox(height: 24),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => context.push('/jobs/apply/${job.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF782B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: main content
                                Expanded(
                                  flex: 3,
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: content,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right: quick facts panel
                                Expanded(
                                  flex: 1,
                                  child: _factsPanel(job),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: content,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _factsPanel(job),
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

  // Quick facts side panel
  Widget _factsPanel(JobPost job) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Role Overview'),
            const SizedBox(height: 8),
            _factRow(Icons.business_outlined, 'Department', job.department),
            const SizedBox(height: 8),
            _factRow(Icons.public_outlined, 'Location', job.location),
            const SizedBox(height: 8),
            _factRow(Icons.badge_outlined, 'Contract Type', job.contractType),
            const SizedBox(height: 8),
            _factRow(Icons.calendar_today_outlined, 'Posting Date', job.postingDate),
            const SizedBox(height: 8),
            _factRow(Icons.hourglass_bottom_outlined, 'Application Deadline', job.applicationDeadline),
            const Divider(height: 24),
            _sectionTitle('Job ID'),
            Text(job.id, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF782B)),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // Small pill-like chip with icon and label
  Widget _chip({required IconData icon, required String label}) {
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
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(title),
            child,
          ],
        ),
      ),
    );
  }

  Widget _bullets(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('\u2022 ', style: TextStyle(fontSize: 16, height: 1.4)),
                Expanded(child: Text(s, style: const TextStyle(height: 1.4))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
      ),
    );
  }

}
