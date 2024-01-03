import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';

class LoanManagementWidget extends StatefulWidget {
  final List<FirebaseAuthUser> users;

  const LoanManagementWidget({Key? key, required this.users}) : super(key: key);

  @override
  LoanManagementWidgetState createState() => LoanManagementWidgetState();
}

class LoanManagementWidgetState extends State<LoanManagementWidget> {
  Map<String, double> outstandingBalances = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Center(
                child: Text('Ngyenmuwah Village Credit'),
              ),
            ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: ListView.builder(
            itemCount: widget.users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = widget.users[index];
              final outstandingBalance = outstandingBalances[user.uid] ??
                  [10000000, 0, 200000, 0][index]; // default to 0.0

              return Column(
                children: [
                  ListTile(
                    tileColor: outstandingBalance > 1500000
                        ? Colors.pink
                        : outstandingBalance > 0
                            ? Colors.pink.shade100
                            : Colors.green.shade100,
                    title: Text(user.displayName ?? 'Unknown user'),
                    subtitle: Text(
                        'Outstanding balance: XAF ${outstandingBalance.toStringAsFixed(2)}'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final newBalance = await showDialog<double>(
                          context: context,
                          builder: (BuildContext context) {
                            final controller = TextEditingController();
                            return AlertDialog(
                              title: const Text('Update outstanding balance'),
                              content: TextField(
                                controller: controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                ElevatedButton(
                                  child: const Text('Submit'),
                                  onPressed: () => Navigator.of(context).pop(
                                      double.tryParse(controller.text) ?? 0.0),
                                ),
                              ],
                            );
                          },
                        );

                        if (newBalance != null) {
                          setState(() {
                            outstandingBalances[user.uid] = newBalance;
                          });
                        }
                      },
                      child: const Text('Update user'),
                    ),
                  ),
                  if (outstandingBalance > 0.0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'User has outstanding balance of \$${outstandingBalance.toStringAsFixed(2)}.'),
                    ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
