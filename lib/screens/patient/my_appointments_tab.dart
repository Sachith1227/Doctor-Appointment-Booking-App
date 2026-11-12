import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../specialties.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

class MyAppointmentsTab extends StatelessWidget {
  const MyAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('My Appointments')),
          bottom: TabBar(
            tabs: [
              Tab(text: t('Upcoming')),
              Tab(text: t('History')),
            ],
          ),
        ),
        body: AsyncBody(
          builder: (context) {
            final user = store.currentUser;
            if (user == null) return const SizedBox.shrink();
            final all = store.appointmentsForPatient(user.id);
            final upcoming = all.where((a) => a.status.isActive).toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
            final history = all.where((a) => !a.status.isActive).toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
            return TabBarView(
              children: [
                _list(
                  context,
                  upcoming,
                  EmptyState(
                    icon: Icons.event_available,
                    title: t('No upcoming appointments'),
                    message: t(
                      'Go to Home and choose a doctor to book your first '
                      'appointment.',
                    ),
                  ),
                ),
                _list(
                  context,
                  history,
                  EmptyState(
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

  Widget _list(BuildContext context, List<Appointment> items, Widget empty) {
    if (items.isEmpty) return empty;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final a = items[i];
        final doctor = store.doctorById(a.doctorId);
        return FadeSlideIn(
          index: i,
          child: AppointmentCard(
            name: doctor.nameL,
            avatarName: doctor.name,
            subtitle:
                '${specialtyOf(doctor.specialty).simpleL}\n${doctor.clinicL}',
            dateTime: a.dateTime,
            status: a.status,
            onTap: () =>
                push(context, AppointmentDetailsScreen(appointmentId: a.id)),
          ),
        );
      },
    );
  }
}
