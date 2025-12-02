import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String text;

  const MyTextFormField(
      {
        super.key,
        required this.onChanged,
        required this.text
      }
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(
            hintText: text,
            border: const OutlineInputBorder()
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value!.isEmpty) { return "Please Write Something";}
          return null;
        }

    );
  }
}
