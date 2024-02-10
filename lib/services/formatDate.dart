import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  String daySuffix;
  int day = date.day;
  if (day >= 11 && day <= 13) {
    daySuffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        daySuffix = 'st';
        break;
      case 2:
        daySuffix = 'nd';
        break;
      case 3:
        daySuffix = 'rd';
        break;
      default:
        daySuffix = 'th';
    }
  }

  DateFormat dateFormat = DateFormat("d'$daySuffix'-MMMM-yyyy h:mm a");
  String formattedDate = dateFormat.format(date);
  return formattedDate;
}


String formatDateWithoutTime(DateTime date) {
  String daySuffix;
  int day = date.day;
  if (day >= 11 && day <= 13) {
    daySuffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        daySuffix = 'st';
        break;
      case 2:
        daySuffix = 'nd';
        break;
      case 3:
        daySuffix = 'rd';
        break;
      default:
        daySuffix = 'th';
    }
  }

  DateFormat dateFormat = DateFormat("d'$daySuffix'-MMMM-yyyy");
  String formattedDate = dateFormat.format(date);
  return formattedDate;
}
