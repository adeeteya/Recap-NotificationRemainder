import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
part 'reminder.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  final String title;
  final String content;
  final bool isPersistent;
  final DateTime? scheduledDate;

  @enumerated
  final Importance importance;

  Reminder(this.title, this.content, this.isPersistent, this.importance,
      this.scheduledDate);

  Reminder copyWith(
      {String? title,
      String? content,
      bool? isPersistent,
      Importance? importance,
      DateTime? scheduledDate}) {
    return Reminder(
        title ?? this.title,
        content ?? this.content,
        isPersistent ?? this.isPersistent,
        importance ?? this.importance,
        scheduledDate);
  }
}
