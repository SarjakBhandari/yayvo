import 'package:flutter/material.dart';
import 'package:yayvo/core/utils/show_my_snack_bar.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/core/widgets/my_button.dart';
import 'package:yayvo/core/widgets/my_logo.dart';
import 'package:yayvo/core/widgets/my_text_form_field.dart';

import '../../../../core/widgets/my_dropdown_form_field.dart';
class RetailerRegistrationScreen extends StatefulWidget {
  const RetailerRegistrationScreen({super.key});

  @override
  State<RetailerRegistrationScreen> createState() => _RetailerRegistrationScreenState();
}

class _RetailerRegistrationScreenState extends State<RetailerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _doeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedCountry;
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
    "Japan"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                MyLogo(size: 100, radius: 24),
                const SizedBox(height: 30),
                const Text(
                  "Create Retailer Account",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: _ownerNameController,
                        label: "Owner Name",
                        prefixIcon: Icons.person,
                        onChanged: (val) {},
                        validator: (value) =>
                        value == null || value.isEmpty ? "Owner name is required" : null,
                      ),
                      const SizedBox(height: 15),
                      MyTextFormField(
                        controller: _orgNameController,
                        label: "Organization Name",
                        prefixIcon: Icons.business,
                        onChanged: (val) {},
                        validator: (value) =>
                        value == null || value.isEmpty ? "Organization name is required" : null,
                      ),
                      const SizedBox(height: 15),
                      MyTextFormField(
                        controller: _emailController,
                        label: "Email",
                        prefixIcon: Icons.email,
                        onChanged: (val) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email is required";
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      MyTextFormField(
                        controller: _doeController,
                        label: "Date of Establishment",
                        prefixIcon: Icons.calendar_today,
                        onChanged: (val) {},
                        validator: (value) =>
                        value == null || value.isEmpty ? "Date of establishment is required" : null,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range, color: Colors.black),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2010),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              _doeController.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            }
                          },
                        ),
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
                            _countryController.text = val ?? "";
                          });
                        },
                        validator: (value) =>
                        value == null || value.isEmpty ? "Country is required" : null,
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
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password is required";
                          if (value.length < 6) return "Password must be at least 6 characters";
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
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please confirm your password";
                          if (value != _passwordController.text) return "Passwords do not match";
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
                  child: MyButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showMySnackBar(
                          context: context,
                          message: "Retailer Registration Successful!",
                          status: SnackBarStatus.success,
                        );
                      }
                    },
                    text: "Register",
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
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
    );
  }
}
