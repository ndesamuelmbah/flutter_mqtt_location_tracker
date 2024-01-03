import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/saved_media.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_loading_shimmer.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html' as html;

class ViewNDYMeida extends StatefulWidget {
  const ViewNDYMeida({super.key});

  @override
  State<ViewNDYMeida> createState() => ViewNDYMeidaState();
}

class ViewNDYMeidaState extends State<ViewNDYMeida> {
  SavedMediaFiles? savedMediaFiles;
  final generalBox = GetIt.I<GeneralBox>();

  @override
  void initState() {
    getPendingApplications();
    super.initState();
  }

  Future getPendingApplications() async {
    DateTime? lastTimeMediaWereFetched =
        generalBox.get(Keys.lastTimeMediaWereFetched);
    savedMediaFiles = generalBox.get(Keys.savedMediaFiles);
    if (lastTimeMediaWereFetched == null) {
      lastTimeMediaWereFetched = DateTime.now().add(const Duration(days: -31));
    } else {
      lastTimeMediaWereFetched = getUtcNow();
    }

    generalBox.put(Keys.lastTimeMediaWereFetched, lastTimeMediaWereFetched);

    final mediaRef = await FirestoreDB.mediaRef
        .where('submissionDate',
            isGreaterThan: lastTimeMediaWereFetched.toIso8601String())
        .limit(40)
        .get();
    List<SavedMedia> fetchedMediaFiles = mediaRef.docs
        .map((e) => SavedMedia.fromJson(e.data()! as Map<String, dynamic>))
        .toList();
    if (fetchedMediaFiles.isEmpty) {
      final mediaFiles = savedMediaFiles?.mediaFiles ?? [];
      savedMediaFiles = SavedMediaFiles(mediaFiles: mediaFiles);
    } else {
      if (savedMediaFiles == null) {
        savedMediaFiles = SavedMediaFiles(mediaFiles: fetchedMediaFiles);
      } else {
        savedMediaFiles!.mediaFiles.addAll(fetchedMediaFiles);
      }
    }
    savedMediaFiles!.mediaFiles
        .sort((a, b) => a.submissionDate.compareTo(b.submissionDate));

    setState(() {});
    generalBox.put(Keys.savedMediaFiles, savedMediaFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing NDY Media'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          child: savedMediaFiles == null
              ? const LoadingWidgetsListView()
              : savedMediaFiles!.mediaFiles.isEmpty
                  ? const Card(
                      elevation: 4,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        title: Text(
                          'No Media Files to View',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            'We did not find any Media files from NDY. Please Check again later.',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: savedMediaFiles!.mediaFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        final mediaFile = savedMediaFiles!.mediaFiles[index];
                        final isImage =
                            imageExtentions.contains(mediaFile.extension);
                        Widget title = Text(
                          '${mediaFile.mediaDescription} Posted by ${mediaFile.submittedByRole} on ${shortDateFormat.format(mediaFile.submissionDate)}',
                          //style: TextStyle(fon),
                        );

                        return Card(
                          child: GestureDetector(
                            onTap: () {
                              html.window.open(mediaFile.mediaUrl, "_self");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    title,
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    isImage
                                        ? Container(
                                            constraints: const BoxConstraints(
                                                maxHeight: 300),
                                            child: Center(
                                                child: Image.network(
                                              mediaFile.mediaUrl,
                                              fit: BoxFit.fitHeight,
                                            )),
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: getDocumentPreview(
                                                mediaFile.mediaUrl),
                                          ),
                                  ]),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
