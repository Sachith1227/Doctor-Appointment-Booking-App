import 'package:flutter/material.dart';

import 'mock_store.dart';
import 'models.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/doctor/doctor_shell.dart';
import 'screens/patient/patient_shell.dart';
import 'screens/shared/login_screen.dart';

/// Routes the signed-in user to the dashboard for their role.
void goHome(BuildContext context) {
  final home = switch (store.currentUser!.role) {
    Role.patient => const PatientShell(),
    Role.doctor => const DoctorShell(),
    Role.admin => const AdminDashboardScreen(),
  };
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => home),
    (_) => false,
  );
}

void signOutToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    (_) => false,
  );
  store.signOut();
}
