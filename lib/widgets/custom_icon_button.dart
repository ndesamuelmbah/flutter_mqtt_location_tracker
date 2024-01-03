import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Function() onPressed;
  final Widget icon;
  final double? radius;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  const CustomIconButton(
      {Key? key,
      required this.onPressed,
      this.radius = 30,
      this.elevation = 0.0,
      required this.icon,
      this.color = Colors.blue,
      this.borderColor = Colors.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation!,

      shape: CircleBorder(
        side: BorderSide(color: borderColor!, width: 1),
      ),
      // RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(radius!),
      //   side: BorderSide(color: borderColor!, width: 1),
      // ),
      color: color,
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          iconSize: 30,
        ),
      ),
    );
    // return Material(
    //   elevation: elevation!,
    //   shape: CircleBorder(
    //     side: BorderSide(color: borderColor!, width: 1),
    //   ),
    //   color: color,
    //   child: SizedBox(
    //     height: 30,
    //     width: 30,
    //     child: IconButton(
    //       onPressed: onPressed,
    //       iconSize: 30,
    //       icon: icon,
    //     ),
    //   ),
    // );
    // Container(
    //     padding: const EdgeInsets.all(1.0), // borde width
    //     decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         border: Border.all(color: color!, width: 1)),
    //     child: CircleAvatar(
    //       backgroundColor: color!, //.withOpacity(0.2),
    //       child: IconButton(
    //           onPressed: onPressed,
    //           icon: Icon(
    //             Icons.call,
    //             color: color,
    //           )),
    //     ));
  }
}
