// consumer_registration_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/utils/show_my_snack_bar.dart';
import 'package:yayvo/core/widgets/my_button.dart';
import 'package:yayvo/core/widgets/my_dropdown_form_field.dart';
import 'package:yayvo/core/widgets/my_logo.dart';
import 'package:yayvo/core/widgets/my_text_form_field.dart';
import 'package:yayvo/features/auth/data/models/auth_api_model.dart';
import 'package:yayvo/features/auth/data/models/user_type.dart';
import 'package:yayvo/features/auth/domain/entities/auth_entity.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/auth/presentation/state/auth_state.dart';
import 'package:yayvo/features/auth/presentation/view_model/auth_viewmodel.dart';

class ConsumerRegistrationScreen extends ConsumerStatefulWidget {
  const ConsumerRegistrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerRegistrationScreen> createState() =>
      _ConsumerRegistrationScreenState();
}

class _ConsumerRegistrationScreenState
    extends ConsumerState<ConsumerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // Keep username controller for auto-generation (no UI field)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> _countries = [
    "Nepal",
    "India",
    "China",
    "United States",
    "United Kingdom",
    "Australia",
    "Canada",
    "Germany",
    "France",
    "Japan",
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _gender = "Male";
  String? _selectedCountry;

  final RegExp _emailRegex = RegExp(
    r"^(?!\.)(?!.*\.\.)[A-Za-z0-9_+'\-\.\*]+@[A-Za-z0-9][A-Za-z0-9\-]*(\.[A-Za-z]{2,})+$",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _generateUsernameIfEmpty() {
    if (_usernameController.text.trim().isEmpty) {
      final email = _emailController.text.trim();
      final emailFirstPart = email.isNotEmpty && email.contains('@')
          ? email.split('@').first
          : 'user';
      final randomNumber = Random().nextInt(9000) + 1000;
      _usernameController.text = "$emailFirstPart$randomNumber";
      _usernameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _usernameController.text.length),
      );
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final first = DateTime(1900);
    final last = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      // Format as YYYY-MM-DD
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _dobController.text = '$y-$m-$d';
      _dobController.selection = TextSelection.fromPosition(
        TextPosition(offset: _dobController.text.length),
      );
      setState(() {});
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_emailRegex.hasMatch(email)) {
      showMySnackBar(
        context: context,
        message: "Enter a valid email address",
        status: SnackBarStatus.error,
      );
      return;
    }

    if (password.length < 8) {
      showMySnackBar(
        context: context,
        message: "Password must be at least 8 characters",
        status: SnackBarStatus.error,
      );
      return;
    }

    _generateUsernameIfEmpty();

    final authEntity = AuthEntity(
      authId: null,
      role: UserType.consumer,
      email: email,
      passwordHash: password,
      consumer: null,
      retailer: null,
    );

    final consumerEntity = ConsumerEntity(
      authId: null,
      username: _usernameController.text.trim(),
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _gender.toLowerCase(),
      country: _selectedCountry ?? "",
      profilePicture: null,
    );

    // Debug (masked)
    final apiModel = AuthApiModel.fromEntity(authEntity, consumerEntity);
    final masked = Map<String, dynamic>.from(apiModel.toJson());
    if (masked.containsKey('password')) masked['password'] = '***';
    // ignore: avoid_print
    print('REGISTER PAYLOAD -> $masked');

    ref
        .read(authViewModelProvider.notifier)
        .register(authEntity, consumerEntity);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        showMySnackBar(
          context: context,
          message: next.errorMessage!,
          status: SnackBarStatus.error,
        );
      } else if (next.status == AuthStatus.registered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    final textColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery(
        // Remove viewInsets so keyboard animation frames don't propagate
        // MediaQuery changes into the widget tree, preventing per-frame rebuilds.
        data: MediaQuery.of(context).removeViewInsets(removeBottom: true),
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
              child: Column(
                children: [
                  MyLogo(size: 100, radius: 24),
                  const SizedBox(height: 30),
                  const Text(
                    "Create Consumer Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        MyTextFormField(
                          controller: _nameController,
                          label: "Full name",
                          prefixIcon: Icons.person,
                          onChanged: (val) {},
                          validator: (value) => value == null || value.isEmpty
                              ? "Please enter your name"
                              : null,
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          controller: _emailController,
                          label: "Email",
                          prefixIcon: Icons.email,
                          onChanged: (val) {},
                          validator: (value) {
                            final v = (value ?? "").trim();
                            if (v.isEmpty) return "Please enter your email";
                            if (!_emailRegex.hasMatch(v))
                              return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Date of birth field uses date picker
                        GestureDetector(
                          onTap: _pickDob,
                          child: AbsorbPointer(
                            child: MyTextFormField(
                              controller: _dobController,
                              label: "Date of Birth",
                              prefixIcon: Icons.calendar_today,
                              onChanged: (val) {},
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "Please select your DOB"
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Username field removed from UI (auto-generated)
                        // Phone field
                        MyTextFormField(
                          controller: _phoneController,
                          label: "Phone",
                          prefixIcon: Icons.phone,
                          onChanged: (val) {},
                          validator: (value) => value == null || value.isEmpty
                              ? "Please enter phone"
                              : null,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text("Gender:", style: TextStyle(color: textColor)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: "Male",
                                    groupValue: _gender,
                                    onChanged: (value) =>
                                        setState(() => _gender = value!),
                                  ),
                                  Text(
                                    "Male",
                                    style: TextStyle(color: textColor),
                                  ),
                                  Radio<String>(
                                    value: "Female",
                                    groupValue: _gender,
                                    onChanged: (value) =>
                                        setState(() => _gender = value!),
                                  ),
                                  Text(
                                    "Female",
                                    style: TextStyle(color: textColor),
                                  ),
                                  Radio<String>(
                                    value: "Other",
                                    groupValue: _gender,
                                    onChanged: (value) =>
                                        setState(() => _gender = value!),
                                  ),
                                  Text(
                                    "Other",
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        MyDropdownButtonFormField(
                          label: "Country",
                          prefixIcon: Icons.location_pin,
                          items: _countries,
                          value: _selectedCountry,
                          onChanged: (val) {
                            setState(() {
                              _selectedCountry = val;
                              _addressController.text = val ?? "";
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Please select your country"
                              : null,
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          controller: _passwordController,
                          label: "Password",
                          prefixIcon: Icons.key,
                          obscureText: _obscurePassword,
                          onChanged: (val) {},
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textColor,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Please enter a password";
                            if (value.length < 8)
                              return "Password must be at least 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          prefixIcon: Icons.key,
                          obscureText: _obscureConfirmPassword,
                          onChanged: (val) {},
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textColor,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Please confirm your password";
                            if (value != _passwordController.text)
                              return "Passwords do not match";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    height: 45,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final isLoading =
                            ref.watch(authViewModelProvider).status ==
                            AuthStatus.loading;
                        return MyButton(
                          onPressed: _onSubmit,
                          text: isLoading ? "Registering..." : "Register",
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Already registered? ",
                        style: TextStyle(color: textColor, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
