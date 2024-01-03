import 'package:flutter/material.dart';

class WidgetFadeInTransition extends StatefulWidget {
  final Widget child;
  final bool canRepeat;
  final int animationDurationInMilisecs;
  const WidgetFadeInTransition(
      {Key? key,
      required this.child,
      required this.canRepeat,
      required this.animationDurationInMilisecs})
      : super(key: key);

  @override
  State<WidgetFadeInTransition> createState() => _WidgetFadeInTransitionState();
}

class _WidgetFadeInTransitionState extends State<WidgetFadeInTransition>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: widget.animationDurationInMilisecs),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.canRepeat) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
