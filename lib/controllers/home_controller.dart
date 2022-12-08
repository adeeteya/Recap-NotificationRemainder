import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:recap/controllers/notification_controller.dart';
import 'package:recap/models/remainder.dart';

class HomeController extends ChangeNotifier {
  static late final Isar _isar;
  static late final List<Remainder> _remainders;

  List<Remainder> get remainders => _remainders;

  Future initialize() async {
    _isar = await Isar.open([RemainderSchema]);
    _remainders = await _isar.remainders.where().findAll();
    await NotificationService().init();
    notifyListeners();
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
    await _isar.writeTxn(() async {
      await _isar.remainders.put(newRemainder);
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
    _remainders.add(newRemainder);
    notifyListeners();
  }

  Future editRemainder(int id, Remainder newRemainder) async {
    await _isar.writeTxn(() async {
      newRemainder.id = id;
      await _isar.remainders.put(newRemainder);
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
    for (int i = 0; i < _remainders.length; i++) {
      if (_remainders[i].id == id) {
        _remainders[i] = newRemainder;
      }
    }
    notifyListeners();
  }

  Future deleteRemainder(Remainder remainder) async {
    await NotificationService().cancelNotification(remainder.id);
    await _isar.writeTxn(() async {
      await _isar.remainders.delete(remainder.id);
    });
    remainders.remove(remainder);
    notifyListeners();
  }
}
