import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/alert_model.dart';
import '../../bloc/alert/alert_bloc.dart';

class CreateAlertSheet extends StatefulWidget {
  final double? suggestedPrice;
  final AlertModel? existingAlert;

  const CreateAlertSheet({super.key, this.suggestedPrice, this.existingAlert});

  @override
  State<CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<CreateAlertSheet> {
  final _priceController = TextEditingController();
  final _labelController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TriggerDirection _direction = TriggerDirection.crossAbove;
  AlertType _alertType = AlertType.standard;
  NotificationType _notifType = NotificationType.soundAndVibration;
  RepeatMode _repeatMode = RepeatMode.once;
  String _soundTheme = 'Default';
  bool _vibration = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingAlert != null;
    if (_isEditing) {
      final a = widget.existingAlert!;
      _priceController.text = a.targetPrice.toStringAsFixed(2);
      _labelController.text = a.label;
      _notesController.text = a.notes;
      _direction = a.direction;
      _alertType = a.alertType;
      _notifType = a.notificationType;
      _repeatMode = a.repeatMode;
      _soundTheme = a.soundTheme;
      _vibration = a.vibrationEnabled;
    } else if (widget.suggestedPrice != null) {
      _priceController.text = widget.suggestedPrice!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildSheetHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Target Price'),
                        _buildPriceField(),
                        const SizedBox(height: 20),
                        _SectionLabel('Trigger Direction'),
                        _buildDirectionSelector(),
                        const SizedBox(height: 20),
                        _SectionLabel('Alert Type'),
                        _buildAlertTypeSelector(),
                        const SizedBox(height: 20),
                        _SectionLabel('Notification'),
                        _buildNotifTypeSelector(),
                        const SizedBox(height: 20),
                        _SectionLabel('Sound Theme'),
                        _buildSoundSelector(),
                        const SizedBox(height: 16),
                        _buildVibrationToggle(),
                        const SizedBox(height: 20),
                        _SectionLabel('Repeat Mode'),
                        _buildRepeatSelector(),
                        const SizedBox(height: 20),
                        _SectionLabel('Label (Optional)'),
                        _buildLabelField(),
                        const SizedBox(height: 16),
                        _SectionLabel('Notes (Optional)'),
                        _buildNotesField(),
                        const SizedBox(height: 28),
                        _buildSaveButton(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.darkBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_alert_rounded,
                color: AppTheme.goldPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            _isEditing ? 'Edit Alert' : 'Create Alert',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF9898B8)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: GoogleFonts.spaceMono(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixText: '\$ ',
        prefixStyle: GoogleFonts.spaceMono(
          fontSize: 18,
          color: AppTheme.goldPrimary,
          fontWeight: FontWeight.w700,
        ),
        hintText: '0.00',
        hintStyle: GoogleFonts.spaceMono(
          color: const Color(0xFF5A5A7A),
          fontSize: 18,
        ),
        suffixText: 'USD/oz',
        suffixStyle: GoogleFonts.dmSans(
          color: const Color(0xFF5A5A7A),
          fontSize: 12,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter a target price';
        final p = double.tryParse(v);
        if (p == null || p <= 0) return 'Enter a valid price';
        if (p < 100 || p > 100000) return 'Price out of range';
        return null;
      },
    );
  }

  Widget _buildDirectionSelector() {
    return Row(
      children: TriggerDirection.values.map((dir) {
        final isSelected = _direction == dir;
        final isAbove = dir == TriggerDirection.crossAbove;
        final color = isAbove ? AppTheme.priceUp : AppTheme.priceDown;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isAbove ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _direction = dir),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.12)
                      : AppTheme.darkCardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.5) : AppTheme.darkBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isAbove
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isSelected ? color : const Color(0xFF5A5A7A),
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAbove ? 'Cross Above' : 'Cross Below',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : const Color(0xFF5A5A7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlertTypeSelector() {
    return Column(
      children: AlertType.values.map((type) {
        final isSelected = _alertType == type;
        String title, subtitle;
        IconData icon;
        Color color;
        switch (type) {
          case AlertType.standard:
            title = 'Standard Notification';
            subtitle = 'Regular push notification';
            icon = Icons.notifications_rounded;
            color = const Color(0xFF9898B8);
            break;
          case AlertType.highPriority:
            title = 'High Priority';
            subtitle = 'Heads-up notification with sound';
            icon = Icons.priority_high_rounded;
            color = AppTheme.goldPrimary;
            break;
          case AlertType.fullScreenAlarm:
            title = 'Full Screen Alarm';
            subtitle = 'Wake device with alarm overlay';
            icon = Icons.alarm_rounded;
            color = AppTheme.priceDown;
            break;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _alertType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.08) : AppTheme.darkCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.4) : AppTheme.darkBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: isSelected ? color : const Color(0xFF5A5A7A), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF9898B8),
                            )),
                        Text(subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: const Color(0xFF5A5A7A),
                            )),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 18),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotifTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: NotificationType.values.map((type) {
        final isSelected = _notifType == type;
        final labels = {
          NotificationType.notification: '🔔 Notify',
          NotificationType.sound: '🔊 Sound',
          NotificationType.vibration: '📳 Vibrate',
          NotificationType.soundAndVibration: '🔊 Sound + Vibrate',
        };
        return FilterChip(
          selected: isSelected,
          label: Text(labels[type] ?? ''),
          onSelected: (_) => setState(() => _notifType = type),
          selectedColor: AppTheme.goldPrimary.withOpacity(0.15),
          checkmarkColor: AppTheme.goldPrimary,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.goldPrimary : const Color(0xFF9898B8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSoundSelector() {
    return DropdownButtonFormField<String>(
      value: _soundTheme,
      dropdownColor: AppTheme.darkCardElevated,
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      decoration: const InputDecoration(),
      items: AppConstants.soundThemes
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => _soundTheme = v!),
    );
  }

  Widget _buildVibrationToggle() {
    return Row(
      children: [
        Text(
          'Vibration',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Switch(
          value: _vibration,
          onChanged: (v) => setState(() => _vibration = v),
        ),
      ],
    );
  }

  Widget _buildRepeatSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RepeatMode.values.map((mode) {
        final isSelected = _repeatMode == mode;
        final labels = {
          RepeatMode.once: 'Once',
          RepeatMode.everyMinute: 'Every 1m',
          RepeatMode.every5Minutes: 'Every 5m',
          RepeatMode.every15Minutes: 'Every 15m',
          RepeatMode.untilDismissed: 'Repeat',
        };
        return ChoiceChip(
          selected: isSelected,
          label: Text(labels[mode] ?? ''),
          onSelected: (_) => setState(() => _repeatMode = mode),
          selectedColor: AppTheme.goldPrimary.withOpacity(0.15),
          backgroundColor: AppTheme.darkCardElevated,
          side: BorderSide(
            color: isSelected ? AppTheme.goldPrimary.withOpacity(0.4) : AppTheme.darkBorder,
          ),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.goldPrimary : const Color(0xFF9898B8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelController,
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g. Support Level, Resistance...',
        hintStyle: GoogleFonts.dmSans(color: const Color(0xFF5A5A7A), fontSize: 14),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 2,
      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Add any notes about this alert...',
        hintStyle: GoogleFonts.dmSans(color: const Color(0xFF5A5A7A), fontSize: 14),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _saveAlert(context),
        child: Text(
          _isEditing ? 'Save Changes' : 'Create Alert',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _saveAlert(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text);
    final alert = AlertModel(
      id: _isEditing ? widget.existingAlert!.id : null,
      targetPrice: price,
      direction: _direction,
      alertType: _alertType,
      notificationType: _notifType,
      soundTheme: _soundTheme,
      vibrationEnabled: _vibration,
      repeatMode: _repeatMode,
      status: _isEditing ? widget.existingAlert!.status : AlertStatus.active,
      label: _labelController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: _isEditing ? widget.existingAlert!.createdAt : null,
    );

    if (_isEditing) {
      context.read<AlertBloc>().add(UpdateAlert(alert));
    } else {
      context.read<AlertBloc>().add(CreateAlert(alert));
    }

    Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF9898B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
