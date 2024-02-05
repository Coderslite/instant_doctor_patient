// Function to calculate the next two weeks' dates based on the selected month
import 'package:intl/intl.dart';

// Function to generate all future dates of the selected month, excluding past dates
List<DateTime> generateAvailableDates(selectedMonth) {
  int currentMonth = DateTime.now().month;
  int selectedMonthIndex = _getMonthNumber(selectedMonth);

  // Calculate the number of months to add
  int monthsToAdd = selectedMonthIndex - currentMonth;
  if (monthsToAdd < 0) {
    monthsToAdd += 12;
  }

  List<DateTime> result = [];
  DateTime currentDate = DateTime.now();

  // Calculate all future dates of the selected month, excluding past dates
  if (monthsToAdd == 0) {
    for (int i = currentDate.day;
        i <= DateTime(currentDate.year, currentMonth + 1, 0).day;
        i++) {
      DateTime nextDate = DateTime(currentDate.year, currentMonth, i);
      result.add(nextDate);
    }
  } else {
    // For future months, add all dates starting from the 1st day
    for (int i = 1;
        i <= DateTime(currentDate.year, currentMonth + monthsToAdd + 1, 0).day;
        i++) {
      DateTime nextDate =
          DateTime(currentDate.year, currentMonth + monthsToAdd, i);
      result.add(nextDate);
    }
  }

  return result;
}

int _getMonthNumber(String month) {
  switch (month.toLowerCase()) {
    case 'january':
      return 1;
    case 'february':
      return 2;
    case 'march':
      return 3;
    case 'april':
      return 4;
    case 'may':
      return 5;
    case 'june':
      return 6;
    case 'july':
      return 7;
    case 'august':
      return 8;
    case 'september':
      return 9;
    case 'october':
      return 10;
    case 'november':
      return 11;
    case 'december':
      return 12;
    default:
      return 1; // Default to January if not recognized
  }
}

// Function to generate available months excluding past months
List<String> generateAvailableMonths() {
  int currentMonth = DateTime.now().month;
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months
      .where((month) => months.indexOf(month) >= currentMonth - 1)
      .toList();
}
