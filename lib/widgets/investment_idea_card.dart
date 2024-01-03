import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/investment_idea.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';

class InvestmentIdeaCard extends StatefulWidget {
  final InvestmentIdea investmentIdea;

  const InvestmentIdeaCard({
    super.key,
    required this.investmentIdea,
  });

  @override
  InvestmentIdeaCardState createState() => InvestmentIdeaCardState();
}

class InvestmentIdeaCardState extends State<InvestmentIdeaCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool isResponding = false;
  bool isCommenting = false;
  bool showResponses = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responseController = TextEditingController();

  final generalBox = GetIt.I<GeneralBox>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _titleController.text = widget.investmentIdea.title;
    _descriptionController.text = widget.investmentIdea.description;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    if (getFirebaseAuthUser(context).uid != widget.investmentIdea.ideaOwnerId) {
      showSuccessToast('You cannot update this idea.');
      return;
    }
    if (mounted) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = generalBox.get(Keys.firebaseAuthUser);
    bool currentUserIsIdeaOwner = user.uid == widget.investmentIdea.ideaOwnerId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 8,
        child: InkWell(
          onTap: _toggleExpansion,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              //color: Colors.green[100],
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${widget.investmentIdea.ownerName}',
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        if (widget.investmentIdea.thumbsUpList
                            .contains(user.uid)) {
                          showErrorToast('You have already liked this idea');
                        } else {
                          var thumbsUpList = widget.investmentIdea.thumbsUpList;
                          thumbsUpList.add(user.uid);
                          await FirestoreDB.investmentIdeasRef
                              .doc(widget.investmentIdea.documentId)
                              .update({'thumbsUpList': thumbsUpList});
                        }
                      },
                      icon: const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.blue,
                      ),
                      label: Text(
                        widget.investmentIdea.thumbsUpList.length.toString(),
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.investmentIdea.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.investmentIdea.description,
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    getFormattedTime(widget.investmentIdea.submissionTime),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 18),
                if (!currentUserIsIdeaOwner)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: ActionButton(
                          text: 'Add A Comment',
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          horizontalPadding: 0,
                          onPressed: () {
                            var myResponse =
                                widget.investmentIdea.responses[user.uid];
                            if (myResponse != null) {
                              _responseController.text =
                                  myResponse.responseText;
                            }

                            isCommenting = !isCommenting;
                            isResponding = !isResponding;
                            setState(() {});
                          }),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AnimatedContainer(
                    color: Colors.white,
                    duration: const Duration(milliseconds: 200),
                    constraints:
                        BoxConstraints(maxHeight: _isExpanded ? 100 : 0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: TextFormField(
                        controller: _titleController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Edit your idea title',
                          hintText: 'Change the title of your idea',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 5,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          value = (value ?? '').trim();
                          if (value.length < 12) {
                            return 'Write at least 4 words';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AnimatedContainer(
                    color: Colors.white,
                    duration: const Duration(milliseconds: 200),
                    constraints:
                        BoxConstraints(maxHeight: _isExpanded ? 100 : 0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Edit your idea discription',
                          hintText: 'Change the description of your idea',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          value = (value ?? '').trim();
                          if (value.length < 16) {
                            return 'Write at least 6 words';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: _isExpanded ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: ActionButton(
                      text: 'Submit',
                      color: Colors.blue,
                      fontColor: Colors.black,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.blue.shade300,
                      radius: 5,
                      onPressed: () async {
                        final title = _titleController.text.trim();
                        final description = _descriptionController.text.trim();
                        if (title.length > 12 && description.length > 16) {
                          if (title != widget.investmentIdea.title ||
                              description !=
                                  widget.investmentIdea.description) {
                            await FirestoreDB.investmentIdeasRef
                                .doc(widget.investmentIdea.documentId)
                                .set(
                              {
                                "lastUpdated": DateTime.now()
                                    .toUtc()
                                    .add(const Duration(hours: 1))
                                    .millisecondsSinceEpoch,
                                'title': title,
                                'description': description
                              },
                              SetOptions(merge: true),
                            );
                            _toggleExpansion();
                          } else {
                            showErrorToast('No Changes Found');
                          }
                        } else {
                          showErrorToast(
                              'Description must be at least 12 and 16 characters');
                        }
                      },
                    ),
                  ),
                ),
                if (widget.investmentIdea.responses.isNotEmpty) ...[
                  Center(
                    child: ActionButton(
                      text: 'Responses to This Idea',
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      showBorder: false,
                      horizontalPadding: 0,
                      radius: 5,
                      onPressed: () {
                        showResponses = !showResponses;
                        setState(() {});
                      },
                    ),
                  ),
                  if (showResponses) ...[
                    Container(
                      color: Colors.blue.shade800,
                      height: 1,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.investmentIdea.responses.values
                          .map(
                            (e) => Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 2),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue.shade800),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade100),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          e.displayName,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          getFormattedTime(e.responseTimestamp,
                                              isShort: true),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      e.responseText,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ]
                ],
                if (isResponding) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey)),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().length < 3) {
                            return 'Please type your reaction';
                          }
                          return null;
                        },
                        maxLines: 5,
                        minLines: 3,
                        controller: _responseController,
                        decoration: const InputDecoration(
                          hintText: 'Type your reaction to this idea',
                          labelText: 'What do you like about the idea',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ActionButton(
                        text: 'Submit my Reaction',
                        color: Colors.blue.shade800,
                        //maxWidth: 250,
                        fontWeight: FontWeight.bold,
                        horizontalPadding: 0,
                        onPressed: () async {
                          if (_responseController.text.length > 2) {
                            var responses = widget.investmentIdea.responses;
                            var myResponse =
                                widget.investmentIdea.responses[user.uid];
                            Map<String, dynamic> updatedResponse = {};
                            responses.forEach((key, value) {
                              updatedResponse[key] = value.toJson();
                            });
                            final responseText =
                                _responseController.text.trim();
                            if (myResponse != null) {
                              myResponse.responseText = responseText;
                              updatedResponse[user.uid] = myResponse.toJson();
                            } else {
                              final time = DateTime.now()
                                  .toUtc()
                                  .add(const Duration(hours: 1));
                              updatedResponse[user.uid] = {
                                'responseBy': user.uid,
                                'responseTimestamp':
                                    time.millisecondsSinceEpoch,
                                'responseText': responseText,
                                'thumbsUp': 0,
                                'thumbsDown': 0,
                                'displayName': user.displayName
                              };
                            }
                            await FirestoreDB.investmentIdeasRef
                                .doc(widget.investmentIdea.documentId)
                                .update({'responses': updatedResponse});
                            isResponding = !isResponding;
                            setState(() {});
                          }
                        }),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getFormattedTime(int time, {bool isShort = false}) {
    DateTime inquiryTime = DateTime.fromMillisecondsSinceEpoch(time);
    if (isShort) {
      return DateFormat('MMM dd, yyyy, HH:mm a').format(inquiryTime);
    }
    return DateFormat('EEEE, MMM dd, yyyy, HH:mm a').format(inquiryTime);
  }
}
