import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShowTime extends StatefulWidget {
  const ShowTime({super.key});

  @override
  State<ShowTime> createState() => _ShowTimeState();
}

class _ShowTimeState extends State<ShowTime> {

 Time _time = Time(hour: 11, minute: 30, second: 20);
  bool iosStyle = true;

  void onTimeChanged(Time newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return    showPicker(
                context: context,
                value: _time,
                sunrise: TimeOfDay(hour: 6, minute: 0), // optional
                sunset: TimeOfDay(hour: 18, minute: 0), // optional
                duskSpanInMinutes: 120, // optional
                onChange: onTimeChanged,
            );
  }
}