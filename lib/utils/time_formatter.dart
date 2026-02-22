import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

String formatGameTime(String utcString, {tz.Location? location, String? locale}) {
  try {
    final utcTime = DateTime.parse(utcString).toUtc();

    DateTime localTime;
    if (location != null) {
      localTime = tz.TZDateTime.from(utcTime, location);
    } else {
      localTime = utcTime.toLocal();
    }

    return DateFormat('EEE d MMM - HH:mm', locale ?? 'fr').format(localTime);
  } catch (_) {
    return utcString;
  }
}
