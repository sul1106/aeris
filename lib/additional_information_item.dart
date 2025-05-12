import 'package:flutter/material.dart';
class AdditionalInfoItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
   AdditionalInfoItem({
    super.key,
     required this.label,
    required this.icon,
     required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 8),
        Text(value, style:const TextStyle
          (
            fontSize: 12,
            fontWeight: FontWeight.bold
        ),
        )

      ],
    );
  }

}