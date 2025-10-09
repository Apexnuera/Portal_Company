import 'package:flutter/material.dart';

class HRPostInternshipPage extends StatefulWidget {
  const HRPostInternshipPage({super.key});

  @override
  State<HRPostInternshipPage> createState() => _HRPostInternshipPageState();
}

class _HRPostInternshipPageState extends State<HRPostInternshipPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _skill = TextEditingController();
  final _qualification = TextEditingController();
  final _duration = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _skill.dispose();
    _qualification.dispose();
    _duration.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Internship'),
        backgroundColor: const Color(0xFFFF782B),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField('Title', _title),
                      const SizedBox(height: 12),
                      _buildField('Skill', _skill, hint: 'Primary skill required'),
                      const SizedBox(height: 12),
                      _buildField('Qualification', _qualification, hint: 'e.g., BSc, BTech'),
                      const SizedBox(height: 12),
                      _buildField('Duration', _duration, hint: 'e.g., 3 months'),
                      const SizedBox(height: 12),
                      _buildMultiline('Description', _description),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Internship submitted (placeholder)')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF782B), foregroundColor: Colors.white),
                          child: const Text('Submit Internship', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
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
}
