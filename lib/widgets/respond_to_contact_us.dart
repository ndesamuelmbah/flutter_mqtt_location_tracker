import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';
import 'package:flutter_mqtt_location_tracker/models/contact_inquiries.dart';

class ContactUsRespond extends StatefulWidget {
  final ContactInquiry inquiry;

  const ContactUsRespond({
    super.key,
    required this.inquiry,
  });

  @override
  ContactUsRespondState createState() => ContactUsRespondState();
}

class ContactUsRespondState extends State<ContactUsRespond>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    if (getFirebaseAuthUser(context).isAdmin != true &&
        widget.inquiry.hasBeenRespondedTo()) {
      showSuccessToast('Cannot Update an inquiry that has been responded to');
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 8,
        child: InkWell(
          onTap: _toggleExpansion,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getFirebaseAuthUser(context).isAdmin == true
                    ? Row(
                        children: [
                          Text(
                            widget.inquiry.userName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            widget.inquiry.phoneNumber,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      )
                    : Text(
                        getFormattedTime(widget.inquiry.timestamp),
                        style: const TextStyle(fontSize: 14),
                      ),
                const SizedBox(height: 8),
                Text(
                  widget.inquiry.contactMessage,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (widget.inquiry.response != null) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.inquiry.response!.adminName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        getFormattedTime(widget.inquiry.timestamp),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    widget.inquiry.contactMessage,
                    style:
                        TextStyle(fontSize: 16, color: Colors.green.shade900),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _isExpanded ? 100 : 0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: TextFormField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText:
                              getFirebaseAuthUser(context).isAdmin == true
                                  ? 'Response'
                                  : 'Edit your inquiry',
                          hintText: getFirebaseAuthUser(context).isAdmin == true
                              ? 'Enter your response...'
                              : 'Edit your inquiry',
                          border: const OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          value = (value ?? '').trim();
                          if (value.length < 4) {
                            return 'Write a detailed Message';
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
                  child: ActionButton(
                    text: 'Submit',
                    color: Colors.blue,
                    fontColor: Colors.black,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.blue.shade300,
                    radius: 5,
                    maxWidth: 200,
                    onPressed: () async {
                      final text = _textController.text.trim();
                      final user = getFirebaseAuthUser(context);
                      if (text.length > 3 &&
                          (user.isAdmin == true ||
                              (!(user.isAdmin == true) && text.length > 9))) {
                        if (user.isAdmin == true) {
                          await FirestoreDB.contactUsRef
                              .doc(widget.inquiry.inquiryId)
                              .set(
                            {
                              "hasResponse": true,
                              'response': {
                                'responseText': text,
                                'adminName': user.displayName,
                                'adminPhone': user.phoneNumber,
                                'timestamp':
                                    DateTime.now().millisecondsSinceEpoch,
                                'contactMessage': widget.inquiry.contactMessage
                              },
                            },
                            SetOptions(merge: true),
                          );
                        } else {
                          await FirestoreDB.contactUsRef
                              .doc(widget.inquiry.inquiryId)
                              .set(
                            {"hasResponse": false, 'contactMessage': text},
                            SetOptions(merge: true),
                          );
                        }
                        _textController.clear();
                        _toggleExpansion();
                        showSuccessToast(user.isAdmin == true
                            ? 'Response Saved'
                            : "Your Update has been saved");
                      } else {
                        showErrorToast('Message is to Short');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
