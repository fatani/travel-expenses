String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// Formats DateTime to "dd/MM/yy"
/// Example: "14/02/26" for Feb 14, 2026
String formatDate(DateTime dateTime) {
  final dt = dateTime.toLocal();
  final year = (dt.year % 100).toString().padLeft(2, '0');
  return '${_twoDigits(dt.day)}/${_twoDigits(dt.month)}/$year';
}

/// Formats DateTime to "HH:mm" (24-hour format)
/// Example: "14:38"
String formatTime(DateTime dateTime) {
  final dt = dateTime.toLocal();
  return '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
}

/// Formats DateTime to "dd/MM/yy • HH:mm" or just "dd/MM/yy" if time is midnight
/// Example: "14/02/26 • 14:38" or "14/02/26" if hour=0 and minute=0
/// 
/// Parameters:
/// - dateTime: The DateTime to format
/// - hideMidnight: If true and time is 00:00, only show date (default: true)
String formatDateTimeUi(DateTime dateTime, {bool hideMidnight = true}) {
  final dt = dateTime.toLocal();
  
  // Check if it's considered "midnight" (no meaningful time set)
  if (hideMidnight && dt.hour == 0 && dt.minute == 0) {
    return formatDate(dt);
  }
  
  return '${formatDate(dt)} • ${formatTime(dt)}';
}
