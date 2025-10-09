import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/post_store.dart';
import '../data/support_store.dart';
import '../data/application_store.dart';

enum _HRMenu { overview, queries, postJob, postInternship }

class _JobsModule extends StatelessWidget {
  const _JobsModule();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                labelColor: Color(0xFFFF782B),
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'Applications'),
                  Tab(text: 'Post New Job'),
                ],
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                double h = MediaQuery.of(context).size.height - 220;
                if (h < 320) h = 320;
                if (h > 900) h = 900;
                return SizedBox(
                height: h,
                child: TabBarView(
                  children: [
                    _JobApplicationsList(),
                    const _PostJobFormInline(),
                  ],
                ),
              );}),
            ],
          ),
        ),
      ),
    );
  }
}

class _InternshipsModule extends StatelessWidget {
  const _InternshipsModule();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                labelColor: Color(0xFFFF782B),
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'Applications'),
                  Tab(text: 'Post New Intern'),
                ],
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                double h = MediaQuery.of(context).size.height - 220;
                if (h < 320) h = 320;
                if (h > 900) h = 900;
                return SizedBox(
                height: h,
                child: TabBarView(
                  children: [
                    _InternshipApplicationsList(),
                    const _PostInternshipFormInline(),
                  ],
                ),
              );}),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobApplicationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ApplicationStore.I,
      builder: (context, _) {
        final items = ApplicationStore.I.jobApplications;
        if (items.isEmpty) {
          return const Center(child: Text('No job applications yet.'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final a = items[i];
            return ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFFFF782B)),
              title: Text(a.email),
              subtitle: Text('Resume: ${a.resumeName} • ${a.createdAt.year.toString().padLeft(4,'0')}-${a.createdAt.month.toString().padLeft(2,'0')}-${a.createdAt.day.toString().padLeft(2,'0')}'),
              trailing: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading resume... (placeholder)')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
            );
          },
        );
      },
    );
  }
}

class _InternshipApplicationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ApplicationStore.I,
      builder: (context, _) {
        final items = ApplicationStore.I.internshipApplications;
        if (items.isEmpty) {
          return const Center(child: Text('No internship applications yet.'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final a = items[i];
            return ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFFFF782B)),
              title: Text(a.email),
              subtitle: Text('Resume: ${a.resumeName} • ${a.createdAt.year.toString().padLeft(4,'0')}-${a.createdAt.month.toString().padLeft(2,'0')}-${a.createdAt.day.toString().padLeft(2,'0')}'),
              trailing: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading resume... (placeholder)')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
            );
          },
        );
      },
    );
  }
}

class HRDashboardPage extends StatefulWidget {
  const HRDashboardPage({super.key});

  @override
  State<HRDashboardPage> createState() => _HRDashboardPageState();
}

class _HRDashboardPageState extends State<HRDashboardPage> {
  _HRMenu _selected = _HRMenu.overview; // initial: overview/welcome

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Dashboard'),
        backgroundColor: const Color(0xFFFF782B),
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              children: [
                _Sidebar(
                  selected: _selected,
                  onSelect: (m) => setState(() => _selected = m),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _RightPanel(selected: _selected)),
              ],
            );
          }
          return Column(
            children: [
              _TopNav(
                selected: _selected,
                onSelect: (m) => setState(() => _selected = m),
              ),
              const Divider(height: 1),
              Expanded(child: _RightPanel(selected: _selected)),
            ],
          );
        },
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final _HRMenu selected;
  final ValueChanged<_HRMenu> onSelect;
  const _Sidebar({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Color(0xFFFF782B)),
            title: const Text('Overview'),
            selected: selected == _HRMenu.overview,
            onTap: () => onSelect(_HRMenu.overview),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFFFF782B)),
            title: const Text('Help and Support'),
            selected: selected == _HRMenu.queries,
            onTap: () => onSelect(_HRMenu.queries),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
            title: const Text('Jobs'),
            selected: selected == _HRMenu.postJob,
            onTap: () => onSelect(_HRMenu.postJob),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
            title: const Text('Internships'),
            selected: selected == _HRMenu.postInternship,
            onTap: () => onSelect(_HRMenu.postInternship),
          ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final _HRMenu selected;
  final ValueChanged<_HRMenu> onSelect;
  const _TopNav({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 56,
      color: Colors.grey.shade50,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.overview),
            icon: const Icon(Icons.dashboard_outlined, color: Color(0xFFFF782B)),
            label: const Text('Overview'),
          ),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.queries),
            icon: const Icon(Icons.help_outline, color: Color(0xFFFF782B)),
            label: const Text('Help and Support'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.postJob),
            icon: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
            label: const Text('Jobs'),
          ),
          TextButton.icon(
            onPressed: () => onSelect(_HRMenu.postInternship),
            icon: const Icon(Icons.school_outlined, color: Color(0xFFFF782B)),
            label: const Text('Internships'),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  final _HRMenu selected;
  const _RightPanel({required this.selected});
  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (selected) {
      case _HRMenu.overview:
        child = _WelcomePanel();
        break;
      case _HRMenu.queries:
        child = const _QueriesList();
        break;
      case _HRMenu.postJob:
        child = const _JobsModule();
        break;
      case _HRMenu.postInternship:
        child = const _InternshipsModule();
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    );
  }
}
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFFF782B)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Welcome to the HR Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Select an option from the left to get started.'),
          ],
        ),
      ),
    );
  }
}

