import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../shared/account_settings.dart';
import 'my_appointments_tab.dart';
import 'notifications_tab.dart';
import 'patient_home_tab.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const PatientHomeTab(),
          const MyAppointmentsTab(),
          const NotificationsTab(),
          Scaffold(
            appBar: AppBar(title: Text(t('Profile'))),
            body: const AccountSettingsView(),
          ),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final user = store.currentUser;
          final unread = user == null ? 0 : store.unreadCount(user.id);
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: t('Home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: t('Appointments'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications),
                ),
                label: t('Notifications'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: t('Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}
