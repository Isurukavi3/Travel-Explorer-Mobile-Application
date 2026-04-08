import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../providers/app_provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel? profile;
  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late List<String> _selectedInterests;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  bool _loading = false;
  File? _profileImage;

  static const _accent = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF8F9FF);
  static const _dark = Color(0xFF1C1C2E);
  static const _mid = Color(0xFF6B7280);

  static const _interests = [
    'Beach',
    'Mountain',
    'Hiking',
    'Food',
    'Culture',
    'History',
    'Shopping',
    'Nightlife',
    'Nature',
    'Adventure',
    'Photography',
    'Art',
  ];

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(widget.profile?.interests ?? []);
    _phoneCtrl.text = widget.profile?.phone ?? '';
    _emailCtrl.text = widget.profile?.email ?? '';
    _websiteCtrl.text = widget.profile?.website ?? '';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    // Capture before async gap
    final provider = context.read<AppProvider>();
    final user = provider.currentUser!;
    try {
      // Preserve existing image URL if no new image picked
      String? imageUrl = widget.profile?.profileImageUrl;
      if (_profileImage != null) {
        try {
          final urls = await provider.service.uploadImages([_profileImage!]);
          if (urls.isNotEmpty) imageUrl = urls.first;
        } catch (_) {}
      }
      final profile = UserProfileModel(
        userId: user.uid,
        name: user.displayName ?? 'User',
        profileImageUrl: imageUrl,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
        interests: _selectedInterests,
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
      );
      await provider.service.saveUserProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _mid, fontSize: 13),
    prefixIcon: Icon(icon, color: _accent, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _accent, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppProvider>().currentUser;
    final name = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _dark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Avatar picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: _accent.withValues(alpha: 0.15),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'W',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: _accent,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_accent, Color(0xFF66BB6A)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap to change photo',
              style: TextStyle(fontSize: 12, color: _mid),
            ),
          ),
          const SizedBox(height: 28),

          // Contact info
          _Label('CONTACT INFORMATION'),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            style: const TextStyle(fontSize: 14, color: _dark),
            decoration: _dec('Phone Number', Icons.phone_outlined),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            style: const TextStyle(fontSize: 14, color: _dark),
            decoration: _dec('Email', Icons.mail_outline_rounded),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _websiteCtrl,
            style: const TextStyle(fontSize: 14, color: _dark),
            decoration: _dec('Website / Social', Icons.link_rounded),
          ),
          const SizedBox(height: 28),

          // Interests
          _Label('TRAVEL INTERESTS'),
          const SizedBox(height: 4),
          const Text(
            'Select what you enjoy',
            style: TextStyle(fontSize: 12, color: _mid),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) {
              final selected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () => setState(() {
                  selected
                      ? _selectedInterests.remove(interest)
                      : _selectedInterests.add(interest);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _accent : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected ? _accent : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _mid,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Save button
          GestureDetector(
            onTap: _loading ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_accent, Color(0xFF66BB6A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
