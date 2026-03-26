class DurationFormatter {
  DurationFormatter._();

  /// Formats a Duration into HH:MM:SS string
  static String format(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formats a Duration into a readable label like "1h 23m"
  static String formatShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m ${duration.inSeconds % 60}s';
  }
}