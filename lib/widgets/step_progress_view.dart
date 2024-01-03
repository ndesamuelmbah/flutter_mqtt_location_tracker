import 'package:flutter/material.dart';

class StepProgressView extends StatelessWidget {
  final double width;
  final List<String> titles;
  final int curStep;
  final Color activeColor;
  final Color textColor;
  final Color inactiveColor = Colors.grey;
  final double lineWidth = 3.0;

  const StepProgressView(
      {Key? key,
      required this.curStep,
      required this.titles,
      required this.width,
      required this.activeColor,
      required this.textColor})
      : assert(width > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: Column(
          children: <Widget>[
            Row(
              children: _iconViews(),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _titleViews(),
            ),
          ],
        ));
  }

  List<Widget> _iconViews() {
    var list = <Widget>[];
    titles.asMap().forEach((i, icon) {
      var circleColor =
          (i == 0 || curStep > i + 1) ? activeColor : inactiveColor;
      var lineColor = curStep > i + 1 ? activeColor : inactiveColor;
      var iconColor = (i == 0 || curStep > i + 1) ? activeColor : inactiveColor;

      list.add(
        Container(
          width: 20.0,
          height: 20.0,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            /* color: circleColor,*/
            borderRadius: const BorderRadius.all(Radius.circular(22.0)),
            border: Border.all(
              color: circleColor,
              width: 2.0,
            ),
          ),
          child: Icon(
            Icons.circle,
            color: iconColor,
            size: 12.0,
          ),
        ),
      );

      //line between icons
      if (i != titles.length - 1) {
        list.add(Expanded(
            child: Container(
          height: lineWidth,
          color: lineColor,
        )));
      }
    });

    return list;
  }

  List<Widget> _titleViews() {
    var list = <Widget>[];
    titles.asMap().forEach((i, text) {
      list.add(Text(text, style: TextStyle(color: textColor)));
    });
    return list;
  }
}
