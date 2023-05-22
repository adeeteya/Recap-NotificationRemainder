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
  final String imageFilePath;

  @enumerated
  final Importance importance;

  Reminder(this.title, this.content, this.isPersistent, this.scheduledDate,
      this.imageFilePath, this.importance);

  Reminder copyWith({
    String? title,
    String? content,
    bool? isPersistent,
    DateTime? scheduledDate,
    String? imageFilePath,
    Importance? importance,
  }) {
    return Reminder(
      title ?? this.title,
      content ?? this.content,
      isPersistent ?? this.isPersistent,
      scheduledDate,
      imageFilePath ?? this.imageFilePath,
      importance ?? this.importance,
    );
  }
}
