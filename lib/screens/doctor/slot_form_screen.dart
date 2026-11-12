import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Add a slot (no [slot]) or edit / remove an existing one.
/// Reserved and booked slots open read-only.
class SlotFormScreen extends StatefulWidget {
  const SlotFormScreen({
    super.key,
    required this.doctorId,
    this.slot,
    this.date,
  });

  final String doctorId;
  final Slot? slot;
  final DateTime? date;

  @override
  State<SlotFormScreen> createState() => _SlotFormScreenState();
}

class _SlotFormScreenState extends State<SlotFormScreen> {
  late DateTime _date = dateOnly(
    widget.slot?.start ?? widget.date ?? DateTime.now(),
  );
  late TimeOfDay _time = widget.slot == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay.fromDateTime(widget.slot!.start);
  String? _error;

  bool get _editing => widget.slot != null;
  bool get _locked => _editing && widget.slot!.state != SlotState.available;

  DateTime get _start =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _error = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() {
        _time = picked;
        _error = null;
      });
    }
  }

  void _save() {
    final error = store.validateSlot(
      widget.doctorId,
      _start,
      ignoreId: widget.slot?.id,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_editing) {
      store.moveSlot(widget.slot!, _start);
    } else {
      store.addSlot(widget.doctorId, _start);
    }
    Navigator.pop(context);
    showSnack(context, _editing ? t('Slot updated.') : t('Slot added.'));
  }

  Future<void> _remove() async {
    final ok = await confirmDialog(
      context,
      title: t('Remove slot?'),
      message: t('Patients will no longer be able to book {0} on {1}.', [
        fmtTime(_start),
        fmtDate(_start),
      ]),
      confirmLabel: t('Remove'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    store.removeSlot(widget.slot!);
    Navigator.pop(context);
    showSnack(context, t('Slot removed.'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final end = _start.add(const Duration(minutes: Slot.minutes));
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? t('Edit Availability') : t('Add Slot')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (_locked) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: slotStyle(widget.slot!.state).bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock, color: slotStyle(widget.slot!.state).fg),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t(
                        'This slot is {0}. You cannot change or remove it '
                        'while a patient has it.',
                        [widget.slot!.state.label],
                      ),
                      style: TextStyle(
                        color: slotStyle(widget.slot!.state).fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _PickerField(
            label: t('Date'),
            value: fmtDate(_date),
            icon: Icons.calendar_today,
            onTap: _locked ? null : _pickDate,
          ),
          const SizedBox(height: 16),
          _PickerField(
            label: t('Start time'),
            value: fmtTime(_start),
            icon: Icons.schedule,
            errorText: _error,
            onTap: _locked ? null : _pickTime,
          ),
          const SizedBox(height: 10),
          Text(
            t('Each slot is {0} minutes: {1} – {2}.', [
              Slot.minutes,
              fmtTime(_start),
              fmtTime(end),
            ]),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: t('Save Slot'),
            onPressed: _locked ? null : _save,
          ),
          if (_editing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _locked ? null : _remove,
                icon: const Icon(Icons.delete_outline),
                label: Text(t('Remove Slot')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
          errorText: errorText,
          enabled: enabled,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? null : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
