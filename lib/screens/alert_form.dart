import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/controllers/remainder_controller.dart';
import 'package:recap/models/remainder.dart';

class AlertFormScreen extends ConsumerStatefulWidget {
  final Remainder? remainder;
  const AlertFormScreen({
    Key? key,
    this.remainder,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends ConsumerState<AlertFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _contentTextEditingController;
  late final TextEditingController _dateTextEditingController;
  Importance selectedImportance = Importance.defaultImportance;
  bool isPersistent = false;
  DateTime? scheduledDateTime;

  @override
  void initState() {
    if (widget.remainder != null) {
      _titleTextEditingController =
          TextEditingController(text: widget.remainder!.title);
      _contentTextEditingController =
          TextEditingController(text: widget.remainder!.content);
      scheduledDateTime = widget.remainder?.scheduledDate;
      _dateTextEditingController =
          TextEditingController(text: scheduledDateTime.toString());
      selectedImportance = Importance(widget.remainder!.importanceValue);
      isPersistent = widget.remainder!.isPersistent;
    } else {
      _titleTextEditingController = TextEditingController();
      _contentTextEditingController = TextEditingController();
      _dateTextEditingController = TextEditingController();
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
        lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _dateTextEditingController.text =
            "${scheduledDateTime?.day}/${scheduledDateTime?.month}/${scheduledDateTime?.year}  ${scheduledDateTime?.hour}:${scheduledDateTime?.minute}";
      });
      return null;
    });
  }

  Future insertRemainder() async {
    if (_formKey.currentState!.validate()) {
      if (widget.remainder != null) {
        Remainder newRemainder = Remainder(
          _titleTextEditingController.text,
          _contentTextEditingController.text,
          isPersistent,
          selectedImportance.value,
          scheduledDateTime,
        );
        await ref
            .read(remainderListProvider.notifier)
            .editRemainder(widget.remainder!.id, newRemainder)
            .then((value) => Navigator.pop(context));
      } else {
        Remainder newRemainder = Remainder(
          _titleTextEditingController.text,
          _contentTextEditingController.text,
          isPersistent,
          selectedImportance.value,
          scheduledDateTime,
        );
        await ref
            .read(remainderListProvider.notifier)
            .addRemainder(newRemainder)
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
          title: (widget.remainder != null)
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
                  minLines: 2,
                  maxLines: 5,
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
                const SizedBox(height: 20),
                CheckboxListTile(
                  value: isPersistent,
                  checkColor: Colors.white,
                  activeColor: Colors.indigo,
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
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: insertRemainder,
                  child: (widget.remainder != null)
                      ? const Text("Edit Remainder")
                      : const Text("Create Remainder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
