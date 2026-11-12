import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../specialties.dart';
import '../../widgets.dart';
import '../shared/account_settings.dart';
import 'doctor_appointments_tab.dart';
import 'doctor_dashboard_tab.dart';
import 'manage_availability_tab.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DoctorDashboardTab(
            onManageAvailability: () => setState(() => _index = 1),
          ),
          const ManageAvailabilityTab(),
          const DoctorAppointmentsTab(),
          Scaffold(
            appBar: AppBar(title: Text(t('Profile'))),
            body: const AccountSettingsView(header: _DoctorDetails()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: t('Dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: t('Schedule'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: t('Appointments'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t('Profile'),
          ),
        ],
      ),
    );
  }
}

/// Specialty, clinic and bio, shown above the shared account settings.
class _DoctorDetails extends StatelessWidget {
  const _DoctorDetails();

  @override
  Widget build(BuildContext context) {
    final doctorId = store.currentUser?.doctorId;
    if (doctorId == null) return const SizedBox.shrink();
    final doctor = store.doctorById(doctorId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(t('Doctor details')),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                InfoRow(
                  Icons.medical_services_outlined,
                  t('Kind of doctor'),
                  specialtyOf(doctor.specialty).fullL,
                ),
                InfoRow(
                  Icons.location_on_outlined,
                  t('Clinic'),
                  doctor.clinicL,
                ),
                InfoRow(Icons.info_outline, t('About'), doctor.bioL),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
