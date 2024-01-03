import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';

class InvestmentIdeasForm extends StatefulWidget {
  const InvestmentIdeasForm({super.key});

  @override
  InvestmentIdeasFormState createState() => InvestmentIdeasFormState();
}

class InvestmentIdeasFormState extends State<InvestmentIdeasForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool isReadOnly = false;
  bool hasSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Submit Investment Idea')),
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: containerDecoration,
                    child: TextFormField(
                      controller: _titleController,
                      readOnly: isReadOnly,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Idea Title',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8.0),
                      ),
                      validator: (value) {
                        value = (value ?? '').trim();
                        if (value.isEmpty) {
                          return 'Enter Title of Investment Idea';
                        }
                        if (value.length < 5) {
                          return 'Too Short';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: containerDecoration,
                    child: TextFormField(
                      controller: _descriptionController,
                      readOnly: isReadOnly,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 10,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Idea Description',
                        hintText:
                            'Add details like how the Idea will generate money',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8.0),
                      ),
                      validator: (value) {
                        value = (value ?? '').trim();
                        if (value.isEmpty) {
                          return 'Enter Description of Investment Idea';
                        }
                        if (value.length < 10) {
                          return 'Too Short';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (!hasSubmitted)
                    ActionButton(
                      text: 'Submit',
                      color: Colors.blue.shade900,
                      onPressed: () async {
                        final time =
                            DateTime.now().toUtc().millisecondsSinceEpoch +
                                const Duration(hours: 1).inMilliseconds;
                        if (_formKey.currentState?.validate() == true) {
                          final user = getFirebaseAuthUser(context);
                          final idea = {
                            'title': _titleController.text,
                            'description': _descriptionController.text,
                            'submittedBy': user.toJson(),
                            'submissionTime': time,
                            'ideaOwnerId': user.uid,
                            'ownerName': user.displayName,
                            'submitionDateTime':
                                DateTime.fromMillisecondsSinceEpoch(time)
                                    .toIso8601String()
                          };
                          await FirestoreDB.investmentIdeasRef
                              .doc(time.toString())
                              .set(idea, SetOptions(merge: true));
                          if (mounted) {
                            hasSubmitted = true;
                            isReadOnly = true;
                            setState(() {});
                          }
                        }
                      },
                    ),
                  if (hasSubmitted) ...[
                    ListTile(
                      tileColor: Colors.grey.shade200,
                      title: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Your Idea has been Submitted',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ),
                      subtitle: const Text('You can now close this window',
                          style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ActionButton(
                      text: 'Close',
                      color: Colors.green,
                      onPressed: () async {
                        hasSubmitted = true;
                        Navigator.pop(context);
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
