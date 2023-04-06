import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:recap/controllers/remainder_controller.dart';
import 'package:recap/models/remainder.dart';
import 'package:recap/screens/alert_form.dart';

class RemainderTile extends ConsumerWidget {
  final Remainder remainder;
  const RemainderTile({Key? key, required this.remainder}) : super(key: key);

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
                      child: AlertFormScreen(remainder: remainder),
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
                    .read(remainderListProvider.notifier)
                    .repeatNotification(context, remainder);
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
                await ref
                    .read(remainderListProvider.notifier)
                    .deleteRemainder(remainder);
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
        ),
      ),
    );
  }
}
