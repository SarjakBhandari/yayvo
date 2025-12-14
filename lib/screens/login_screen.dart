import 'package:flutter/material.dart';
import 'package:yayvo/common/show_my_snack_bar.dart';
import 'package:yayvo/screens/onboarding/interests_onboarding_screen.dart';
import 'package:yayvo/widgets/my_button.dart';
import 'package:yayvo/widgets/my_logo.dart';
import 'package:yayvo/widgets/my_text_form_field.dart';

import 'onboarding/welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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

                const SizedBox(height: 40),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Please login with your credentials",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: _emailController,
                        label: "Email",
                        prefixIcon: Icons.email,
                        onChanged: (val) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
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
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showMySnackBar(
                      context: context,
                      message: "Forgot Password tapped",
                      status: SnackBarStatus.warning,
                    );
                  },
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
                          message: "Logged In!",
                          status: SnackBarStatus.success,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InterestsScreen(),
                          ),
                        );
                      }
                    },
                    text: "Sign In",
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an Account? ",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Sign Up",
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
