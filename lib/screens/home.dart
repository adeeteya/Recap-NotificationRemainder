import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:recap/controllers/home_controller.dart';
import 'package:recap/models/remainder.dart';
import 'package:recap/screens/alert_form.dart';
import 'package:recap/widgets/remainder_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _homeController = HomeController();
  List<Remainder> remainders = [];
  @override
  void initState() {
    _homeController.addListener(() {
      setState(() {
        remainders = _homeController.remainders;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Alerts"),
      ),
      floatingActionButton: FloatingActionButton(
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
          setState(() {
            remainders = _homeController.remainders;
          });
        },
        child: const Icon(Icons.add),
      ),
      body: (remainders.isEmpty)
          ? const Center(child: Text("No Remainders added yet"))
          : ListView.builder(
              itemCount: remainders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.5,
                      children: [
                        SlidableAction(
                          label: "Edit",
                          icon: Icons.edit,
                          backgroundColor: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, animation2) =>
                                    SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: AlertFormScreen(
                                    remainder: remainders[index],
                                  ),
                                ),
                              ),
                            );
                            setState(() {
                              remainders = _homeController.remainders;
                            });
                          },
                        ),
                        SlidableAction(
                          label: "Repeat",
                          icon: Icons.refresh,
                          backgroundColor: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            await _homeController.repeatNotification(
                                context, remainders[index]);
                          },
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.24,
                      children: [
                        SlidableAction(
                          label: "Delete",
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) {
                            _homeController.deleteRemainder(remainders[index]);
                          },
                        )
                      ],
                    ),
                    child: RemainderTile(remainder: remainders[index]),
                  ),
                );
              },
            ),
    );
  }
}
