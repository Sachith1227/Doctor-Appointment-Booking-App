import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'slot_form_screen.dart';

class ManageAvailabilityTab extends StatefulWidget {
  const ManageAvailabilityTab({super.key});

  @override
  State<ManageAvailabilityTab> createState() => _ManageAvailabilityTabState();
}

class _ManageAvailabilityTabState extends State<ManageAvailabilityTab> {
  DateTime _date = dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final doctorId = store.currentUser?.doctorId;
    if (doctorId == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('Manage Availability'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            push(context, SlotFormScreen(doctorId: doctorId, date: _date)),
        icon: const Icon(Icons.add),
        label: Text(t('Add Slot')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateStrip(
            selected: _date,
            onSelected: (d) => setState(() => _date = d),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              fmtDate(_date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: AsyncBody(
              builder: (context) {
                final slots = store.slotsFor(doctorId, _date);
                if (slots.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_busy,
                    title: t('No times on this day'),
                    message: t(
                      'Tap Add Slot to open appointment times for patients.',
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: slots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => FadeSlideIn(
                    key: ValueKey(slots[i].id),
                    index: i,
                    child: _SlotTile(slots[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile(this.slot);
  final Slot slot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editable = slot.state == SlotState.available;
    final appt = store.activeAppointmentForSlot(slot.id);
    final who = appt == null
        ? t('a patient')
        : store.userById(appt.patientId).name;
    return TapScale(
      child: Card(
        child: InkWell(
          onTap: () => push(
            context,
            SlotFormScreen(doctorId: slot.doctorId, slot: slot),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fmtTime(slot.start)} – ${fmtTime(slot.end)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(switch (slot.state) {
                        SlotState.available => t('Open for booking'),
                        SlotState.reserved => t(
                          'Kept for {0} · waiting for your reply',
                          [who],
                        ),
                        SlotState.booked => t('Confirmed with {0}', [who]),
                      }, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Pill(label: slot.state.label, style: slotStyle(slot.state)),
                const SizedBox(width: 8),
                Icon(
                  editable ? Icons.edit_outlined : Icons.lock_outline,
                  size: 20,
                  color: editable ? scheme.primary : scheme.outline,
                  semanticLabel: editable ? t('Edit slot') : t('Locked'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
