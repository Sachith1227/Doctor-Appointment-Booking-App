import 'package:flutter/foundation.dart';

import 'format.dart';
import 'l10n.dart';
import 'models.dart';

/// In-memory stand-in for Firebase Auth + Firestore.
///
/// Every screen reads and writes through this class, so swapping in Firebase
/// later means replacing these methods rather than touching the UI.
class MockStore extends ChangeNotifier {
  MockStore() {
    _seed();
  }

  /// Simulated network delay.
  static const latency = Duration(milliseconds: 500);

  final users = <AppUser>[];
  final doctors = <Doctor>[];
  final slots = <Slot>[];
  final appointments = <Appointment>[];
  final notifications = <AppNotification>[];

  AppUser? currentUser;

  // Notification preferences (per device in this mock).
  bool notifyBookingUpdates = true;
  bool notifyReminders = true;

  // Prototype-only switches, toggled from Account & Settings.
  bool simulateLoadError = false;
  bool simulateSlotTaken = false;

  int _seq = 1;
  String _id(String prefix) => '$prefix${_seq++}';

  void reset() {
    users.clear();
    doctors.clear();
    slots.clear();
    appointments.clear();
    notifications.clear();
    currentUser = null;
    notifyBookingUpdates = true;
    notifyReminders = true;
    simulateLoadError = false;
    simulateSlotTaken = false;
    _seq = 1;
    appLang.value = AppLang.en;
    _seed();
    notifyListeners();
  }

  void setPrefs({
    bool? bookingUpdates,
    bool? reminders,
    bool? loadError,
    bool? slotTaken,
  }) {
    notifyBookingUpdates = bookingUpdates ?? notifyBookingUpdates;
    notifyReminders = reminders ?? notifyReminders;
    simulateLoadError = loadError ?? simulateLoadError;
    simulateSlotTaken = slotTaken ?? simulateSlotTaken;
    notifyListeners();
  }

  // ---------------------------------------------------------------- loading

  /// Simulates fetching a screen's data. Fails once if the prototype
  /// "connection error" switch is on, so the retry state can be shown.
  Future<void> load() async {
    await Future<void>.delayed(latency);
    if (simulateLoadError) {
      simulateLoadError = false;
      throw Exception('Simulated connection error');
    }
  }

  // ------------------------------------------------------------------- auth

  Future<String?> login(String email, String password) async {
    await Future<void>.delayed(latency);
    final user = _userByEmail(email);
    if (user == null || user.password != password) {
      return t('Wrong email or password. Please try again.');
    }
    if (user.role == Role.doctor && !doctorById(user.doctorId!).active) {
      return t(
        'This doctor account is switched off. Please contact the admin.',
      );
    }
    currentUser = user;
    notifyListeners();
    return null;
  }

  Future<String?> registerPatient(
    String name,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(latency);
    if (_userByEmail(email) != null) {
      return t('An account with this email already exists.');
    }
    final user = AppUser(
      id: _id('u'),
      name: name.trim(),
      email: email.trim(),
      password: password,
      role: Role.patient,
      joined: DateTime.now(),
    );
    users.add(user);
    currentUser = user;
    notifyListeners();
    return null;
  }

  /// Deliberately does not notify: the caller navigates to Login first and
  /// screens that are being torn down should not rebuild without a user.
  void signOut() => currentUser = null;

  AppUser? _userByEmail(String email) {
    final e = email.trim().toLowerCase();
    return users.where((u) => u.email.toLowerCase() == e).firstOrNull;
  }

  // ---------------------------------------------------------------- lookups

  AppUser userById(String id) => users.firstWhere((u) => u.id == id);
  Doctor doctorById(String id) => doctors.firstWhere((d) => d.id == id);
  Slot? slotById(String? id) => slots.where((s) => s.id == id).firstOrNull;
  Appointment appointmentById(String id) =>
      appointments.firstWhere((a) => a.id == id);

  List<AppUser> get patients =>
      users.where((u) => u.role == Role.patient).toList();

  List<Slot> slotsFor(String doctorId, DateTime day) =>
      slots
          .where((s) => s.doctorId == doctorId && sameDay(s.start, day))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  bool isBookable(Slot s) =>
      s.state == SlotState.available && s.start.isAfter(DateTime.now());

