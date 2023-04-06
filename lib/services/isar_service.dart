import 'package:isar/isar.dart';
import 'package:recap/models/remainder.dart';
import 'package:recap/models/settings_data.dart';

class IsarService {
  static late final Isar _isar;

  Isar get isar => _isar;

  Future init() async {
    _isar = await Isar.open([RemainderSchema, SettingsDataSchema]);
  }
}
