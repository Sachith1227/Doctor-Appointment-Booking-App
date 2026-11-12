import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../specialties.dart';
import '../../widgets.dart';
import 'select_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final doctor = store.doctorById(doctorId);
    final sp = specialtyOf(doctor.specialty);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t('Doctor Profile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PersonAvatar(
                    doctor.name,
                    radius: 48,
                    heroTag: 'doctor-${doctor.id}',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    doctor.nameL,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sp.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sp.icon, color: sp.color, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            sp.simpleL,
                            style: TextStyle(
                              color: sp.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sp.simple != sp.name) ...[
                    const SizedBox(height: 6),
                    Text(sp.nameL, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (sp.treats.isNotEmpty)
                    InfoRow(Icons.healing, t('Helps with'), sp.treatsL),
                  InfoRow(
                    Icons.location_on_outlined,
                    t('Clinic location'),
                    doctor.clinicL,
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(t('About the doctor')),
          Text(
            doctor.bioL,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: t('View Availability'),
            icon: Icons.calendar_month,
            onPressed: () =>
                push(context, SelectAppointmentScreen(doctorId: doctorId)),
          ),
        ],
      ),
    );
  }
}
