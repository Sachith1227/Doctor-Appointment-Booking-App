import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../specialties.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

class ReviewAppointmentScreen extends StatefulWidget {
  const ReviewAppointmentScreen({super.key, required this.slotId});
  final String slotId;

  @override
  State<ReviewAppointmentScreen> createState() =>
      _ReviewAppointmentScreenState();
}

class _ReviewAppointmentScreenState extends State<ReviewAppointmentScreen> {
  bool _busy = false;
  bool _slotGone = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    final appt = await store.requestAppointment(widget.slotId);
    if (!mounted) return;
    if (appt == null) {
      setState(() {
        _busy = false;
        _slotGone = true;
      });
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => RequestSubmittedScreen(appointmentId: appt.id),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = store.slotById(widget.slotId)!;
    final doctor = store.doctorById(slot.doctorId);
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(t('Review Appointment'))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: !_slotGone
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: scheme.onErrorContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t(
                                    'This time is no longer available. '
                                    'Please choose another slot',
                                  ),
                                  style: TextStyle(
                                    color: scheme.onErrorContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t('Choose Another Slot')),
                          ),
                        ],
                      ),
                    ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(Icons.person_outline, t('Doctor'), doctor.nameL),
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
                    InfoRow(
                      Icons.calendar_today,
                      t('Date'),
                      fmtDate(slot.start),
                    ),
                    InfoRow(
                      Icons.schedule,
                      t('Time'),
                      '${fmtTime(slot.start)} – ${fmtTime(slot.end)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                'Your request stays Pending until the doctor replies. The '
                'time is kept for you until then.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          children: [
            PrimaryButton(
              label: t('Request Appointment'),
              loading: _busy,
              onPressed: _slotGone ? null : _submit,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: Text(t('Change Time')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestSubmittedScreen extends StatelessWidget {
  const RequestSubmittedScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    final appt = store.appointmentById(appointmentId);
    final doctor = store.doctorById(appt.doctorId);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Success tick pops in.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      gradient: kBrandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x402347D9),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  t('Appointment request sent'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                StatusBadge(appt.status),
                const SizedBox(height: 12),
                Text(
                  t('Your doctor will review your request.'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InfoRow(
                          Icons.person_outline,
                          t('Doctor'),
                          doctor.nameL,
                        ),
                        InfoRow(
                          Icons.calendar_today,
                          t('Date and time'),
                          fmtDateTime(appt.dateTime),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: t('View Appointment'),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) =>
                    AppointmentDetailsScreen(appointmentId: appointmentId),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Back to Home')),
            ),
          ),
        ],
      ),
    );
  }
}
