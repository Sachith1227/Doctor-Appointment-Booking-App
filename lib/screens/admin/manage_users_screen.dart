import 'package:flutter/material.dart';

import '../../format.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search patients by name or email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AsyncBody(
              builder: (context) {
                final results = store.patients
                    .where(
                      (u) =>
                          u.name.toLowerCase().contains(_query) ||
                          u.email.toLowerCase().contains(_query),
                    )
                    .toList();
                if (results.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No patients found',
                    message: 'Try a different name or email.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = results[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: PersonAvatar(u.name, radius: 22),
                        title: Text(
                          u.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(u.email),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => push(context, UserDetailScreen(user: u)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final appts = store.appointmentsForPatient(user.id)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final active = appts.where((a) => a.status.isActive).length;
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PersonAvatar(user.name, radius: 36),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(Icons.mail_outline, 'Email', user.email),
                  InfoRow(Icons.badge_outlined, 'Role', 'Patient'),
                  InfoRow(Icons.calendar_today, 'Joined', fmtDate(user.joined)),
                  InfoRow(
                    Icons.event_note_outlined,
                    'Appointments',
                    '${appts.length} total · $active upcoming',
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Appointments'),
          if (appts.isEmpty)
            const Text('This patient has not requested any appointments.')
          else
            for (final a in appts)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppointmentCard(
                  name: store.doctorById(a.doctorId).name,
                  subtitle: store.doctorById(a.doctorId).specialty,
                  dateTime: a.dateTime,
                  status: a.status,
                  onTap: () => push(
                    context,
                    AppointmentDetailsScreen(appointmentId: a.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
