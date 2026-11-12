import 'package:flutter/material.dart';

import '../../format.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

class AppointmentReportsScreen extends StatefulWidget {
  const AppointmentReportsScreen({super.key});

  @override
  State<AppointmentReportsScreen> createState() =>
      _AppointmentReportsScreenState();
}

class _AppointmentReportsScreenState extends State<AppointmentReportsScreen> {
  DateTimeRange? _range;
  ApptStatus? _status; // null = all

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Reports')),
      body: AsyncBody(builder: _content),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final range = _range;
    final inRange = store.appointments.where((a) {
      if (range == null) return true;
      final d = dateOnly(a.dateTime);
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
    final matches =
        inRange.where((a) => _status == null || a.status == _status).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  range == null
                      ? 'All dates'
                      : '${range.start.day} ${monthShort(range.start)} – '
                            '${range.end.day} ${monthShort(range.end)}',
                ),
              ),
            ),
            if (range != null)
              IconButton(
                tooltip: 'Clear date filter',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _range = null),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final s in [null, ...ApptStatus.values])
              ChoiceChip(
                label: Text(s?.label ?? 'All'),
                selected: _status == s,
                onSelected: (_) => setState(() => _status = s),
              ),
          ],
        ),
        const SectionTitle('Appointments by status'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final s in ApptStatus.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(statusStyle(s).icon, color: statusStyle(s).fg),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s.label)),
                        Text(
                          '${inRange.where((a) => a.status == s).length}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${inRange.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionTitle(
          matches.length == 1
              ? '1 matching booking'
              : '${matches.length} matching bookings',
        ),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No bookings match these filters.'),
          )
        else
          for (final a in matches)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppointmentCard(
                name: store.doctorById(a.doctorId).name,
                subtitle: 'Patient: ${store.userById(a.patientId).name}',
                dateTime: a.dateTime,
                status: a.status,
                onTap: () => push(
                  context,
                  AppointmentDetailsScreen(appointmentId: a.id),
                ),
              ),
            ),
      ],
    );
  }
}
