import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String label;
  final IconData prefixIcon;
  final bool? obscureText; // ✅ nullable, defaults to false
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const MyTextFormField({
    super.key,
    required this.onChanged,
    required this.label,
    required this.prefixIcon,
    this.obscureText,
    this.validator,
    this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(prefixIcon, color: Colors.black),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
      onChanged: onChanged,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return "Please enter $label";
            }
            return null;
          },
    );
  }
}
