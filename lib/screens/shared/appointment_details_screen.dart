import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../models.dart';
import '../../specialties.dart';
import '../../widgets.dart';

/// Appointment details for every role. The actions depend on who is looking:
/// patients can cancel, doctors can accept / reject / complete, admins view.
class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  bool _busy = false;

  late final Role _role = store.currentUser?.role ?? Role.patient;
  late final bool _openedAsRequest =
      _role == Role.doctor &&
      store.appointmentById(widget.appointmentId).status == ApptStatus.pending;

  Future<void> _run({
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(Appointment) action,
    required String done,
    bool destructive = false,
  }) async {
    final ok = await confirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: t('Go Back'),
      destructive: destructive,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    await action(store.appointmentById(widget.appointmentId));
    if (!mounted) return;
    setState(() => _busy = false);
    showSnack(context, done);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final a = store.appointmentById(widget.appointmentId);
        final doctor = store.doctorById(a.doctorId);
        final patient = store.userById(a.patientId);
        final theme = Theme.of(context);
        final forDoctor = _role == Role.doctor;
        final actions = _actions(a, patient.name);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _openedAsRequest
                  ? t('Request Details')
                  : t('Appointment Details'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PersonAvatar(
                            forDoctor ? patient.name : doctor.name,
                            radius: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  forDoctor ? patient.name : doctor.nameL,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  forDoctor
                                      ? t('Patient')
                                      : specialtyOf(doctor.specialty).fullL,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(t('Status'), style: theme.textTheme.bodyMedium),
                          const SizedBox(width: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: StatusBadge(
                              a.status,
                              key: ValueKey(a.status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.status.description,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      if (_role == Role.admin)
                        InfoRow(
                          Icons.person_outline,
                          t('Patient'),
                          patient.name,
                        ),
                      if (forDoctor)
                        InfoRow(Icons.mail_outline, t('Email'), patient.email),
                      InfoRow(
                        Icons.calendar_today,
                        t('Date'),
                        fmtDate(a.dateTime),
                      ),
                      InfoRow(Icons.schedule, t('Time'), fmtTime(a.dateTime)),
                      InfoRow(
                        Icons.location_on_outlined,
                        t('Clinic'),
                        doctor.clinicL,
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(t('What has happened so far')),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StatusTimeline(a),
                ),
              ),
            ],
          ),
          bottomNavigationBar: actions == null
              ? null
              : BottomActionBar(children: [actions]),
        );
      },
    );
  }

  Widget? _actions(Appointment a, String patientName) {
    final when = fmtDateTime(a.dateTime);
    final scheme = Theme.of(context).colorScheme;

    if (_role == Role.patient && a.status.isActive) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
          onPressed: _busy
              ? null
              : () => _run(
                  title: t('Cancel appointment?'),
                  message: t(
                    'Your appointment on {0} will be cancelled. The time '
                    'will be given to other patients.',
                    [when],
                  ),
                  confirmLabel: t('Cancel Appointment'),
                  destructive: true,
                  action: store.cancel,
                  done: t('Appointment cancelled. The time is free again.'),
                ),
          child: Text(_busy ? t('Cancelling…') : t('Cancel Appointment')),
        ),
      );
    }

    if (_role == Role.doctor && a.status == ApptStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
              onPressed: _busy
                  ? null
                  : () => _run(
                      title: t('Reject request?'),
                      message: t(
                        '{0} will be told that the request for {1} was '
                        'rejected. The time becomes free again.',
                        [patientName, when],
                      ),
                      confirmLabel: t('Reject'),
                      destructive: true,
                      action: store.reject,
                      done: t('Request rejected. The time is free again.'),
                    ),
              child: Text(t('Reject')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                      title: t('Accept request?'),
                      message: t(
                        'This confirms the appointment with {0} on {1}.',
                        [patientName, when],
                      ),
                      confirmLabel: t('Accept'),
                      action: store.accept,
                      done: t('Appointment confirmed.'),
                    ),
              child: Text(t('Accept')),
            ),
          ),
        ],
      );
    }

    if (_role == Role.doctor && a.status == ApptStatus.confirmed) {
      return PrimaryButton(
        label: t('Mark as Completed'),
        icon: Icons.task_alt,
        loading: _busy,
        onPressed: () => _run(
          title: t('Mark as completed?'),
          message: t('Confirm that the visit with {0} is finished.', [
            patientName,
          ]),
          confirmLabel: t('Mark Completed'),
          action: store.complete,
          done: t('Appointment marked as completed.'),
        ),
      );
    }

    return null;
  }
}
