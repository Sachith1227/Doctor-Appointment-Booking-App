import 'l10n.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdaysSi = ['සඳු', 'අඟ', 'බදා', 'බ්‍රහ', 'සිකු', 'සෙන', 'ඉරි'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _monthsSi = [
  'ජන', 'පෙබ', 'මාර්තු', 'අප්‍රේල්', 'මැයි', 'ජූනි', //
  'ජූලි', 'අගෝ', 'සැප්', 'ඔක්', 'නොවැ', 'දෙසැ',
];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String weekdayShort(DateTime d) =>
    (isSi ? _weekdaysSi : _weekdays)[d.weekday - 1];

String monthShort(DateTime d) => (isSi ? _monthsSi : _months)[d.month - 1];

/// "Sat, 14 Nov 2026" / "2026 නොවැ 14, සෙන"
String fmtDate(DateTime d) => isSi
    ? '${d.year} ${monthShort(d)} ${d.day}, ${weekdayShort(d)}'
    : '${weekdayShort(d)}, ${d.day} ${monthShort(d)} ${d.year}';

/// "9:30 AM" / "පෙ.ව. 9:30"
String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  if (isSi) return '${d.hour < 12 ? 'පෙ.ව.' : 'ප.ව.'} $h:$m';
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

String fmtDateTime(DateTime d) => '${fmtDate(d)} · ${fmtTime(d)}';

String fmtAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return t('Just now');
  if (diff.inMinutes < 60) return t('{0} min ago', [diff.inMinutes]);
  if (diff.inHours < 24) return t('{0} h ago', [diff.inHours]);
  if (diff.inDays < 7) return t('{0} d ago', [diff.inDays]);
  return fmtDate(d);
}

/// "Dr. Anjali Perera" -> "AP"
String initials(String name) {
  final parts = name
      .replaceFirst(RegExp(r'^Dr\.?\s+', caseSensitive: false), '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
