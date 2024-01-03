import 'package:flutter_mqtt_location_tracker/widgets/shimmer.dart';
import 'package:flutter/material.dart';

class DefaultLoadingSchimmer extends StatelessWidget {
  final bool showRow;
  const DefaultLoadingSchimmer({Key? key, this.showRow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const material = Material(
      child: SizedBox(
        height: 38,
        width: 150,
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade100,
            highlightColor: Colors.grey.shade400,
            child: Container(
              color: Colors.grey.shade400,
              height: 200,
            ),
          ),
          if (showRow)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                        baseColor: Colors.grey.shade100,
                        highlightColor: Colors.grey.shade400,
                        child: material),
                    const SizedBox(width: 2),
                    Shimmer.fromColors(
                        baseColor: Colors.grey.shade100,
                        highlightColor: Colors.grey.shade400,
                        child: material),
                  ]),
            )
        ],
      ),
    );
  }
}

class LoadingWidgetsGridView extends StatelessWidget {
  const LoadingWidgetsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: 21,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/
              350, // choose the number of cards to fit the width
          childAspectRatio: 1.3, // set the aspect ratio of each card
        ),
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: DefaultLoadingSchimmer(),
          );
        });
  }
}

class LoadingWidgetsListView extends StatelessWidget {
  final int numberOfLoaders;
  const LoadingWidgetsListView({super.key, this.numberOfLoaders = 3});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(
          numberOfLoaders, (index) => const DefaultLoadingSchimmer()),
    );
  }
}

class LoadingWidgetsColumn extends StatelessWidget {
  final int numberOfLoaders;
  const LoadingWidgetsColumn({super.key, this.numberOfLoaders = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          numberOfLoaders, (index) => const DefaultLoadingSchimmer()),
    );
  }
}