  List<Appointment> appointmentsForPatient(String userId) =>
      appointments.where((a) => a.patientId == userId).toList();

  List<Appointment> appointmentsForDoctor(String doctorId) =>
      appointments.where((a) => a.doctorId == doctorId).toList();

  /// The pending/confirmed appointment holding [slotId], if any.
  Appointment? activeAppointmentForSlot(String slotId) => appointments
      .where((a) => a.slotId == slotId && a.status.isActive)
      .firstOrNull;

  List<AppNotification> notificationsFor(String userId) =>
      notifications.where((n) => n.userId == userId).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  int unreadCount(String userId) =>
      notifications.where((n) => n.userId == userId && !n.read).length;

  void markRead(AppNotification n) {
    if (n.read) return;
    n.read = true;
    notifyListeners();
  }

  void markAllRead(String userId) {
    for (final n in notifications.where((n) => n.userId == userId)) {
      n.read = true;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- booking

  /// Creates a Pending appointment and holds the slot. Returns null when the
  /// slot was taken in the meantime.
  Future<Appointment?> requestAppointment(String slotId) async {
    await Future<void>.delayed(latency);
    final slot = slotById(slotId);
    if (slot != null && simulateSlotTaken) {
      simulateSlotTaken = false;
      slot.state = SlotState.booked; // someone else got there first
    }
    if (slot == null || !isBookable(slot)) {
      notifyListeners();
      return null;
    }
    slot.state = SlotState.reserved;
    final appt = Appointment(
      id: _id('a'),
      doctorId: slot.doctorId,
      patientId: currentUser!.id,
      slotId: slot.id,
      dateTime: slot.start,
      status: ApptStatus.pending,
      events: [StatusEvent(ApptStatus.pending, DateTime.now())],
    );
    appointments.add(appt);
    _notify(appt, ApptStatus.pending);
    notifyListeners();
    return appt;
  }

  Future<void> accept(Appointment a) => _transition(a, ApptStatus.confirmed);
  Future<void> reject(Appointment a) => _transition(a, ApptStatus.rejected);
  Future<void> cancel(Appointment a) => _transition(a, ApptStatus.cancelled);
  Future<void> complete(Appointment a) => _transition(a, ApptStatus.completed);

  Future<void> _transition(Appointment a, ApptStatus to) async {
    await Future<void>.delayed(latency);
    final allowed = switch (to) {
      ApptStatus.confirmed ||
      ApptStatus.rejected => a.status == ApptStatus.pending,
      ApptStatus.cancelled => a.status.isActive,
      ApptStatus.completed => a.status == ApptStatus.confirmed,
      ApptStatus.pending => false,
    };
    if (!allowed) return;
    a.status = to;
    a.events.add(StatusEvent(to, DateTime.now()));
    final slot = slotById(a.slotId);
    if (slot != null) {
      if (to == ApptStatus.confirmed) slot.state = SlotState.booked;
      if (to == ApptStatus.rejected || to == ApptStatus.cancelled) {
        slot.state = SlotState.available;
      }
    }
    _notify(a, to);
    notifyListeners();
  }

  void _notify(Appointment a, ApptStatus s, {DateTime? at, bool read = false}) {
    notifications.add(
      AppNotification(
        id: _id('n'),
        userId: a.patientId,
        appointmentId: a.id,
        status: s,
        at: at ?? DateTime.now(),
        read: read,
      ),
    );
  }

  /// Notification text in the current app language.
  ({String title, String body}) notificationText(AppNotification n) {
    final a = appointmentById(n.appointmentId);
    final args = [doctorById(a.doctorId).nameL, fmtDateTime(a.dateTime)];
    return switch (n.status) {
      ApptStatus.pending => (
        title: t('Appointment request sent'),
        body: t('Your request to {0} for {1} is waiting for a reply.', args),
      ),
      ApptStatus.confirmed => (
        title: t('Appointment confirmed'),
        body: t('{0} accepted your request for {1}.', args),
      ),
      ApptStatus.rejected => (
        title: t('Appointment rejected'),
        body: t('{0} could not accept your request for {1}.', args),
      ),
      ApptStatus.cancelled => (
        title: t('Appointment cancelled'),
        body: t('Your appointment with {0} on {1} was cancelled.', args),
      ),
      ApptStatus.completed => (
        title: t('Appointment completed'),
        body: t('Your visit to {0} on {1} is finished.', args),
      ),
    };
  }

  // ----------------------------------------------------------- availability

  /// Returns an error message, or null when [start] is a valid slot time.
  String? validateSlot(String doctorId, DateTime start, {String? ignoreId}) {
    if (start.isBefore(DateTime.now())) {
      return t('Choose a time in the future.');
    }
    for (final s in slots) {
      if (s.doctorId != doctorId || s.id == ignoreId) continue;
      if (s.start == start) return t('A slot already exists at this time.');
      if (s.start.difference(start).inMinutes.abs() < Slot.minutes) {
        return t('This overlaps with the {0} slot.', [fmtTime(s.start)]);
      }
    }
    return null;
  }

  void addSlot(String doctorId, DateTime start) {
    slots.add(Slot(id: _id('s'), doctorId: doctorId, start: start));
    notifyListeners();
  }

  void moveSlot(Slot slot, DateTime start) {
    if (slot.state != SlotState.available) return;
    slot.start = start;
    notifyListeners();
  }

  void removeSlot(Slot slot) {
    if (slot.state != SlotState.available) return;
    slots.remove(slot);
    notifyListeners();
  }

  // ------------------------------------------------------------------ admin

  /// Password given to doctor accounts created in the mock.
  static const demoDoctorPassword = 'doctor123';

  String? validateNewDoctorEmail(String email) => _userByEmail(email) == null
      ? null
      : t('An account with this email already exists.');

  void addDoctor({
    required String name,
    required String email,
    required String specialty,
    required String clinic,
    required String bio,
    required bool active,
  }) {
    final d = Doctor(
      id: _id('d'),
      name: name,
      email: email,
      specialty: specialty,
      clinic: clinic,
      bio: bio,
      active: active,
    );
    doctors.add(d);
    users.add(
      AppUser(
        id: _id('u'),
        name: name,
        email: email,
        password: demoDoctorPassword,
        role: Role.doctor,
        joined: DateTime.now(),
        doctorId: d.id,
      ),
    );
    notifyListeners();
  }

  void updateDoctor(
    Doctor d, {
    required String name,
    required String specialty,
    required String clinic,
    required String bio,
    required bool active,
  }) {
    d
      ..name = name
      ..specialty = specialty
      ..clinic = clinic
      ..bio = bio
      ..active = active;
    users.where((u) => u.doctorId == d.id).firstOrNull?.name = name;
    notifyListeners();
  }

  // ------------------------------------------------------------------- seed

  void _seed() {
    final now = DateTime.now();
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

    void doctor(
      String name,
      String email,
      String specialty,
      String clinic,
      String bio,
    ) {
      final d = Doctor(
        id: _id('d'),
        name: name,
        email: email,
        specialty: specialty,
        clinic: clinic,
        bio: bio,
      );
      doctors.add(d);
      users.add(
        AppUser(
          id: _id('u'),
          name: name,
          email: email,
          password: demoDoctorPassword,
          role: Role.doctor,
          joined: at(-200, 9),
          doctorId: d.id,
        ),
      );
    }

    AppUser patient(String name, String email, int joinedDaysAgo) {
      final u = AppUser(
        id: _id('u'),
        name: name,
        email: email,
        password: 'patient123',
        role: Role.patient,
        joined: at(-joinedDaysAgo, 10),
      );
      users.add(u);
      return u;
    }

    doctor(
      'Dr. Anjali Perera',
      'anjali.perera@mydoctor.lk',
      'Cardiologist',
      'Lakeside Medical Centre, Colombo 07',
      'Consultant cardiologist with 14 years of experience in preventive '
          'cardiology, hypertension and heart failure management.',
    );
    doctor(
      'Dr. Ruwan Fernando',
      'ruwan.fernando@mydoctor.lk',
      'Dermatologist',
      'Hill Country Skin Clinic, Kandy',
      'Treats acne, eczema, psoriasis and other skin conditions for adults '
          'and children. Special interest in tropical skin disease.',
    );
    doctor(
      'Dr. Tharushi Silva',
      'tharushi.silva@mydoctor.lk',
      'Paediatrician',
      'Southern Care Clinic, Galle',
      'Cares for newborns, children and teenagers, with a focus on growth, '
          'nutrition and childhood asthma.',
    );
    doctor(
      'Dr. Kasun Wijesinghe',
      'kasun.wijesinghe@mydoctor.lk',
      'General Physician',
      'Rajarata Family Clinic, Anuradhapura',
      'Family physician managing diabetes, fever, infections and routine '
          'health checks for all ages.',
    );
    doctor(
      'Dr. Fathima Rizwan',
      'fathima.rizwan@mydoctor.lk',
      'Gynaecologist',
      'Lagoon Wellness Centre, Negombo',
      'Obstetrician and gynaecologist providing antenatal care, family '
          'planning and women\'s health consultations.',
    );
    doctor(
      'Dr. Sivakumar Nadarajah',
      'sivakumar.nadarajah@mydoctor.lk',
      'Orthopaedic Surgeon',
      'Northern Health Point, Jaffna',
      'Specialises in sports injuries, joint pain and fracture care, '
          'including post-surgery rehabilitation.',
    );

    // Plain-language bios, plus Sinhala names, clinics and bios.
    const local = [
      (
        'Heart specialist with 14 years of experience. Helps with chest '
            'pain, high blood pressure and other heart problems.',
        'වෛද්‍ය අංජලී පෙරේරා',
        'ලේක්සයිඩ් වෛද්‍ය මධ්‍යස්ථානය, කොළඹ 07',
        'වසර 14ක පළපුරුද්දක් ඇති හෘද රෝග විශේෂඥ වෛද්‍යවරියකි. පපුවේ '
            'වේදනාව, අධි රුධිර පීඩනය සහ අනෙකුත් හෘද රෝග සඳහා ප්‍රතිකාර කරයි.',
      ),
      (
        'Skin specialist for adults and children. Helps with pimples, '
            'rashes, itching and other skin problems.',
        'වෛද්‍ය රුවන් ප්‍රනාන්දු',
        'හිල් කන්ට්‍රි සම රෝග සායනය, මහනුවර',
        'වැඩිහිටියන් සහ ළමුන් සඳහා සම රෝග විශේෂඥ වෛද්‍යවරයෙකි. කුරුලෑ, '
            'බිබිලි, කැසීම සහ අනෙකුත් සමේ රෝග සඳහා ප්‍රතිකාර කරයි.',
      ),
      (
        'Children\'s specialist. Looks after babies, children and '
            'teenagers, including growth, food and breathing problems.',
        'වෛද්‍ය තරුෂි සිල්වා',
        'සදර්න් කෙයාර් සායනය, ගාල්ල',
        'ළමා රෝග විශේෂඥ වෛද්‍යවරියකි. ළදරුවන්, ළමුන් සහ යොවුන් දරුවන්ගේ '
            'වර්ධනය, පෝෂණය සහ හුස්ම ගැනීමේ අපහසුතා ගැන සොයා බලයි.',
      ),
      (
        'Family doctor for all ages. Helps with fever, infections, '
            'diabetes and regular health check-ups.',
        'වෛද්‍ය කසුන් විජේසිංහ',
        'රජරට පවුල් සායනය, අනුරාධපුරය',
        'සෑම වයසකම අය සඳහා පවුලේ වෛද්‍යවරයෙකි. උණ, ආසාදන, දියවැඩියාව සහ '
            'සෞඛ්‍ය පරීක්ෂා සඳහා උපකාර කරයි.',
      ),
      (
        'Women\'s health specialist. Helps with pregnancy care, family '
            'planning and other women\'s health needs.',
        'වෛද්‍ය ෆාතිමා රිස්වාන්',
        'ලගූන් සුවතා මධ්‍යස්ථානය, මීගමුව',
        'නාරි හා ප්‍රසව රෝග විශේෂඥ වෛද්‍යවරියකි. ගර්භණී සත්කාර, පවුල් '
            'සැලසුම් සහ කාන්තා සෞඛ්‍ය ගැටලු සඳහා උපකාර කරයි.',
      ),
      (
        'Bone and joint specialist. Helps with broken bones, joint pain '
            'and sports injuries, and with recovery after surgery.',
        'වෛද්‍ය සිවකුමාර් නඩරාජා',
        'නෝදර්න් හෙල්ත් පොයින්ට්, යාපනය',
        'අස්ථි රෝග විශේෂඥ වෛද්‍යවරයෙකි. අස්ථි බිඳීම්, සන්ධි වේදනා, ක්‍රීඩා '
            'තුවාල සහ සැත්කමෙන් පසු සුවය සඳහා උපකාර කරයි.',
      ),
    ];
    for (var i = 0; i < local.length; i++) {
      final (bio, nameSi, clinicSi, bioSi) = local[i];
      doctors[i]
        ..bio = bio
        ..nameSi = nameSi
        ..clinicSi = clinicSi
        ..bioSi = bioSi;
    }

    final nimal = patient('Nimal Jayawardena', 'nimal@example.com', 40);
    final sanduni = patient('Sanduni Rathnayake', 'sanduni@example.com', 31);
    final farook = patient('Mohamed Farook', 'farook@example.com', 22);
    final priya = patient('Priya Selvarajah', 'priya@example.com', 15);
    final chamara = patient('Chamara Bandara', 'chamara@example.com', 9);

    users.add(
      AppUser(
        id: _id('u'),
        name: 'System Admin',
        email: 'admin@mydoctor.lk',
        password: 'admin123',
        role: Role.admin,
        joined: at(-365, 9),
      ),
    );

    // Slots: today plus nine days. Day +3 is left empty on purpose so the
    // "no slots" state is easy to find.
    const times = [
      (9, 0),
      (9, 30),
      (10, 0),
      (11, 0),
      (14, 0),
      (14, 30),
      (15, 30),
      (16, 0),
    ];
    for (final d in doctors) {
      for (var day = 0; day < 10; day++) {
        if (day == 3) continue;
        for (final (h, m) in times) {
          slots.add(Slot(id: _id('s'), doctorId: d.id, start: at(day, h, m)));
        }
      }
    }

    Slot? slotAt(String doctorId, DateTime start) => slots
        .where((s) => s.doctorId == doctorId && s.start == start)
        .firstOrNull;

    // A few slots taken by other people, so unavailable chips show up.
    for (final d in doctors.skip(1)) {
      slotAt(d.id, at(1, 15, 30))?.state = SlotState.booked;
      slotAt(d.id, at(2, 9))?.state = SlotState.reserved;
    }

    void appt(
      Doctor d,
      AppUser p,
      DateTime when,
      ApptStatus status,
      Duration createdAgo,
    ) {
      final created = now.subtract(createdAgo);
      final resolved = status == ApptStatus.completed
          ? when.add(const Duration(minutes: Slot.minutes))
          : created.add(const Duration(hours: 2));
      final slot = slotAt(d.id, when);
      if (status == ApptStatus.pending) slot?.state = SlotState.reserved;
      if (status == ApptStatus.confirmed) slot?.state = SlotState.booked;
      final a = Appointment(
        id: _id('a'),
        doctorId: d.id,
        patientId: p.id,
        slotId: slot?.id,
        dateTime: when,
        status: status,
        events: [
          StatusEvent(ApptStatus.pending, created),
          if (status != ApptStatus.pending) StatusEvent(status, resolved),
        ],
      );
      appointments.add(a);
      _notify(
        a,
        status,
        at: status == ApptStatus.pending ? created : resolved,
        read: !status.isActive,
      );
    }

    final [perera, fernando, silva, wijesinghe, ...] = doctors;
    const h = Duration(hours: 1);
    const day = Duration(days: 1);

    // The demo patient's bookings.
    appt(perera, nimal, at(1, 9, 30), ApptStatus.confirmed, day * 2);
    appt(fernando, nimal, at(2, 10), ApptStatus.pending, h * 3);
    appt(silva, nimal, at(-6, 10), ApptStatus.completed, day * 9);
    appt(wijesinghe, nimal, at(-12, 14), ApptStatus.rejected, day * 14);

    // The demo doctor's other patients.
    appt(perera, sanduni, at(1, 10), ApptStatus.pending, h * 5);
    appt(perera, farook, at(2, 14), ApptStatus.pending, h);
    appt(perera, priya, at(0, 14, 30), ApptStatus.confirmed, day * 3);
    appt(perera, chamara, at(4, 11), ApptStatus.confirmed, day);
    appt(perera, chamara, at(-1, 11), ApptStatus.completed, day * 4);
    appt(perera, sanduni, at(-3, 15, 30), ApptStatus.cancelled, day * 5);
  }
}

final store = MockStore();
