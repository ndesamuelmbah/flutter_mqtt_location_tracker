import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/models/tracking_device_media.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/play_video.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this dependency for launching URLs

class TrackingDeviceMediaList extends StatelessWidget {
  final TrackingDeviceMedias trackingDeviceMedias;
  final VoidCallback onRefreshList;

  const TrackingDeviceMediaList(
      {super.key,
      required this.trackingDeviceMedias,
      required this.onRefreshList});

  @override
  Widget build(BuildContext context) {
    return DefaultCenterContainer(
        children: trackingDeviceMedias.isEmpty
            ? <Widget>[
                const Center(
                  child: Text('No Notifications'),
                ),
                const SizedBox(height: 10),
                ActionButton(
                  text: 'Refresh List',
                  onPressed: onRefreshList,
                )
              ]
            : _buildMediaList(context));
  }

  List<Widget> _buildMediaList(BuildContext context) {
    // Sort the trackingDeviceMedias by date
    //trackingDeviceMedias.sort((a, b) => b.localTimeStamp.compareTo(a.localTimeStamp));
    List<Widget> mediaWidgetList = [];
    int numberOfWidgets = trackingDeviceMedias.length();
    int index = 0;
    List<TrackingDeviceMedia> mediaList = trackingDeviceMedias.media;
    while (index < numberOfWidgets) {
      TrackingDeviceMedia currentMedia = mediaList[index];
      bool showDate = index == 0 ||
          currentMedia.localTimeStamp.day !=
              mediaList[index - 1].localTimeStamp.day;
      if (showDate) {
        mediaWidgetList.add(
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              shortDateFormat.format(currentMedia.localTimeStamp),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      mediaWidgetList.add(
        Card(
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  currentMedia.description,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(longDateTimeFormat
                          .format(currentMedia.localTimeStamp)),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text('Tap to open the video')
                    ]),
                onTap: () async {
                  final s3Url = Uri.parse(currentMedia.s3Url);
                  if (await canLaunchUrl(s3Url)) {
                    await launchUrl(s3Url);
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PlayVideo(
                              urlOrPath: currentMedia.s3Url,
                              mqd: MediaQuery.of(context),
                            )));
                    //launch(currentMedia.s3Url);
                    // ignore: use_build_context_synchronously
                    // await showDialog(
                    //   context: context,
                    //   barrierDismissible: false,
                    //   builder: (context) {
                    //     final mediaQuery = MediaQuery.of(context);
                    //     return PopScope(
                    //       onPopInvoked: (pop) async => false,
                    //       child: AlertDialog(
                    //           title: const Text('Time goes here'),
                    //           content: PlayVideo(
                    //               urlOrPath: currentMedia.s3Url,
                    //               mqd: mediaQuery)
                    //           // actions: [
                    //           //   TextButton(
                    //           //     onPressed: () async {
                    //           //       if (await canLaunchUrl(
                    //           //           Uri.parse(uri.toString()))) {
                    //           //         generalBox.put(Keys.updatePromptTime,
                    //           //             DateTime.now().millisecondsSinceEpoch);
                    //           //         await launchUrl(Uri.parse(uri.toString()));
                    //           //         Navigator.pop(context);
                    //           //       }
                    //           //     },
                    //           //     child: const Text(
                    //           //       Strings.letsUpdate,
                    //           //     ),
                    //           //   ),
                    //           //   TextButton(
                    //           //     onPressed: () async {
                    //           //       generalBox.put(Keys.updatePromptTime,
                    //           //           DateTime.now().millisecondsSinceEpoch);
                    //           //       Navigator.pop(context);
                    //           //     },
                    //           //     child: const Text(
                    //           //       Strings.maybeLater,
                    //           //     ),
                    //           //   ),
                    //           // ],
                    //           ),
                    //     );
                    //   },
                    // );
                  }
                },
              ),
            ],
          ),
        ),
      );
      index++;
    }
    mediaWidgetList.add(ActionButton(
      text: 'Refresh List',
      onPressed: onRefreshList,
    ));
    return mediaWidgetList.reversed.toList();
  }

  // Function to launch the S3 URL in a web browser
  void launchS3Url(String s3Url) async {
    if (await canLaunch(s3Url)) {
      await launch(s3Url);
    } else {
      // Handle error, e.g., show an error message
      print('Error launching URL: $s3Url');
    }
  }
}