class _QueriesList extends StatelessWidget {
  const _QueriesList();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SupportStore.I,
      builder: (context, _) {
        final items = SupportStore.I.items;
        return _InfoCard(
          icon: Icons.help_outline,
          title: 'Help and Support',
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No submissions yet.'),
                )
              : Column(
                  children: [
                    for (final q in items)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                        title: Text(q.email),
                        subtitle: Text(q.description),
                        trailing: Text(
                          '${q.createdAt.year.toString().padLeft(4,'0')}-${q.createdAt.month.toString().padLeft(2,'0')}-${q.createdAt.day.toString().padLeft(2,'0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _PostJobFormInline extends StatefulWidget {
  const _PostJobFormInline();
  @override
  State<_PostJobFormInline> createState() => _PostJobFormInlineState();
}

class _PostJobFormInlineState extends State<_PostJobFormInline> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _responsibilities = TextEditingController();
  final _qualifications = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _department = TextEditingController();
  final _postingDate = TextEditingController();
  final _applicationDeadline = TextEditingController();
  final _jobId = TextEditingController();
  String _contractType = 'Full-Time';

  @override
  void dispose() {
    _title.dispose();
    _experience.dispose();
    _skills.dispose();
    _responsibilities.dispose();
    _qualifications.dispose();
    _description.dispose();
    _location.dispose();
    _department.dispose();
    _postingDate.dispose();
    _applicationDeadline.dispose();
    _jobId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize defaults when first built
    if (_postingDate.text.isEmpty) {
      final now = DateTime.now();
      _postingDate.text = '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    }
    if (_jobId.text.isEmpty) {
      _jobId.text = 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }

    return SizedBox(
      width: 820,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Text('Post New Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildField('Title', _title),
                const SizedBox(height: 12),
                _buildField('Experience', _experience, hint: 'e.g., 3-5 years'),
                const SizedBox(height: 12),
                _buildField('Skills', _skills, hint: 'Comma-separated skills'),
                const SizedBox(height: 12),
                _buildMultiline('Responsibilities', _responsibilities),
                const SizedBox(height: 12),
                _buildMultiline('Qualifications', _qualifications),
                const SizedBox(height: 12),
                _buildMultiline('Description', _description),
                const SizedBox(height: 16),
                _buildField('Location', _location, hint: 'City, Country'),
                const SizedBox(height: 12),
                _dropdownContractType(),
                const SizedBox(height: 12),
                _buildField('Department', _department),
                const SizedBox(height: 12),
                _dateRow(),
                const SizedBox(height: 12),
                _buildField('Job ID', _jobId, hint: 'Auto-filled, you can edit'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final job = JobPost(
                          id: _jobId.text.trim(),
                          title: _title.text.trim(),
                          description: _description.text.trim(),
                          location: _location.text.trim(),
                          contractType: _contractType,
                          department: _department.text.trim(),
                          postingDate: _postingDate.text.trim(),
                          applicationDeadline: _applicationDeadline.text.trim(),
                          experience: _experience.text.trim(),
                          skills: _splitList(_skills.text),
                          responsibilities: _splitLines(_responsibilities.text),
                          qualifications: _splitLines(_qualifications.text),
                        );
                        PostStore.I.addJob(job);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job posted successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                    child: const Text('Submit Job', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Manage Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: PostStore.I,
                  builder: (context, _) {
                    final items = PostStore.I.jobs;
                    if (items.isEmpty) {
                      return const Text('No active job posts yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final j = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(j.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${j.id} • ${j.postingDate}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final ok = PostStore.I.deleteJob(j.id);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Job deleted')),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildMultiline(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _dropdownContractType() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Contract Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _contractType,
          items: const [
            DropdownMenuItem(value: 'Full-Time', child: Text('Full-Time')),
            DropdownMenuItem(value: 'Part-Time', child: Text('Part-Time')),
            DropdownMenuItem(value: 'Contract', child: Text('Contract')),
            DropdownMenuItem(value: 'Temporary', child: Text('Temporary')),
            DropdownMenuItem(value: 'Intern', child: Text('Intern')),
          ],
          onChanged: (v) => setState(() => _contractType = v ?? 'Full-Time'),
        ),
      ),
    );
  }

  Widget _dateRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField('Posting Date', _postingDate, allowPast: true),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField('Application Deadline', _applicationDeadline),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool allowPast = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final firstDate = allowPast ? DateTime(now.year - 5) : now;
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: DateTime(now.year + 5),
          initialDate: now,
        );
        if (picked != null) {
          final s = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
          setState(() => controller.text = s);
        }
      },
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null,
    );
  }

  List<String> _splitList(String input) {
    return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  List<String> _splitLines(String input) {
    return input.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}

class _PostInternshipFormInline extends StatefulWidget {
  const _PostInternshipFormInline();
  @override
  State<_PostInternshipFormInline> createState() => _PostInternshipFormInlineState();
}

class _PostInternshipFormInlineState extends State<_PostInternshipFormInline> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _skill = TextEditingController();
  final _qualification = TextEditingController();
  final _duration = TextEditingController();
  final _description = TextEditingController();
  final _postingDate = TextEditingController();
  // Removed: Location, Contract Type, Internship ID as per requirements

  @override
  void dispose() {
    _title.dispose();
    _skill.dispose();
    _qualification.dispose();
    _duration.dispose();
    _description.dispose();
    _postingDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize defaults
    if (_postingDate.text.isEmpty) {
      final now = DateTime.now();
      _postingDate.text = '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    }

    return SizedBox(
      width: 820,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const Text('Post New Internship', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildField('Title', _title),
                const SizedBox(height: 12),
                _buildField('Skill', _skill, hint: 'Primary skill required'),
                const SizedBox(height: 12),
                _buildField('Qualification', _qualification, hint: 'e.g., BSc, BTech'),
                const SizedBox(height: 12),
                _buildField('Duration', _duration, hint: 'e.g., 3 months'),
                const SizedBox(height: 12),
                _buildMultiline('Description', _description),
                const SizedBox(height: 12),
                _buildDateField('Posting Date', _postingDate, allowPast: true),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final genId = 'INT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        final post = InternshipPost(
                          id: genId,
                          title: _title.text.trim(),
                          skill: _skill.text.trim(),
                          qualification: _qualification.text.trim(),
                          duration: _duration.text.trim(),
                          description: _description.text.trim(),
                          location: '',
                          contractType: '',
                          postingDate: _postingDate.text.trim(),
                        );
                        PostStore.I.addInternship(post);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Internship posted successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                    child: const Text('Submit Internship', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Manage Internships', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: PostStore.I,
                  builder: (context, _) {
                    final items = PostStore.I.internships;
                    if (items.isEmpty) {
                      return const Text('No active internship posts yet.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final it = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${it.id} • ${it.postingDate}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final ok = PostStore.I.deleteInternship(it.id);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Internship deleted')),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildMultiline(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool allowPast = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.date_range_outlined, color: Color(0xFFFF782B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF782B), width: 2),
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final firstDate = allowPast ? DateTime(now.year - 5) : now;
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: DateTime(now.year + 5),
          initialDate: now,
        );
        if (picked != null) {
          final s = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
          setState(() => controller.text = s);
        }
      },
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null,
    );
  }
}
