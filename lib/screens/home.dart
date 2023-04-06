import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/controllers/remainder_controller.dart';
import 'package:recap/controllers/settings_controller.dart';
import 'package:recap/screens/alert_form.dart';
import 'package:recap/screens/settings_screen.dart';
import 'package:recap/widgets/remainder_tile.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

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
              "• Create a remainder by clicking on the add button on the bottom right\n• Slide a remainder tile left or right to view more options\n• You could edit, repeat or delete a notification\n• If Notifications don't appear then try granting permissions from the settings app",
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
    final remainderList = ref.watch(remainderListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Alerts"),
        actions: [
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, animation2) =>
                      SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: const SettingsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Remainder",
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, animation2) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: const AlertFormScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: (remainderList.isEmpty)
          ? const Center(child: Text("No Remainders added yet"))
          : ListView.builder(
              itemCount: remainderList.length,
              itemBuilder: (context, index) =>
                  RemainderTile(remainder: remainderList[index]),
            ),
    );
  }
}
