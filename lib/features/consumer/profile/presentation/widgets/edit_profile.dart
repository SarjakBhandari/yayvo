import 'package:flutter/material.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

class EditProfileSection extends StatefulWidget {
  final ConsumerEntity user;
  final Future<void> Function(ConsumerEntity updated) onSave;

  const EditProfileSection({Key? key, required this.user, required this.onSave}) : super(key: key);

  @override
  State<EditProfileSection> createState() => _EditProfileSectionState();
}

class _EditProfileSectionState extends State<EditProfileSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _usernameCtrl = TextEditingController(text: widget.user.username);
  }

  @override
  void didUpdateWidget(covariant EditProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.fullName != widget.user.fullName) _nameCtrl.text = widget.user.fullName;
    if (oldWidget.user.username != widget.user.username) _usernameCtrl.text = widget.user.username;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.user.copyWith(fullName: _nameCtrl.text.trim(), username: _usernameCtrl.text.trim());
    await widget.onSave(updated);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text('Change details', style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(height: 8),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _usernameCtrl, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  child: _saving ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}