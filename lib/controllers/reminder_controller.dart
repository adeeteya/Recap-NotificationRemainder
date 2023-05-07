import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:recap/models/reminder.dart';
import 'package:recap/services/isar_service.dart';
import 'package:recap/services/notification_service.dart';

final reminderListProvider =
    AsyncNotifierProvider<ReminderController, List<Reminder>>(
        () => ReminderController());

class ReminderController extends AsyncNotifier<List<Reminder>> {
  @override
  FutureOr<List<Reminder>> build() async {
    return await IsarService().isar.reminders.where().findAll();
  }

  Future repeatNotification(BuildContext context, Reminder reminder) async {
    try {
      if (reminder.scheduledDate != null) {
        await NotificationService().showScheduledNotification(
          reminder,
        );
      } else {
        await NotificationService().showNotification(
          reminder,
        );
      }
    } on ArgumentError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future addReminder(Reminder newReminder) async {
    List<Reminder> currentState = state.value ?? [];
    state = const AsyncValue.loading();
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.reminders.put(newReminder);
    });
    if (newReminder.scheduledDate != null) {
      await NotificationService().showScheduledNotification(
        newReminder,
      );
    } else {
      await NotificationService().showNotification(
        newReminder,
      );
    }
    state = AsyncValue.data([...currentState, newReminder]);
  }

  Future editReminder(int id, Reminder newReminder) async {
    List<Reminder> currentState = state.value ?? [];
    state = const AsyncValue.loading();
    await IsarService().isar.writeTxn(() async {
      newReminder.id = id;
      await IsarService().isar.reminders.put(newReminder);
    });
    await NotificationService().cancelNotification(id);
    if (newReminder.scheduledDate != null) {
      await NotificationService().showScheduledNotification(
        newReminder,
      );
    } else {
      await NotificationService().showNotification(
        newReminder,
      );
    }
    state = AsyncValue.data([
      for (int i = 0; i < currentState.length; i++)
        if (currentState[i].id == id)
          currentState[i] = newReminder
        else
          currentState[i],
    ]);
  }

  Future deleteReminder(Reminder reminder) async {
    List<Reminder> currentState = state.value ?? [];
    state = const AsyncValue.loading();
    await NotificationService().cancelNotification(reminder.id);
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.reminders.delete(reminder.id);
    });
    state = AsyncValue.data(
        currentState.where((element) => element.id != reminder.id).toList());
  }
}
