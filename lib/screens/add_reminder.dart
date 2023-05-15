import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recap/controllers/reminder_controller.dart';
import 'package:recap/models/reminder.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;
  const AddReminderScreen({
    Key? key,
    this.reminder,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends ConsumerState<AddReminderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _contentTextEditingController;
  late final TextEditingController _dateTextEditingController;
  Importance selectedImportance = Importance.defaultImportance;
  bool isPersistent = false;
  DateTime? scheduledDateTime;
  String encodedImageBytes = '';

  @override
  void initState() {
    if (widget.reminder != null) {
      _titleTextEditingController =
          TextEditingController(text: widget.reminder!.title);
      _contentTextEditingController =
          TextEditingController(text: widget.reminder!.content);
      scheduledDateTime = widget.reminder?.scheduledDate;
      _dateTextEditingController =
          TextEditingController(text: widget.reminder!.timeAndDateInString());
      selectedImportance = widget.reminder!.importance;
      isPersistent = widget.reminder!.isPersistent;
      encodedImageBytes = widget.reminder!.encodedImageBytes;
    } else {
      _titleTextEditingController = TextEditingController();
      _contentTextEditingController = TextEditingController();
      _dateTextEditingController = TextEditingController(text: "None");
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    _contentTextEditingController.dispose();
    _dateTextEditingController.dispose();
    super.dispose();
  }

  String timeAndDateInString() {
    int hour = scheduledDateTime?.hour ?? 0;
    int minute = scheduledDateTime?.minute ?? 0;
    return "${hour > 12 ? hour - 12 : hour}:${minute > 9 ? minute : "0$minute"} ${(hour > 12) ? "PM" : "AM"} - ${scheduledDateTime?.day}/${scheduledDateTime?.month}/${scheduledDateTime?.year}";
  }

  Future pickDateAndTime() async {
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "Select Time",
      cancelText: "None",
      confirmText: "Next",
    ).then((value) async {
      if (value == null) {
        setState(() {
          scheduledDateTime = null;
          _dateTextEditingController.clear();
        });
        return;
      }
      DateTime? dateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 1825)),
        helpText: "Select Date",
        cancelText: "None",
        confirmText: "Schedule",
      );
      if (dateTime == null) {
        setState(() {
          scheduledDateTime = null;
          _dateTextEditingController.clear();
        });
        return null;
      }
      dateTime =
          dateTime.add(Duration(hours: value.hour, minutes: value.minute));
      setState(() {
        scheduledDateTime = dateTime;
        _dateTextEditingController.text = timeAndDateInString();
      });
      return null;
    });
  }

  Future insertReminder() async {
    if (_formKey.currentState!.validate()) {
      if (widget.reminder != null) {
        Reminder newReminder = Reminder(
          _titleTextEditingController.text.trim(),
          _contentTextEditingController.text.trim(),
          isPersistent,
          scheduledDateTime,
          encodedImageBytes,
          selectedImportance,
        );
        await ref
            .read(reminderListProvider.notifier)
            .editReminder(widget.reminder!.id, newReminder)
            .then((value) => Navigator.pop(context));
      } else {
        Reminder newReminder = Reminder(
          _titleTextEditingController.text.trim(),
          _contentTextEditingController.text.trim(),
          isPersistent,
          scheduledDateTime,
          encodedImageBytes,
          selectedImportance,
        );
        await ref
            .read(reminderListProvider.notifier)
            .addReminder(newReminder)
            .then((value) => Navigator.pop(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: (widget.reminder != null)
              ? const Text("Edit Alert")
              : const Text("Create Alert"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final XFile? imageFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        encodedImageBytes =
                            base64.encode(await imageFile?.readAsBytes() ?? []);
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Ink(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                                  ? Theme.of(context).colorScheme.surfaceVariant
                                  : Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: (encodedImageBytes.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.memory(
                                  base64.decode(encodedImageBytes),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Image\n(optional)",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Importance",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButtonFormField<Importance>(
                              value: selectedImportance,
                              isDense: false,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: Importance.none,
                                  child: Text("None"),
                                ),
                                DropdownMenuItem(
                                  value: Importance.low,
                                  child: Text("Low"),
                                ),
                                DropdownMenuItem(
                                  value: Importance.min,
                                  child: Text("Min"),
                                ),
                                DropdownMenuItem(
                                  value: Importance.defaultImportance,
                                  child: Text("Default"),
                                ),
                                DropdownMenuItem(
                                  value: Importance.high,
                                  child: Text("High"),
                                ),
                                DropdownMenuItem(
                                  value: Importance.max,
                                  child: Text("Max"),
                                ),
                              ],
                              onChanged: (val) {
                                selectedImportance = val ?? selectedImportance;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            value: isPersistent,
                            checkColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: const Text(
                              "Persistent",
                            ),
                            onChanged: (val) {
                              setState(() {
                                isPersistent = val ?? isPersistent;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Title",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _titleTextEditingController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: "Title"),
                  validator: (val) {
                    if (val?.isEmpty ?? true) return "Please enter the title";
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Content",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _contentTextEditingController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(hintText: "Content"),
                  validator: (val) {
                    if (val?.isEmpty ?? true) return "Please enter the content";
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Schedule Notification",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _dateTextEditingController,
                  readOnly: true,
                  decoration: const InputDecoration(hintText: "None"),
                  validator: (val) {
                    if (scheduledDateTime == null) return null;
                    if (scheduledDateTime!.isBefore(DateTime.now())) {
                      return "Input a time in the future";
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: pickDateAndTime,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: insertReminder,
                  child: (widget.reminder != null)
                      ? const Text("Edit Reminder")
                      : const Text("Create Reminder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
