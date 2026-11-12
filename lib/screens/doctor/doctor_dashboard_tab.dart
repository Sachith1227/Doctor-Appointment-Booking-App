import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';
import 'doctor_appointments_tab.dart';

class DoctorDashboardTab extends StatelessWidget {
  const DoctorDashboardTab({super.key, required this.onManageAvailability});
  final VoidCallback onManageAvailability;

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser;
    final doctor = user?.doctorId == null
        ? null
        : store.doctorById(user!.doctorId!);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fmtDate(DateTime.now()),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor?.nameL ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const LanguagePill(),
              ],
            ),
          ),
          Expanded(child: AsyncBody(builder: _content)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final doctorId = store.currentUser?.doctorId;
    if (doctorId == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final all = store.appointmentsForDoctor(doctorId);
    final pending = all.where((a) => a.status == ApptStatus.pending).length;
    final now = DateTime.now();
    final today =
        all
            .where(
              (a) =>
                  sameDay(a.dateTime, now) &&
                  (a.status == ApptStatus.confirmed ||
                      a.status == ApptStatus.completed),
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        TapScale(
          child: Card(
            color: const Color(0xFFFFF4E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFFD9A8)),
            ),
            child: InkWell(
              onTap: () => push(context, const AppointmentRequestsScreen()),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: kWarm,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Text(
                          '$pending',
                          key: ValueKey(pending),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Pending requests'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            pending == 0
                                ? t('Nothing to review right now')
                                : t('Patients are waiting for your reply'),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                icon: Icons.fact_check_outlined,
                color: kPrimary,
                label: t('Review Requests'),
                onTap: () => push(context, const AppointmentRequestsScreen()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Shortcut(
                icon: Icons.edit_calendar_outlined,
                color: kAccent,
                label: t('Manage Availability'),
                onTap: onManageAvailability,
              ),
            ),
          ],
        ),
        SectionTitle(t('Today\'s schedule')),
        if (today.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.free_breakfast_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(t('No confirmed appointments today.'))),
                ],
              ),
            ),
          )
        else
          for (final (i, a) in today.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FadeSlideIn(
                index: i,
                child: AppointmentCard(
                  name: store.userById(a.patientId).name,
                  subtitle: t('Patient'),
                  dateTime: a.dateTime,
                  status: a.status,
                  onTap: () => push(
                    context,
                    AppointmentDetailsScreen(appointmentId: a.id),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
