String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  if (days > 0) {
    return "${days}d ${twoDigits(hours)}h ${twoDigits(minutes)}m ${twoDigits(seconds)}s";
  } else {
    return "${twoDigits(hours)}h ${twoDigits(minutes)}m ${twoDigits(seconds)}s";
  }
}
