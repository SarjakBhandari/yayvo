import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const MyDropdownButtonFormField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(prefixIcon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
      dropdownColor: const Color.fromARGB(255, 40, 40, 40),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return "Please select $label";
            }
            return null;
          },
    );
  }
}
