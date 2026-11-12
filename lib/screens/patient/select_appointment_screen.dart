import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../specialties.dart';
import '../../widgets.dart';
import 'review_appointment_screen.dart';

class SelectAppointmentScreen extends StatefulWidget {
  const SelectAppointmentScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  State<SelectAppointmentScreen> createState() =>
      _SelectAppointmentScreenState();
}

class _SelectAppointmentScreenState extends State<SelectAppointmentScreen> {
  DateTime _date = dateOnly(DateTime.now());
  String? _slotId;

  Future<void> _continue() async {
    await push(context, ReviewAppointmentScreen(slotId: _slotId!));
    if (!mounted) return;
    // Coming back from Review: drop the selection if the slot has gone.
    final slot = store.slotById(_slotId);
    setState(() {
      if (slot == null || !store.isBookable(slot)) _slotId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = store.doctorById(widget.doctorId);
    final theme = Theme.of(context);
    final slot = store.slotById(_slotId);
    return Scaffold(
      appBar: AppBar(title: Text(t('Select Appointment'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '${doctor.nameL} · ${specialtyOf(doctor.specialty).simpleL}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          DateStrip(
            selected: _date,
            onSelected: (d) => setState(() {
              _date = d;
              _slotId = null;
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('Selected date'), style: theme.textTheme.bodySmall),
                Text(
                  fmtDate(_date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: AsyncBody(builder: _slots)),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: slot == null
                ? t('Choose a time')
                : t('Continue with {0}', [fmtTime(slot.start)]),
            icon: slot == null ? null : Icons.arrow_forward,
            onPressed: slot == null ? null : _continue,
          ),
        ],
      ),
    );
  }

  Widget _slots(BuildContext context) {
    final slots = store.slotsFor(widget.doctorId, _date);
    if (slots.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        title: t('No times on this day'),
        message: t(
          'The doctor has no appointment times on {0}. Please choose '
          'another date.',
          [fmtDate(_date)],
        ),
      );
    }
    final morning = slots.where((s) => s.start.hour < 12).toList();
    final afternoon = slots.where((s) => s.start.hour >= 12).toList();
    final anyBookable = slots.any(store.isBookable);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (!anyBookable)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              t('All times on this day are taken. Please choose another date.'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (morning.isNotEmpty) ...[
          _PartOfDay(Icons.wb_sunny_outlined, t('Morning')),
          SlotGrid(children: morning.map(_chip).toList()),
        ],
        if (afternoon.isNotEmpty) ...[
          _PartOfDay(Icons.wb_twilight, t('Afternoon')),
          SlotGrid(children: afternoon.map(_chip).toList()),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _Legend(t('Available'), SlotChipState.available),
            _Legend(t('Selected'), SlotChipState.selected),
            _Legend(t('Unavailable'), SlotChipState.unavailable),
          ],
        ),
      ],
    );
  }

  Widget _chip(Slot s) {
    final state = !store.isBookable(s)
        ? SlotChipState.unavailable
        : s.id == _slotId
        ? SlotChipState.selected
        : SlotChipState.available;
    return SlotChip(
      label: fmtTime(s.start),
      state: state,
      onTap: () => setState(() => _slotId = s.id),
    );
  }
}

class _PartOfDay extends StatelessWidget {
  const _PartOfDay(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Icon(icon, size: 20, color: const Color(0xFFFF8A3D)),
        ),
        const SizedBox(width: 8),
        SectionTitle(label),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.state);
  final String label;
  final SlotChipState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (fill, border) = switch (state) {
      SlotChipState.available => (Colors.white, scheme.primary),
      SlotChipState.selected => (scheme.primary, scheme.primary),
      SlotChipState.unavailable => (
        const Color(0xFFE6E9F2),
        const Color(0xFFB9C0D0),
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
