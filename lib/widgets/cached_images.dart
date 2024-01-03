// import 'dart:io';
import 'dart:math' show min;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mqtt_location_tracker/widgets/shimmer.dart'
    show Shimmer;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show CacheManager, Config;

class CacheNetworkImages extends StatelessWidget {
  final double height;
  final String imageUrl;
  final double? width;
  final double? borderRadius;
  const CacheNetworkImages(
      {Key? key,
      required this.height,
      required this.imageUrl,
      this.width,
      this.borderRadius})
      : super(key: key);

  static final mediaCacheManager = CacheManager(Config("cachedMedia",
      stalePeriod: const Duration(days: 20), maxNrOfCacheObjects: 300));
  static bool deleteObject(String obj) {
    mediaCacheManager.removeFile(obj);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final fileName = imageUrl.split('/').last;
    final Key imageKey = Key(fileName);
    double imageWidth = width ?? (height * 2 + [50, height / 2].reduce(min));
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
      child: CachedNetworkImage(
          key: imageKey,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          height: height,
          width: imageWidth,
          //maxHeightDiskCache: 300,
          cacheManager: mediaCacheManager,
          cacheKey: fileName,
          errorWidget: (context, val, err) {
            return Container(
                color: Colors.grey,
                child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 50)));
          },
          placeholder: (context, val) => Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade400,
              child: Container(
                color: Colors.grey.shade400,
              ))),
    );
  }
}


// class CustomCacheManager extends BaseCacheManager {
//   static const key = "cachedMedia";
//   CustomCacheManager() : super(key);

//   static CacheManager instance = CacheManager(
//     Config(
//       key,
//       stalePeriod: const Duration(days: 7),
//       maxNrOfCacheObjects: 20,
//       // repo: JsonCacheInfoRepository(databaseName: key),
//       // fileSystem: IOFileSystem(key),
//       // fileService: HttpFileService(),
//     ),
//   );
//   @override
//   Future<String> getFilePath(String url) {
//     return null;
//   }

//   @override
//   Future<void> dispose() {
//     // TODO: implement dispose
//     throw UnimplementedError();
//   }

//   @override
//   Future<FileInfo> downloadFile(String url,
//       {String? key, Map<String, String>? authHeaders, bool force = false}) {
//     // TODO: implement downloadFile
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> emptyCache() {
//     // TODO: implement emptyCache
//     throw UnimplementedError();
//   }

//   @override
//   Stream<FileInfo> getFile(String url,
//       {String key, Map<String, String> headers}) {
//     // TODO: implement getFile
//     throw UnimplementedError();
//   }

//   @override
//   Future<FileInfo?> getFileFromCache(String key,
//       {bool ignoreMemCache = false}) {
//     // TODO: implement getFileFromCache
//     throw UnimplementedError();
//   }

//   @override
//   Future<FileInfo?> getFileFromMemory(String key) {
//     // TODO: implement getFileFromMemory
//     throw UnimplementedError();
//   }

//   @override
//   Stream<FileResponse> getFileStream(String url,
//       {String? key, Map<String, String>? headers, bool withProgress}) {
//     // TODO: implement getFileStream
//     throw UnimplementedError();
//   }

//   @override
//   Future<File> getSingleFile(String url,
//       {String key, Map<String, String> headers}) {
//     // TODO: implement getSingleFile
//     throw UnimplementedError();
//   }

//   @override
//   Future<File> putFile(String url, Uint8List fileBytes,
//       {String? key,
//       String? eTag,
//       Duration maxAge = const Duration(days: 20),
//       String fileExtension = 'file'}) {
//     // TODO: implement putFile
//     throw UnimplementedError();
//   }

//   @override
//   Future<File> putFileStream(String url, Stream<List<int>> source,
//       {String? key,
//       String? eTag,
//       Duration maxAge = const Duration(days: 20),
//       String fileExtension = 'file'}) {
//     // TODO: implement putFileStream
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> removeFile(String key) {
//     // TODO: implement removeFile
//     throw UnimplementedError();
//   }
// }
