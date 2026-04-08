import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guide_model.dart';
import '../providers/app_provider.dart';

class RegisterGuidePage extends StatefulWidget {
  const RegisterGuidePage({super.key});

  @override
  State<RegisterGuidePage> createState() => _RegisterGuidePageState();
}

class _RegisterGuidePageState extends State<RegisterGuidePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _expertiseCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _bioCtrl.dispose();
    _expertiseCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<AppProvider>();
      final user = provider.currentUser!;
      final guide = GuideModel(
        id: provider.service.generateId(),
        userId: user.uid,
        name: user.displayName ?? 'Guide',
        bio: _bioCtrl.text.trim(),
        expertise: _expertiseCtrl.text.trim(),
        hourlyRate: double.parse(_rateCtrl.text.trim()),
        createdAt: DateTime.now(),
      );
      await provider.service.registerAsGuide(guide);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered as a guide!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Guide'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell tourists about yourself',
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expertiseCtrl,
              decoration: const InputDecoration(
                labelText: 'Expertise',
                hintText: 'e.g., Historical sites, Nature trails, Food tours',
                prefixIcon: Icon(Icons.star),
              ),
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: const InputDecoration(
                labelText: 'Hourly Rate (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register as Guide'),
            ),
          ],
        ),
      ),
    );
  }
}
