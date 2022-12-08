import 'package:isar/isar.dart';

part 'remainder.g.dart';

@collection
class Remainder {
  Id id = Isar.autoIncrement;

  final String title;
  final String content;
  final bool isPersistent;
  final int importanceValue;
  final DateTime? scheduledDate;

  Remainder(this.title, this.content, this.isPersistent, this.importanceValue,
      this.scheduledDate);

  Remainder copyWith(
      {String? title,
      String? content,
      bool? isPersistent,
      int? importanceValue,
      DateTime? scheduledDate}) {
    return Remainder(
        title ?? this.title,
        content ?? this.content,
        isPersistent ?? this.isPersistent,
        importanceValue ?? this.importanceValue,
        scheduledDate);
  }
}
