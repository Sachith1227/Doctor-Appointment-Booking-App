import 'package:flutter/material.dart';

import '../../mock_store.dart';
import '../../widgets.dart';
import '../shared/account_settings.dart';
import 'appointment_reports_screen.dart';
import 'manage_doctors_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Account & Settings',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => push(context, const AccountSettingsScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AsyncBody(
        builder: (context) {
          void doctors() => push(context, const ManageDoctorsScreen());
          void users() => push(context, const ManageUsersScreen());
          void reports() => push(context, const AppointmentReportsScreen());
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.medical_services_outlined,
                      count: store.doctors.length,
                      label: 'Doctors',
                      onTap: doctors,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.people_outline,
                      count: store.patients.length,
                      label: 'Users',
                      onTap: users,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.event_note_outlined,
                      count: store.appointments.length,
                      label: 'Appointments',
                      onTap: reports,
                    ),
                  ),
                ],
              ),
              const SectionTitle('Manage'),
              Card(
                child: Column(
                  children: [
                    _Shortcut(
                      icon: Icons.medical_services_outlined,
                      title: 'Manage Doctors',
                      subtitle: 'Add doctors and edit their profiles',
                      onTap: doctors,
                    ),
                    const Divider(height: 1),
                    _Shortcut(
                      icon: Icons.people_outline,
                      title: 'Manage Users',
                      subtitle: 'Search and view patient accounts',
                      onTap: users,
                    ),
                    const Divider(height: 1),
                    _Shortcut(
                      icon: Icons.bar_chart,
                      title: 'Appointment Reports',
                      subtitle: 'Filter bookings by date and status',
                      onTap: reports,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
