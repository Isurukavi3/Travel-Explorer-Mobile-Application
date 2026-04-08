import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/guide_model.dart';
import '../models/booking_request_model.dart';
import '../providers/app_provider.dart';

class RequestGuidePage extends StatefulWidget {
  final GuideModel guide;
  const RequestGuidePage({super.key, required this.guide});

  @override
  State<RequestGuidePage> createState() => _RequestGuidePageState();
}

class _RequestGuidePageState extends State<RequestGuidePage> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _hours = 1;
  bool _loading = false;

  static const _accent = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF8F9FF);
  static const _textDark = Color(0xFF1C1C2E);
  static const _textMid = Color(0xFF6B7280);

  static const _avatarColors = [
    Color(0xFF2E7D32),
    Color(0xFF00B4D8),
    Color(0xFF2D9B4E),
    Color(0xFFE07B39),
    Color(0xFF7B5EA7),
    Color(0xFFE63946),
  ];

  Color get _guideColor {
    final code = widget.guide.name.isNotEmpty
        ? widget.guide.name.codeUnitAt(0)
        : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<AppProvider>();
      final user = provider.currentUser!;
      final booking = BookingRequestModel(
        id: provider.service.generateId(),
        guideId: widget.guide.id,
        guideName: widget.guide.name,
        touristId: user.uid,
        touristName: user.displayName ?? 'Tourist',
        placeId: '',
        placeName: 'TBD',
        requestedDate: _selectedDate,
        hours: _hours,
        message: _messageCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await provider.service.requestGuide(booking);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Guide request sent!')));
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

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: _textMid,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final color = _guideColor;
    final totalCost = widget.guide.hourlyRate * _hours;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book a Guide',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Guide profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      widget.guide.name.isNotEmpty
                          ? widget.guide.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.guide.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RatingBarIndicator(
                          rating: widget.guide.rating,
                          itemBuilder: (_, _i) => const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.guide.expertise,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${widget.guide.hourlyRate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'per hour',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Date picker
            _sectionLabel('PREFERRED DATE'),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: _accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB0B7C3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Duration stepper
            _sectionLabel('DURATION'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: _accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Hours',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const Spacer(),
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: _hours > 1 ? () => setState(() => _hours--) : null,
                    color: _accent,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_hours',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: _hours < 8 ? () => setState(() => _hours++) : null,
                    color: _accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Message
            _sectionLabel('MESSAGE (OPTIONAL)'),
            TextFormField(
              controller: _messageCtrl,
              style: const TextStyle(fontSize: 14, color: _textDark),
              decoration: InputDecoration(
                hintText: 'Tell the guide about your interests...',
                hintStyle: const TextStyle(
                  color: Color(0xFFB0B7C3),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: _accent,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _accent, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Cost summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.08),
                    _accent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Cost',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textMid,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_hours hr × \$${widget.guide.hourlyRate.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: _textMid),
                      ),
                    ],
                  ),
                  Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, _accent],
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
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Send Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.12)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? color : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
