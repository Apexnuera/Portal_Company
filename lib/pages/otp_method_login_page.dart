import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header_clean.dart';

class OTPMethodLoginPage extends StatefulWidget {
  const OTPMethodLoginPage({super.key});

  @override
  State<OTPMethodLoginPage> createState() => _OTPMethodLoginPageState();
}

class _OTPMethodLoginPageState extends State<OTPMethodLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _otpSent = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.sms_outlined, color: Color(0xFFFF782B)),
                              SizedBox(width: 8),
                              Text(
                                'OTP Login',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (!_otpSent) ...[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter your email address'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('OTP sent to email (demo)')),
                                    );
                                    setState(() {
                                      _otpSent = true;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF782B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Get OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ] else ...[
                            // OTP Field
                            TextFormField(
                              controller: _otpController,
                              decoration: InputDecoration(
                                labelText: 'Enter OTP',
                                prefixIcon: const Icon(Icons.pin_outlined, color: Color(0xFFFF782B)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter the OTP' : null,
                            ),
                            const SizedBox(height: 12),

                            // New Password
                            TextFormField(
                              controller: _newPwdController,
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
                              controller: _confirmPwdController,
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
                                if (v != _newPwdController.text) return 'Passwords do not match';
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
                                      const SnackBar(content: Text('Password reset successful (demo)')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF782B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
