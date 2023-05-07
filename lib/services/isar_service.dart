import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recap/models/reminder.dart';
import 'package:recap/models/settings_data.dart';

class IsarService {
  static late final Isar _isar;

  Isar get isar => _isar;

  Future init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([ReminderSchema, SettingsDataSchema],
        directory: documentsDirectory.path);
  }
}
