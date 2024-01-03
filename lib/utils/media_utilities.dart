import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;

Future<PermissionStatus> handleWebPermission(Map<String, String> params) async {
  if (html.window.navigator.permissions != null) {
    var permissions = await html.window.navigator.permissions!.query(params);
    if (permissions.state == 'granted' || permissions.state == 'prompt') {
      return PermissionStatus.granted;
    }
    if (permissions.state == 'denied') {
      permissions = await html.window.navigator.permissions!.request(params);
      return permissions.state == 'granted'
          ? PermissionStatus.granted
          : PermissionStatus.permanentlyDenied;
    } else {
      return PermissionStatus.permanentlyDenied;
    }
  } else {
    return Future.value(PermissionStatus.denied);
  }
}

Future<String?> saveXFileImageToFirestore(
    dynamic xFileImage, Reference storageRef) async {
  //image needs to be XFile
  if (xFileImage != null) {
    final bytes = await xFileImage.readAsBytes();
    final meme = xFileImage.mimeType ?? lookupMimeType(xFileImage.path);
    final UploadTask uploadTask = storageRef.putData(
      bytes,
      SettableMetadata(contentType: meme),
    );
    final snapshot = await uploadTask;
    final docUrl = await snapshot.ref.getDownloadURL();

    return docUrl;
  } else {
    return null;
  }
}

Future<String?> saveBytesImageToFirestore(
    Uint8List? imageBytes, Reference storageRef, String mimeContentTtpe) async {
  if (imageBytes != null) {
    final UploadTask uploadTask = storageRef.putData(
      imageBytes,
      SettableMetadata(contentType: mimeContentTtpe),
    );

    final snapshot = await uploadTask;
    final docUrl = await snapshot.ref.getDownloadURL();
    return docUrl;
  } else {
    return null;
  }
}
