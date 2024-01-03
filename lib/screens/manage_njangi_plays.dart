import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/play_njangi.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_loading_shimmer.dart';
import 'package:flutter_mqtt_location_tracker/widgets/play_njangi_list_item.dart';

class ManageNjangiPlays extends StatefulWidget {
  const ManageNjangiPlays({super.key});

  @override
  ManageNjangiPlaysState createState() => ManageNjangiPlaysState();
}

class ManageNjangiPlaysState extends State<ManageNjangiPlays> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = getFirebaseAuthUser(context);
    final startDate =
        DateTime.now().add(const Duration(days: 14)).toIso8601String();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Njangi History'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreDB.njangiRef
                .where('submittedByUid', isEqualTo: user.uid)
                .where('playDate', isGreaterThanOrEqualTo: startDate)
                //.orderBy('playDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidgetsListView(
                  numberOfLoaders: 2,
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Failed to fetch loan details'),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data!.docs;
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Tere are no previous loans to show'),
                  );
                }
                final prevePlays = data.map((rec) {
                  Map<String, dynamic> playMap =
                      rec.data() as Map<String, dynamic>;
                  playMap['documentId'] = rec.id;
                  return PlayNjangi.fromJson(playMap);
                }).toList();
                return ListView.builder(
                  itemCount: prevePlays.length,
                  itemBuilder: (BuildContext context, int index) {
                    final njangiPlay = prevePlays[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PlayNjangiListItem(
                        playNjangi: njangiPlay,
                        isAdmin: true,
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
