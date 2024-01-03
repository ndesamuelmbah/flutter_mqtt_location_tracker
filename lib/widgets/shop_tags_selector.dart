import 'package:flutter/material.dart';

class ShopTagsSelector extends StatefulWidget {
  final String tagGroup;
  final List<String> tagsList;
  final List<String> selectedTags;
  final void Function(String) onTagSelected;
  const ShopTagsSelector(
      {Key? key,
      required this.tagGroup,
      required this.tagsList,
      required this.selectedTags,
      required this.onTagSelected})
      : super(key: key);

  @override
  State<ShopTagsSelector> createState() => _ShopTagsSelectorState();
}

class _ShopTagsSelectorState extends State<ShopTagsSelector> {
  List<String> selectedTags = [];
  @override
  void initState() {
    selectedTags = widget.selectedTags;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 9,
      //color: Colors.yellow.shade100,
      child: Padding(
        padding: const EdgeInsets.only(top: 13.0, bottom: 5),
        child: Column(children: [
          Text(
            widget.tagGroup,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 2,
            color: Colors.grey,
          ),
          Wrap(
              children: widget.tagsList
                  .map((tag) => GestureDetector(
                        onTap: () {
                          widget.onTagSelected(tag);
                          if (selectedTags.contains(tag)) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                          setState(() {});
                        },
                        child: Chip(
                          label: Text(tag),
                          backgroundColor:
                              selectedTags.contains(tag) ? Colors.green : null,
                        ),
                      ))
                  .toList())
        ]),
      ),
    );
  }
}
