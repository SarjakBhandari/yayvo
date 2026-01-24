import 'package:flutter/material.dart';

class PasswordChangeResult {
  final String current;
  final String next;
  const PasswordChangeResult(this.current, this.next);
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(PasswordChangeResult(_currentCtrl.text.trim(), _newCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current password',
                suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Enter current password' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New password',
                suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Change')),
      ],
    );
  }
}
