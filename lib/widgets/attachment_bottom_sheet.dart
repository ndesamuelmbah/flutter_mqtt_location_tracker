import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentBottomSheet extends StatelessWidget {
  final Function(ImageSource) onAttachmentSelected;

  const AttachmentBottomSheet({super.key, required this.onAttachmentSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
              child: Text(
                'You will need to grant permissions in order to proceed',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 30),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                onAttachmentSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 30),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                onAttachmentSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
