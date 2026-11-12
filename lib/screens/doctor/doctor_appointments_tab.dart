import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

List<Appointment> _doctorAppointments(bool Function(Appointment) test) {
  final doctorId = store.currentUser?.doctorId;
  if (doctorId == null) return [];
  return store.appointmentsForDoctor(doctorId).where(test).toList();
}

Widget _appointmentList(
  BuildContext context,
  List<Appointment> items, {
  required Widget empty,
  String? actionLabel,
}) {
  if (items.isEmpty) return empty;
  return ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, i) {
      final a = items[i];
      return FadeSlideIn(
        index: i,
        child: AppointmentCard(
          name: store.userById(a.patientId).name,
          subtitle: t('Patient'),
          dateTime: a.dateTime,
          status: a.status,
          actionLabel: actionLabel,
          onTap: () =>
              push(context, AppointmentDetailsScreen(appointmentId: a.id)),
        ),
      );
    },
  );
}

/// Pending request cards; used by the Requests tab and the stand-alone
/// screen opened from the dashboard.
class RequestList extends StatelessWidget {
  const RequestList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _doctorAppointments((a) => a.status == ApptStatus.pending)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return _appointmentList(
      context,
      items,
      actionLabel: t('View Request'),
      empty: EmptyState(
        icon: Icons.inbox_outlined,
        title: t('No pending requests'),
        message: t(
          'New appointment requests from patients will be shown here.',
        ),
      ),
    );
  }
}

class AppointmentRequestsScreen extends StatelessWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Appointment Requests'))),
      body: AsyncBody(builder: (_) => const RequestList()),
    );
  }
}

class DoctorAppointmentsTab extends StatelessWidget {
  const DoctorAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('Appointments')),
          bottom: TabBar(
            tabs: [
              Tab(text: t('Requests')),
              Tab(text: t('Upcoming')),
              Tab(text: t('History')),
            ],
          ),
        ),
        body: AsyncBody(
          builder: (context) {
            final upcoming = _doctorAppointments(
              (a) => a.status == ApptStatus.confirmed,
            )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
            final history = _doctorAppointments((a) => !a.status.isActive)
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
            return TabBarView(
              children: [
                const RequestList(),
                _appointmentList(
                  context,
                  upcoming,
                  empty: EmptyState(
                    icon: Icons.event_available,
                    title: t('No upcoming appointments'),
                    message: t(
                      'Appointments you accept will be shown here as '
                      'Confirmed.',
                    ),
                  ),
                ),
                _appointmentList(
                  context,
                  history,
                  empty: EmptyState(
                    icon: Icons.history,
                    title: t('No past appointments'),
                    message: t(
                      'Completed, cancelled and rejected appointments will '
                      'be shown here.',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
