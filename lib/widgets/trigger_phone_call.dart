import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, HapticFeedback;
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;
import 'package:url_launcher/url_launcher.dart';

Future<void> triggerPhoneCall(BuildContext context, String phoneNumber,
    String userName, String message) async {
  AlertDialog dailog = AlertDialog(
      insetPadding: const EdgeInsets.only(top: 5.0, bottom: 15),
      backgroundColor: const Color(0xFFE9EDF0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(13))),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(
                Icons.close,
                size: 30,
                color: Colors.red,
              ),
              onPressed: () {
                try {
                  // ignore: unnecessary_null_comparison
                  if (context.widget != null) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  // Widget is not longer mounted
                }
              }),
          ListTile(
            textColor: Colors.black,
            tileColor: Colors.green.shade200,
            title: Text(
              phoneNumber,
              style: const TextStyle(fontSize: 18),
            ),
            leading: const Icon(FontAwesomeIcons.copy),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: phoneNumber));
              Navigator.of(context).pop();
              showSuccessToast('Phone Number Copied');
              HapticFeedback.vibrate();
            },
          ),
        ],
      ),
      content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Use Dailpad or WhatsApp.')]),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.green.shade700, width: 1)),
                  child: TextButton.icon(
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      String text = "Hello $userName, $message";
                      var phone = phoneNumber
                          .replaceAll(RegExp(r'\D'), '')
                          .replaceAll(RegExp('^0+'), '');
                      final sb = StringBuffer('https://wa.me/$phone');
                      sb.write('?text=${Uri.encodeQueryComponent(text)}');
                      //launch(sb.toString());
                      // launchUrl(Uri.parse(sb.toString()));
                      html.window.open(sb.toString(), 'new tab', "_blank");
                    },
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.blue.shade700, width: 1)),
                  child: TextButton.icon(
                    icon: const Icon(
                      FontAwesomeIcons.phone,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      launch('tel:$phoneNumber');
                    },
                    label: const Text(
                      'Dailpad',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ]);
  showDialog(
      context: context, barrierDismissible: true, builder: (context) => dailog);
}
