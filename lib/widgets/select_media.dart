import 'package:flutter_mqtt_location_tracker/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';

class SelectMedia extends StatelessWidget {
  final double width;
  final double height;
  final String cameraLabel;
  final String galleryLabel;
  final Function() onCameraPressed;
  final Function() onGalleryPressed;
  final double? radius;
  final double? borderWidth;
  final double? padding;
  final Widget? cameraIcon;
  final Widget? galleryIcon;
  final Color? borderColor;
  final Color? backgroundColor;
  // final Color? backgroundColor;
  const SelectMedia(
      {super.key,
      required this.height,
      required this.width,
      required this.cameraLabel,
      required this.galleryLabel,
      required this.onCameraPressed,
      required this.onGalleryPressed,
      this.radius,
      this.borderWidth,
      this.padding,
      this.cameraIcon,
      this.galleryIcon,
      this.borderColor,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              border: Border.all(
                  color: borderColor ?? Colors.black, width: borderWidth ?? 2),
              borderRadius: BorderRadius.circular(radius ?? 10),
              color: Colors.grey.shade300),
        ),
        Positioned(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding ?? 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CustomIconButton(
                      color: Colors.white,
                      borderColor: borderColor ?? Colors.black54,
                      onPressed: onCameraPressed,
                      icon: cameraIcon ?? const Icon(Icons.camera_alt)),
                  Text(cameraLabel),
                ],
              ),
              Column(
                children: [
                  CustomIconButton(
                      color: Colors.white,
                      borderColor: borderColor ?? Colors.black54,
                      onPressed: onGalleryPressed,
                      icon: galleryIcon ?? const Icon(Icons.image)),
                  Text(galleryLabel)
                ],
              )
            ],
          ),
        ))
      ],
    );
  }
}
