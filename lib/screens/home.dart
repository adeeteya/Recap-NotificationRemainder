import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:recap/controllers/reminder_controller.dart';
import 'package:recap/controllers/settings_controller.dart';
import 'package:recap/screens/add_reminder.dart';
import 'package:recap/screens/settings_screen.dart';
import 'package:recap/widgets/reminder_tile.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
    showHintDialog();
  }

  Future showHintDialog() async {
    Future.delayed(const Duration(seconds: 2), () async {
      if (ref.read(settingsProvider).showInitialHint) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hints"),
            content: const Text(
              "• Create a reminder by clicking on the add button on the bottom right\n• Slide a reminder tile left or right to view more options\n• You could edit, repeat or delete a notification\n• If Notifications don't appear then try granting permissions from the settings app",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setInitialHint(false)
                      .then((_) => Navigator.pop(context));
                },
                child: const Text("Don't show again"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderList = ref.watch(reminderListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Reminders"),
        actions: [
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Reminder",
        onPressed: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: reminderList.when(
        error: (_, __) => const Center(child: Text("Some Error Occurred")),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        data: (data) => (data.isEmpty)
            ? Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Lottie.asset("assets/lottie/empty_notification.json"),
                    const SizedBox(height: 10),
                    Text(
                      "No Reminders Remaining",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) =>
                    ReminderTile(reminder: data[index]),
              ),
      ),
    );
  }
}
