import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingSchedule extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;

  const BookingSchedule({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> timeSlots = [
      "09:00 AM",
      "10:00 AM",
      "11:00 AM",
      "12:00 PM",
      "01:00 PM",
      "02:00 PM",
      "03:00 PM",
      "04:00 PM",
      "05:00 PM"
    ];

    final DateTime now = DateTime.now();
    final bool isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    final List<String> availableSlots = timeSlots.where((time) {
      if (!isToday) return true;

      // Parse time slot (e.g., "09:00 AM")
      final parts = time.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final amPm = parts[1];

      if (amPm == "PM" && hour != 12) hour += 12;
      if (amPm == "AM" && hour == 12) hour = 0;

      final slotDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Allow slots that are at least 15 minutes in the future to give buffer
      return slotDateTime.isAfter(now.add(const Duration(minutes: 15)));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Schedule',
          style: boldTextStyle(size: 22, color: ink, letterSpacing: -0.5),
        ),
        8.height,
        Text(
          'Choose a convenient date and time for your consultation.',
          style: secondaryTextStyle(size: 13, color: slate, height: 1.4),
        ),
        24.height,

        // Horizontal Date Picker
        Text(
          'Available Dates',
          style: boldTextStyle(size: 15, color: ink),
        ),
        16.height,
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Next 2 weeks
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = selectedDate.day == date.day &&
                  selectedDate.month == date.month &&
                  selectedDate.year == date.year;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kPrimary : border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonth(date.month),
                        style: boldTextStyle(
                          size: 10,
                          color: isSelected ? white.withOpacity(0.7) : slate,
                        ),
                      ),
                      4.height,
                      Text(
                        '${date.day}',
                        style: boldTextStyle(
                          size: 20,
                          color: isSelected ? white : ink,
                        ),
                      ),
                      4.height,
                      Text(
                        _getWeekday(date.weekday),
                        style: boldTextStyle(
                          size: 10,
                          color: isSelected ? white.withOpacity(0.7) : slate,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        24.height,
        Text(
          'Available Time Slots',
          style: boldTextStyle(size: 15, color: ink),
        ),
        if (availableSlots.isEmpty) ...[
          16.height,
          Text(
            "No more slots available for today. Please pick another date.",
            style: secondaryTextStyle(color: redText, size: 12),
          ),
        ] else ...[
          16.height,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final time = availableSlots[index];
              final isSelected = selectedTime == time;

              return GestureDetector(
                onTap: () => onTimeSelected(time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary.withOpacity(0.1) : white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? kPrimary : border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: boldTextStyle(
                      size: 12,
                      color: isSelected ? kPrimary : ink,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  String _getMonth(int month) {
    return [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ][month - 1];
  }

  String _getWeekday(int weekday) {
    return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][weekday - 1];
  }
}
