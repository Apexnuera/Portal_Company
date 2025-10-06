import 'package:flutter/material.dart';
import 'app_header.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
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
                final compact = constraints.maxHeight < 620;
                final cardWidth = isSmall ? constraints.maxWidth - 24 : 480.0;
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
                          padding: EdgeInsets.all(compact ? 16 : (isSmall ? 20 : 24)),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_reset_outlined,
                                        color: const Color(0xFFFF782B), size: isSmall ? 28 : 32),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: isSmall ? 20 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Old Password
                                TextFormField(
                                  controller: _oldController,
                                  obscureText: _obscureOld,
                                  decoration: InputDecoration(
                                    labelText: 'Old Password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF782B)),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscureOld = !_obscureOld),
                                      icon: Icon(
                                        _obscureOld ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: const Color(0xFFFF782B),
                                      ),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter old password' : null,
                                ),
                                const SizedBox(height: 12),
                                // New Password
                                TextFormField(
                                  controller: _newController,
                                  obscureText: _obscureNew,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF782B)),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                                      icon: Icon(
                                        _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: const Color(0xFFFF782B),
                                      ),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter new password' : null,
                                ),
                                const SizedBox(height: 12),
                                // Confirm New Password
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF782B)),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                      icon: Icon(
                                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: const Color(0xFFFF782B),
                                      ),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please confirm new password';
                                    if (v != _newController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Password changed (demo)')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF782B),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
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
