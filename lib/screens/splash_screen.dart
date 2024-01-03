import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/widgets/fade_in_dart.dart';

class SplashScreen extends StatefulWidget {
  final String appName;
  const SplashScreen({Key? key, required this.appName}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dims = MediaQuery.of(context).size;
    var height = (dims.height - 200) / 3;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/splash.png",
            fit: BoxFit.cover,
            height: dims.height,
            width: dims.width,
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height,
                  width: height,
                  child: const WidgetFadeInTransition(
                    animationDurationInMilisecs: 2000,
                    canRepeat: false,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        "assets/images/launcher_icon.png",
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: WidgetFadeInTransition(
                    animationDurationInMilisecs: 1000,
                    canRepeat: false,
                    child: Container(
                      padding: const EdgeInsets.all(28.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.appName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800),
                          ),
                          const Text("Rest Assured, we will track it!",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 19,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
