import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/app_header_clean.dart';
import 'utils/validators.dart';

class EmployeeRegistrationPage extends StatefulWidget {
  const EmployeeRegistrationPage({super.key});

  @override
  State<EmployeeRegistrationPage> createState() => _EmployeeRegistrationPageState();
}

class _EmployeeRegistrationPageState extends State<EmployeeRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                final cardWidth = isSmall ? constraints.maxWidth - 24 : 480.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 8 : 12),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmall ? 10 : 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add_alt_1_outlined,
                                        color: const Color(0xFFFF782B), size: isSmall ? 24 : 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'New Employee Registration',
                                      style: TextStyle(
                                        fontSize: isSmall ? 18 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFFFF782B)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: (v) => Validators.validateName(v, fieldName: 'Full Name'),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF782B)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: Validators.validateEmail,
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 10,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    labelText: 'Mobile Number (10 digits)',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    prefixIcon: const Icon(Icons.phone_android_outlined, color: Color(0xFFFF782B)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                                    ),
                                  ),
                                  validator: Validators.validateMobileNumber,
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Password (10 chars: Capital, lowercase, numbers, symbols)',
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                                  validator: Validators.validatePassword,
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    prefixIcon: const Icon(Icons.lock_person_outlined, color: Color(0xFFFF782B)),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
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
                                  validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Registering...')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF782B),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login/hr');
                                    },
                                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                                    child: const Text('Already have an account? Login Here'),
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
