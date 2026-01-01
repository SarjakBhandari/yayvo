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
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.dividerColor,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
      ),
      dropdownColor: theme.dropdownMenuTheme.menuStyle?.backgroundColor
          ?.resolve({}) ??
          theme.colorScheme.surface,
      style: theme.dropdownMenuTheme.textStyle ??
          theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
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