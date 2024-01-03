import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';

class DefaultCenterContainer extends StatelessWidget {
  final List<Widget> children;
  final bool? isColumn;
  final double? hPadding;
  final double? vPadding;
  final double? maxWidth;
  final bool useListBuilder;
  const DefaultCenterContainer(
      {super.key,
      required this.children,
      this.isColumn = false,
      this.hPadding = 8.0,
      this.vPadding = 16,
      this.maxWidth = 400,
      this.useListBuilder = false});

  @override
  Widget build(BuildContext context) {
    if ((isColumn ?? false) == false) {
      return Center(
        child: Card(
          elevation: 10,
          child: Container(
            // constraints: BoxConstraints(maxWidth: maxWidth!),
            // margin:
            //     EdgeInsets.symmetric(horizontal: hPadding!, vertical: vPadding!),
            // child:
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.stretch,
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: children,
            // ),
            constraints: mobileScreenBox,
            margin: EdgeInsets.symmetric(
                horizontal: hPadding!, vertical: vPadding!),
            child: useListBuilder
                ? ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      return children[index];
                    },
                  )
                : ListView(
                    children: children,
                  ),
          ),
        ),
      );
    }
    return Center(
      child: Container(
        constraints: mobileScreenBox,
        margin:
            EdgeInsets.symmetric(horizontal: hPadding!, vertical: vPadding!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class DefaultLoadingProgressIndicator extends StatelessWidget {
  const DefaultLoadingProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
          SizedBox(height: 40.0, width: 40, child: CircularProgressIndicator()),
    );
  }
}
