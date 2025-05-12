import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
class HourlyForecastWidget extends StatelessWidget {
  final String date;
  final String time;
  final String temp;
  final Widget iconData;
  const HourlyForecastWidget({
    super.key,
    required this.date,
    required this.iconData,
    required this.time,
    required this.temp
  });


  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children:
          [
          Text(date, style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
            maxLines: 1,
            overflow:TextOverflow.ellipsis ,
          ),
            Text(time, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
              maxLines: 1,
              overflow:TextOverflow.ellipsis ,
            ),
            const SizedBox(height: 4),
           iconData,
            const SizedBox(height: 4),
            Text(temp, style: TextStyle(
              fontSize: 14,
            ),
            ),
          ],
        ),
      ),
    );
  }

}