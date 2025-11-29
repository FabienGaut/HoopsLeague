import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
/// A simple clock service that can be mocked for testing.
/// By default, it returns the current time, but it can be subclassed
/// to return a fixed time for tests.
class Clock {
  DateTime now() => DateTime.now();
  DateTime toLocalTime(DateTime utcTime) => utcTime.toLocal();
}


class LAClock extends Clock {
  final tz.Location _laLocation;
  tz.Location get location => _laLocation;

  LAClock() : _laLocation = _initLocation();

  static tz.Location _initLocation() {
    tz.initializeTimeZones();
    return tz.getLocation('America/Los_Angeles');
  }

  @override
  DateTime now() => tz.TZDateTime.now(_laLocation);

  @override
  DateTime toLocalTime(DateTime utcTime) => tz.TZDateTime.from(utcTime, _laLocation);
}
