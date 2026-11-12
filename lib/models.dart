import 'l10n.dart';

enum Role { patient, doctor, admin }

enum ApptStatus { pending, confirmed, rejected, cancelled, completed }

enum SlotState { available, reserved, booked }

extension ApptStatusText on ApptStatus {
  /// Label in the current app language.
  String get label => t(switch (this) {
    ApptStatus.pending => 'Pending',
    ApptStatus.confirmed => 'Confirmed',
    ApptStatus.rejected => 'Rejected',
    ApptStatus.cancelled => 'Cancelled',
    ApptStatus.completed => 'Completed',
  });

  String get description => t(switch (this) {
    ApptStatus.pending => 'Request sent. Waiting for the doctor to reply.',
    ApptStatus.confirmed => 'The doctor accepted the request.',
    ApptStatus.rejected =>
      'The doctor could not accept the request. The time is free again.',
    ApptStatus.cancelled => 'The patient cancelled. The time is free again.',
    ApptStatus.completed => 'The visit is finished.',
  });

  bool get isActive =>
      this == ApptStatus.pending || this == ApptStatus.confirmed;
}

extension SlotStateText on SlotState {
  String get label => t(switch (this) {
    SlotState.available => 'Available',
    SlotState.reserved => 'Reserved',
    SlotState.booked => 'Booked',
  });
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.joined,
    this.doctorId,
  });

  final String id;
  String name;
  final String email;
  final String password;
  final Role role;
  final DateTime joined;

  /// Set for doctor accounts: the [Doctor] profile this account owns.
  final String? doctorId;
}

class Doctor {
  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.clinic,
    required this.bio,
    this.active = true,
    this.nameSi,
    this.clinicSi,
    this.bioSi,
  });

  final String id;
  String name;
  final String email;
  String specialty;
  String clinic;
  String bio;
  bool active;

  // Optional Sinhala versions; English is shown when they are missing.
  String? nameSi;
  String? clinicSi;
  String? bioSi;

  String get nameL => pick(name, nameSi);
  String get clinicL => pick(clinic, clinicSi);
  String get bioL => pick(bio, bioSi);
}

class Slot {
  Slot({
    required this.id,
    required this.doctorId,
    required this.start,
    this.state = SlotState.available,
  });

  static const minutes = 30;

  final String id;
  final String doctorId;
  DateTime start;
  SlotState state;

  DateTime get end => start.add(const Duration(minutes: minutes));
}

class StatusEvent {
  StatusEvent(this.status, this.at);
  final ApptStatus status;
  final DateTime at;
}

class Appointment {
  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.dateTime,
    required this.status,
    required this.events,
    this.slotId,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final String? slotId;
  final DateTime dateTime;
  ApptStatus status;
  final List<StatusEvent> events;
}

/// A booking update. The text is built from [status] when shown, so it
/// follows the app language.
class AppNotification {
  AppNotification({
    required this.id,
    required this.userId,
    required this.appointmentId,
    required this.status,
    required this.at,
    this.read = false,
  });

  final String id;
  final String userId;
  final String appointmentId;
  final ApptStatus status;
  final DateTime at;
  bool read;
}
