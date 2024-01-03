import 'package:hive_flutter/adapters.dart';

part 'shop_tags.g.dart';

@HiveType(typeId: 14)
class ShopTag {
  ShopTag({
    required this.tagsList,
    required this.tagGroup,
  });
  @HiveField(0)
  List<String> tagsList;
  @HiveField(1)
  String tagGroup;

  factory ShopTag.fromMapEntry(MapEntry<dynamic, dynamic> map) {
    return ShopTag(
      tagGroup: map.key.toString().trim(),
      tagsList: (map.value as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}

@HiveType(typeId: 15)
class ShopTags {
  ShopTags({
    required this.tags,
  });
  @HiveField(0)
  List<ShopTag> tags;

  factory ShopTags.fromMap(Map<dynamic, dynamic> json) {
    return ShopTags(
      tags: List<ShopTag>.from(json.entries.map(
        (groupTagsPair) => ShopTag.fromMapEntry(groupTagsPair),
      )),
    );
  }
}
