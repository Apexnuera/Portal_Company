import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/app_header_clean.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'state/app_session.dart';
import 'utils/validators.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.badge_outlined,
                                  color: const Color(0xFFFF782B), size: isSmall ? 28 : 32),
                              const SizedBox(width: 8),
                              Text(
                                'Employee Login',
                                style: TextStyle(
                                  fontSize: isSmall ? 20 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF782B)),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFFF782B),
                                ),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Simulate login process
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Logging in...')),
                                  );
                                  
                                  // Set employee as logged in and navigate to employee dashboard
                                  AuthService.instance.setEmployeeLoggedIn(true);

                                  final appSession = context.read<AppSession>();
                                  appSession.signIn(_emailController.text.trim());

                                  context.go('/employee/dashboard');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF782B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/change-password'),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          // Registration link removed as requested
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
