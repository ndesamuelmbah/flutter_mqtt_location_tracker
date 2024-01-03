import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';

class CenterMobileView extends StatelessWidget {
  final Widget child;
  final double? padding;
  const CenterMobileView({super.key, required this.child, this.padding = 8});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: mobileScreenBox,
        child: Padding(padding: EdgeInsets.all(padding ?? 8), child: child),
      ),
    );
  }
}
