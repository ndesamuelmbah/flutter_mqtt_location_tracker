import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/size_config.dart';
import 'package:flutter_mqtt_location_tracker/widgets/custom_widget.dart';

class PageHeader extends StatelessWidget {
  final String header;
  final String subHeader;
  final String appName;
  const PageHeader(this.header, this.subHeader, this.appName, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/banner.png"), fit: BoxFit.fill)),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20.0, bottom: 35, left: 20, right: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80,
                    width: 80,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage("assets/images/launcher_icon.png"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Text(
                      appName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  header,
                  style: CustomWidget(context).commonTextStyles(FontWeight.bold,
                      Colors.white, SizeConfig.blockSizeVertical! * 1.9),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  subHeader,
                  style: CustomWidget(context).commonTextStyles(
                      FontWeight.normal,
                      Colors.white,
                      SizeConfig.blockSizeVertical! * 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
