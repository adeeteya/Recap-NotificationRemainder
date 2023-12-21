import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:recap/controllers/reminder_controller.dart';
import 'package:recap/models/reminder.dart';
import 'package:recap/screens/add_reminder.dart';
import 'package:recap/extensions.dart';

class ReminderTile extends ConsumerWidget {
  final Reminder reminder;
  const ReminderTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              label: "Edit",
              icon: Icons.edit,
              backgroundColor: Colors.green,
              borderRadius: BorderRadius.circular(10),
              onPressed: (context) async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, animation2) =>
                        SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: AddReminderScreen(reminder: reminder),
                    ),
                  ),
                );
              },
            ),
            SlidableAction(
              label: "Repeat",
              icon: Icons.refresh,
              backgroundColor: Colors.blue,
              borderRadius: BorderRadius.circular(10),
              onPressed: (context) async {
                await ref
                    .read(reminderListProvider.notifier)
                    .repeatNotification(context, reminder);
              },
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.24,
          children: [
            SlidableAction(
              label: "Delete",
              icon: Icons.delete,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(10),
              onPressed: (context) async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Reminder"),
                    content: const Text(
                        "Are you sure you want to delete this reminder?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(reminderListProvider.notifier)
                              .deleteReminder(reminder)
                              .then((value) => Navigator.pop(context));
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reminder.imageFilePath.isNotEmpty)
                        Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(right: 10),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.file(
                            File(reminder.imageFilePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reminder.content,
                              style: TextStyle(
                                color: ListTileTheme.of(context).textColor,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reminder.scheduledDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.scheduledDate!.timeAndDateInString,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  if (reminder.isPersistent)
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
