import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  final String urlOrPath;
  final MediaQueryData mqd;

  const PlayVideo({Key? key, required this.urlOrPath, required this.mqd})
      : super(key: key);

  @override
  PlayVideoState createState() => PlayVideoState();
}

class PlayVideoState extends State<PlayVideo> {
  bool isLoading = true;

  late VideoPlayerController _videoController;
  IconData childIcon = Icons.play_arrow;
  String videoDuration = '';
  String currentPosition = '';

  /*
  *  init state
  * */
  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void setLoaingStatus(bool status) {
    setState(() {
      isLoading = status;
    });
  }

  String getStringDuration(Duration? duration) {
    if (duration == null) {
      return '';
    }
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  initializeVideo() async {
    if (widget.urlOrPath.startsWith('https')) {
      _videoController = VideoPlayerController.network(widget.urlOrPath);
    } else {
      _videoController = VideoPlayerController.file(File(widget.urlOrPath));
    }
    await _videoController.initialize();

    // Use the controller to loop the video
    _videoController.setLooping(true);
    videoDuration = getStringDuration(_videoController.value.duration);
    _videoController.addListener(() {
      currentPosition = getStringDuration(_videoController.value.position);
      if (videoDuration == '' && currentPosition != '') {
        videoDuration = getStringDuration(_videoController.value.duration);
      }
      setState(() {});
    });
    setLoaingStatus(false);
  }

  double abs(double v) {
    return v > 0 ? v : v * -1;
  }

  @override
  Widget build(BuildContext context) {
    double safeHeight = widget.mqd.size.height - widget.mqd.padding.top;
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: isLoading
            ? const DefaultLoadingProgressIndicator()
            : Stack(
                children: <Widget>[
                  (widget.mqd.size.aspectRatio >
                          _videoController.value.aspectRatio)
                      ? FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Container(
                            color: Colors.black87,
                            padding: EdgeInsets.symmetric(
                                horizontal: abs(widget.mqd.size.width -
                                        _videoController.value.aspectRatio *
                                            safeHeight) /
                                    2),
                            height: safeHeight,
                            width: widget.mqd.size.width,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                VideoPlayer(_videoController),
                                ClosedCaption(
                                    text: _videoController.value.caption.text),
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: buildVideoController(context)),
                                VideoProgressIndicator(_videoController,
                                    allowScrubbing: true)
                              ],
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              VideoPlayer(_videoController),
                              ClosedCaption(
                                  text: _videoController.value.caption.text),
                              VideoProgressIndicator(_videoController,
                                  allowScrubbing: true),
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: buildVideoController(context))
                            ],
                          ),
                        ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        decoration: containerBoxDecoration(
                            color: Colors.white24,
                            borderColor: Colors.transparent),
                        child: Center(
                          child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.arrow_back, size: 50),
                              color: Colors.white,
                              onPressed: () => Navigator.of(context).pop()),
                        ),
                      )),
                ],
              ),
      ),
    );
  }

  Widget buildVideoController(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.transparent.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(childIcon, color: Colors.white, size: 35),
              onPressed: () async {
                if (_videoController.value.isPlaying) {
                  await _videoController.pause();
                  childIcon = Icons.play_circle;
                } else {
                  await _videoController.play();
                  childIcon = Icons.pause;
                }
                setState(() {});
              }),
          Text(
            "$currentPosition/$videoDuration",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          )
        ],
      ),
    );
  }
}

BoxDecoration containerBoxDecoration(
    {Color color = Colors.white,
    Color borderColor = Colors.white,
    double radius = 10,
    double borderWidth = 1}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    border: Border.all(color: borderColor, width: borderWidth),
  );
}
