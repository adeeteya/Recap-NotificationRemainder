import 'package:flutter/material.dart';
import 'package:recap/models/remainder.dart';

class RemainderTile extends StatelessWidget {
  final Remainder remainder;
  const RemainderTile({Key? key, required this.remainder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                remainder.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                remainder.content,
                style: TextStyle(
                  color: ListTileTheme.of(context).textColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 8),
              if (remainder.scheduledDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${remainder.scheduledDate!.day}/${remainder.scheduledDate!.month}/${remainder.scheduledDate!.year}  ${remainder.scheduledDate!.hour}:${remainder.scheduledDate!.minute}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              if (remainder.isPersistent)
                Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Persistent",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
