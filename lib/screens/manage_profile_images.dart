import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/media_utilities.dart';
import 'package:flutter_mqtt_location_tracker/widgets/attachment_bottom_sheet.dart';
import 'package:flutter_mqtt_location_tracker/widgets/center_mobile_view.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signature_widget.dart';

import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html' as html;

class ManageProfileImages extends StatefulWidget {
  const ManageProfileImages({
    Key? key,
  }) : super(key: key);

  @override
  ManageProfileImagesState createState() => ManageProfileImagesState();
}

class ManageProfileImagesState extends State<ManageProfileImages> {
  late FirebaseAuthUser user;

  @override
  void initState() {
    super.initState();
    user = getFirebaseAuthUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final userRef = FirestoreDB.customersRef.doc(user.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile Images'),
      ),
      body: CenterMobileView(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Profile Picture',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            UploadMediaItem(
              heading: 'Set Your Profile Picture',
              onImageSaved: (downloadUrl) async {
                if (downloadUrl != null) {
                  await updateUser(userRef, {'photoUrl': downloadUrl});
                }
              },
              buttonText: 'Upload Picture',
              imageUrl: user.photoUrl,
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Upload ID Card',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 8.0),
            UploadMediaItem(
              heading: 'Upload Front of ID Card',
              onImageSaved: (downloadUrl) async {
                if (downloadUrl != null) {
                  await updateUser(userRef, {'frontOfId': downloadUrl});
                }
              },
              //onImageCleared: (file) => _handleIdCardSaved(file, _idCardBack),
              imageUrl: user.frontOfId,
              buttonText: 'Front of ID',
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 8.0),
            UploadMediaItem(
              heading: 'Upload Back of ID Card',
              onImageSaved: (downloadUrl) async {
                if (downloadUrl != null) {
                  await updateUser(userRef, {'backOfId': downloadUrl});
                }
              },
              //onImageCleared: () => _handleIdCardSaved(_idCardFront),
              imageUrl: user.backOfId,
              buttonText: 'Back of ID',
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Save Your Signature',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You will not be able to change your signature after saving it.',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            user.signatureUrl == null
                ? SignatureWidget(
                    onSignatureCleared: () async {},
                    onPressed: (signatureBytes) async {
                      final ref = FirestoreDB.signaturesRef.child(
                          '${user.uid}${longDateTimeFormat.format(getUtcNow()).replaceAll('[, :]', '_')}.png');
                      final UploadTask uploadTask = ref.putData(signatureBytes,
                          SettableMetadata(contentType: 'image/png'));
                      final snapshot = await uploadTask;
                      final downloadUrl = await snapshot.ref.getDownloadURL();
                      await updateUser(userRef, {'signatureUrl': downloadUrl});
                    },
                  )
                : Center(
                    child: SizedBox(
                      height: 120,
                      child: Image.network(
                        user.signatureUrl!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget generateImagePreview(String url) {
    return Image.network(
      url,
      fit: BoxFit.fitHeight,
    );
  }

  Future<void> updateUser(
      DocumentReference<Object?> userRef, Map<String, dynamic> updates) async {
    await userRef.update(updates);
    var updatedUserRef = await userRef.get();
    final updatedUserMap = updatedUserRef.data()! as Map<String, dynamic>;

    final firebaseAuthUser = FirebaseAuthUser.fromJson(updatedUserMap);
    user = firebaseAuthUser;

    final generalBox = GetIt.I<GeneralBox>();
    generalBox.put(Keys.firebaseAuthUser, firebaseAuthUser);
    if (mounted) {
      setState(() {});
    }
  }
}

class UploadMediaItem extends StatefulWidget {
  final String heading;
  final String buttonText;
  final String? imageUrl;
  final bool? useFilePicker;
  final List<String>? extensions;
  final Function(String?) onImageSaved;
  //final Function() onImageCleared;

  const UploadMediaItem(
      {Key? key,
      required this.heading,
      required this.buttonText,
      required this.onImageSaved,
      this.imageUrl,
      this.useFilePicker = false,
      this.extensions = const ['jpg', 'png', 'jpeg']})
      : super(key: key);

  @override
  UploadImageState createState() => UploadImageState();
}

class UploadImageState extends State<UploadMediaItem> {
  bool isLoading = false;
  dynamic imageBytes;
  String? otherFileExtention;

  Future<String?> pickAndSaveCameraImage(ImageSource source) async {
    final user = getFirebaseAuthUser(context);
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final extension =
          pickedFile.name.split('.').last.toLowerCase().split('?').first;
      if (imageExtentions.contains(extension)) {
        imageBytes = await pickedFile.readAsBytes();
      }
      final docRef = FirestoreDB.profilesAndIdsRef.child(
          '${user.uid}_${longDateTimeFormat.format(getUtcNow()).replaceAll(RegExp('[ ,:]'), '_')}.$extension');
      final url = await saveXFileImageToFirestore(pickedFile, docRef);
      return url;
    } else {
      return null;
    }
  }

  Future<String?> pickAndSaveFileFilePicker() async {
    final user = getFirebaseAuthUser(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: widget.extensions,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final extension = file.extension ??
          file.name.split('.').last.toLowerCase().split('?').first;
      if (imageExtentions.contains(extension)) {
        imageBytes = file.bytes;
      } else {
        otherFileExtention = extension;
      }
      final docRef = FirestoreDB.profilesAndIdsRef.child(
          '${user.uid}_${longDateTimeFormat.format(getUtcNow()).replaceAll(RegExp('[ ,:]'), '_')}.$extension');
      final url = await saveBytesImageToFirestore(
          file.bytes, docRef, lookupMimeType(file.name)!);
      return url;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.heading,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if ((otherFileExtention != null || imageBytes != null) &&
                widget.imageUrl != null) {
              html.window.open(widget.imageUrl!, "_blank");
            }
            if (widget.useFilePicker == true) {
              final params = {'name': 'clipboard-read'};
              final perms = await handleWebPermission(params);
              if (perms.isGranted) {
                final downloadUrl = await pickAndSaveFileFilePicker();
                if (downloadUrl != null) {
                  isLoading = true;
                  setState(() {});
                  await widget.onImageSaved(downloadUrl);

                  isLoading = false;
                  setState(() {});
                }
              }
            } else {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AttachmentBottomSheet(
                      onAttachmentSelected: (imageSource) async {
                    final params = imageSource == ImageSource.camera
                        ? {'name': 'camera'}
                        : {'name': 'clipboard-read'};
                    final perms = await handleWebPermission(params);
                    if (perms.isGranted) {
                      final downloadUrl =
                          await pickAndSaveCameraImage(imageSource);
                      if (downloadUrl != null) {
                        isLoading = true;
                        setState(() {});
                        await widget.onImageSaved(downloadUrl);

                        isLoading = false;
                        setState(() {});
                      }
                    }
                  });
                },
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: 200,
            child: isLoading
                ? const LoadingProgressIndicator()
                : Center(
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            fit: BoxFit.fitHeight,
                          )
                        : otherFileExtention != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:
                                    getDocumentPreview('.$otherFileExtention'),
                              )
                            : widget.imageUrl != null
                                ? imageExtentions.contains(
                                        getFileExtensionFromUrl(
                                            widget.imageUrl!))
                                    ? Image.network(
                                        widget.imageUrl!,
                                        fit: BoxFit.fitHeight,
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: getDocumentPreview(
                                            widget.imageUrl!),
                                      )
                                : const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No file selected',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Tap here this box to select an image or document',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                  ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
