import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/investment_idea.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_loading_shimmer.dart';
import 'package:flutter_mqtt_location_tracker/widgets/investment_idea_card.dart';

class ViewInvestmentIdeaScreen extends StatefulWidget {
  const ViewInvestmentIdeaScreen({Key? key}) : super(key: key);

  @override
  State<ViewInvestmentIdeaScreen> createState() =>
      ViewInvestmentIdeaScreenState();
}

class ViewInvestmentIdeaScreenState extends State<ViewInvestmentIdeaScreen> {
  TextEditingController textEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();

  Size? screenSize;

  final getIt = GetIt.I;

  final Logger logger = Logger('ViewInvestmentIdeas');

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    scrollController.animateTo(800,
        duration: const Duration(milliseconds: 900),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  onNewMessage(String message, String phoneNumber) async {
    message = message.trim();
    if (message.length > 1) {
      textEditingController.clear();
      await addStoreMessage(message, phoneNumber);
      _scrollDown();
    }
  }

  Future<bool> addStoreMessage(String message, String phoneNumber) async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      await FirestoreDB.investmentIdeasRef
          .doc('widget.chatRoomDetails.customerPhone')
          .collection('messages')
          .doc(getChatMessageId(time))
          .set({
        'message': message,
        'time': time,
        'sentBy': phoneNumber,
        'sentByAdmin': getIt<GeneralBox>().get(Keys.firebaseAuthUser).isAdmin,
        'isRead': false,
      });
      return Future.value(true);
    } catch (e, stackTrace) {
      logger.severe(e, stackTrace);
      return Future.value(false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInvestmentIdeas() {
    return FirestoreDB.investmentIdeasRef
        .orderBy('submissionTime', descending: true)
        .limit(100)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text('Respond to Chat'),
              centerTitle: true,
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 8,
            //     offset: Offset(0, 2),
            //   ),
            // ],
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  elevation: 9,
                  color: Colors.grey.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: Colors.blueAccent, width: 1.5)),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Please find below ideas that have been submitted by other registered members of our Organization. You can respond to each idea and every registered member will see your reaction to the idea.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: StreamBuilder<Object>(
                      stream: getInvestmentIdeas(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingWidgetsListView();
                        } else {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text('There are no Investment Ideas'),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  'Sorry! An error has occurred. Please Try Refreshing.'),
                            );
                          } else {
                            final investmentIdeas =
                                (snapshot.data! as QuerySnapshot)
                                    .docs
                                    .map((e) {
                                      var data =
                                          e.data()! as Map<String, dynamic>;
                                      data['documentId'] = e.id;
                                      return InvestmentIdea.fromJson(data);
                                    })
                                    .toList()
                                    .reversed
                                    .toList();
                            if (investmentIdeas.isEmpty) {
                              return const Center(
                                child: Text('There are no Investment Ideas'),
                              );
                            }
                            return ListView.builder(
                                itemCount: investmentIdeas.length,
                                padding: const EdgeInsets.all(8.0),
                                physics: const BouncingScrollPhysics(),
                                controller: scrollController,
                                itemBuilder: (context, index) {
                                  final idea = investmentIdeas[index];
                                  return InvestmentIdeaCard(
                                    investmentIdea: idea,
                                  );
                                });
                          }
                        }
                      }),
                ),
              ]),
        ),
      ),
    );
  }
}
