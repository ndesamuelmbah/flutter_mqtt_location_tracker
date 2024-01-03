import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseAuth firebaseAuthInst = FirebaseAuth.instance;
  final FirebaseMessaging firebaseMessaginInst = FirebaseMessaging.instance;
  final FirebaseFirestore firestoreDatabaseInst = FirebaseFirestore.instance;
  final FirebaseDynamicLinks dynamicLinksInst = FirebaseDynamicLinks.instance;

  static const androidAppId = 'com.peervendors.villagecredit';
  static const iosBundleId = 'com.peervendors.villagecredit';

  Future<String> createDynamicLink(String pathOfUrl,
      {bool short = true}) async {
    final actualUrl = 'https://www.dukafoods.com/$pathOfUrl';
    final readableUrl = Uri.parse(actualUrl);
    final actualUrlEncoded = Uri.encodeComponent(actualUrl);
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://dukafoods.page.link',
      longDynamicLink: Uri.parse(
        'https://dukafoods.page.link/?apn=$androidAppId&ibi=$iosBundleId&link=$actualUrlEncoded',
      ),
      link: readableUrl,
      androidParameters: const AndroidParameters(
        packageName: androidAppId,
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: iosBundleId,
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await dynamicLinksInst.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinksInst.buildLink(parameters);
    }
    return url.toString();
  }
}
