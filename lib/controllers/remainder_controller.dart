import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:recap/models/remainder.dart';
import 'package:recap/services/isar_service.dart';
import 'package:recap/services/notification_service.dart';

final remainderListProvider =
    StateNotifierProvider<RemainderController, List<Remainder>>(
        (ref) => RemainderController([]));

class RemainderController extends StateNotifier<List<Remainder>> {
  RemainderController(super.state) {
    initialize();
  }

  Future initialize() async {
    state = await IsarService().isar.remainders.where().findAll();
  }

  Future repeatNotification(BuildContext context, Remainder remainder) async {
    try {
      if (remainder.scheduledDate != null) {
        await NotificationService().showScheduledNotification(
          remainder,
        );
      } else {
        await NotificationService().showNotification(
          remainder,
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

  Future addRemainder(Remainder newRemainder) async {
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.remainders.put(newRemainder);
    });
    if (newRemainder.scheduledDate != null) {
      await NotificationService().showScheduledNotification(
        newRemainder,
      );
    } else {
      await NotificationService().showNotification(
        newRemainder,
      );
    }
    state = [...state, newRemainder];
  }

  Future editRemainder(int id, Remainder newRemainder) async {
    await IsarService().isar.writeTxn(() async {
      newRemainder.id = id;
      await IsarService().isar.remainders.put(newRemainder);
    });
    await NotificationService().cancelNotification(id);
    if (newRemainder.scheduledDate != null) {
      await NotificationService().showScheduledNotification(
        newRemainder,
      );
    } else {
      await NotificationService().showNotification(
        newRemainder,
      );
    }
    state = [
      for (int i = 0; i < state.length; i++)
        if (state[i].id == id) state[i] = newRemainder else state[i],
    ];
  }

  Future deleteRemainder(Remainder remainder) async {
    await NotificationService().cancelNotification(remainder.id);
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.remainders.delete(remainder.id);
    });
    state = state.where((element) => element.id != remainder.id).toList();
  }
}
