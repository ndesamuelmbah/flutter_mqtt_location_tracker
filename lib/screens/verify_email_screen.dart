import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen_with_bg.dart';
import 'package:flutter_mqtt_location_tracker/services/auth_service.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/firebase_auth/firebase_auth_bloc.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/pending_authentications.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_card.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String emailAddress;
  final String passwordHash;

  final String passwordString;
  final int timeStamp;
  final bool emailAndPasswordAccountHasBeenCreated;

  const VerifyEmailScreen(
      {super.key,
      required this.emailAddress,
      required this.passwordHash,
      required this.passwordString,
      required this.timeStamp,
      required this.emailAndPasswordAccountHasBeenCreated});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isLoading = false;
  bool hasVerifiedEmail = false;
  String? warningMessage;
  String? warningSubmessage;
  final logger = Logger('verifyEmailScreen');
  late final String emailLink;
  late FirebaseAuthUser user;

  final generalBox = GetIt.I<GeneralBox>();
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    user = getFirebaseAuthUser(context);
    emailLink =
        '${ApiRequest.baseUrl}notify_email_verification/${user.uid}/${widget.timeStamp}';
    sendVerificationEmail().then((value) => null);

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        if (user.emailVerified && user.email == widget.emailAddress) {
          hasVerifiedEmail = true;
          setState(() {});
        }
      }
    });
    super.initState();
  }

  Future sendVerificationEmail() async {
    try {
      print('startinf Email sent to user');
      await _auth.sendSignInLinkToEmail(
          email: widget.emailAddress,
          actionCodeSettings:
              ActionCodeSettings(url: emailLink, handleCodeInApp: true));
      print('Email sent to user');
      await FirestoreDB.pendingAuthenticationsRef
          .doc(widget.timeStamp.toString())
          .set({
        'timeStamp': widget.timeStamp,
        'uid': user.uid,
        'isSignedIn': false
      });
      print('Email sent to firestore');
    } catch (e, stackTrace) {
      print('Email sent to error');
      print(e);
      print(stackTrace);
      logger.severe(e, stackTrace);
      if (e is FirebaseAuthException) {
        print(e.code);
        print(e.message);
        if (e.code.contains('invalid-email')) {
          warningMessage = 'Email Invalid Email Provided';
          warningSubmessage =
              'The email address ${widget.emailAddress} is not a valid email address. Please provide a different one.';
        } else if (e.code.contains('email-already-in-use')) {
          warningMessage = 'Email Already Used by Different User';
          warningSubmessage =
              'The email you entered has been used by a different user. Please Enter another Email Address';
        }
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        centerTitle: true,
      ),
      body: DefaultCenterContainer(
        children: [
          if (warningMessage == null) ...[
            WarningWidget(
              warningMessage:
                  'This screen will automatically close when verification is completed.',
              tileColor: Colors.blue.shade200,
              onTap: () {},
            ),
          ],
          if (hasVerifiedEmail || warningMessage != null) ...[
            const SizedBox(height: 20),
            hasVerifiedEmail
                ? WarningWidget(
                    warningMessage: 'Your Email has been verified.',
                    subtitle: 'Tap this widget to Continue',
                    tileColor: Colors.green.shade200,
                  )
                : WarningWidget(
                    warningMessage: warningMessage!,
                    subtitle: warningSubmessage,
                    //tileColor: Colors.green.shade200,
                  )
          ],
          if (warningMessage == null)
            StreamBuilder<DocumentSnapshot<Object?>>(
                stream: FirestoreDB.pendingAuthenticationsRef
                    .doc(widget.timeStamp.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return prepareEmailCard(
                      'Sending Verification Link',
                      'We are sending you a verification link to your Email address ${widget.emailAddress}. Click on the link to verify your email',
                      leading: const CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return prepareEmailCard(
                      'Error Sending Verification Mail',
                      'We were not able to send a verification Link to ${widget.emailAddress}. Make sure the email is valid and you have a strong internet connection',
                    );
                  } else if (snapshot.hasData) {
                    final snpshotData = snapshot.data;
                    if (snpshotData == null) {
                      return const SizedBox.shrink();
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data?.isNotEmpty != true) {
                      return prepareEmailCard(
                        'Sending Verification Link',
                        'We are sending you a verification link to your Email address ${widget.emailAddress}. Click on the link to verify your email',
                        leading: const CircularProgressIndicator(),
                      );
                    }
                    final pendingAuthentication =
                        PendingAuthentications.fromJson(data!);
                    if (pendingAuthentication.isSignedIn) {
                      navigateToNextPage().then((value) {
                        if (mounted) {
                          print('Navigated to a new page');
                        }
                      });
                      return prepareEmailCard(
                        'You have successfully Signed In.',
                        'Please wait while we complete setting up your account.',
                        leading: const CircularProgressIndicator(),
                      );
                    } else {
                      return ActionCard(
                        title: 'Verification Email Sent.',
                        subTitle:
                            'We have sent you a verification link to your Email address ${widget.emailAddress}. Tap Here to open your email box. Once opened, click on the link to get verified.',
                        onPressed: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: widget.emailAddress,
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          } else {
                            throw 'Could not launch email';
                          }
                        },
                      );

                      // return prepareEmailCard(
                      //   'Verification Email Sent.',
                      //   'We have sent you a verification link to your Email address ${widget.emailAddress}. Tap Here to open your email box. This screen will automatically close when verification is completed',
                      //   onTap: () async {

                      //     final Uri emailLaunchUri = Uri(
                      //       scheme: 'mailto',
                      //       path: widget.emailAddress,
                      //     );
                      //     if (await canLaunchUrl(emailLaunchUri)) {
                      //       await launchUrl(emailLaunchUri);
                      //     } else {
                      //       throw 'Could not launch email';
                      //     }
                      //   },
                      //   leading: const Icon(
                      //     Icons.email_outlined,
                      //     size: 30,
                      //     color: Colors.blue,
                      //   ),
                      // );
                    }
                  } else {
                    return const LoadingProgressIndicator();
                  }
                }),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(
                  text: 'Cancel Verification',
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  maxWidth: 150,
                  radius: 5,
                  flex: 1,
                  onPressed: () async {
                    Navigator.of(context).pop();
                  }),
              const SizedBox(width: 30),
              ActionButton(
                text: 'Resend Email',
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                radius: 5,
                maxWidth: 150,
                flex: 1,
                onPressed: () async {
                  isLoading = true;
                  setState(() {});
                  await sendVerificationEmail();
                  isLoading = false;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget prepareEmailCard(String title, String subtitle,
      {void Function()? onTap, Widget? leading}) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          onTap: onTap,
          leading: leading,
          minLeadingWidth: 16,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  navigateToNextPage() async {
    final currentUser = _auth.currentUser!;
    Map<String, dynamic> updates = {
      'email': widget.emailAddress,
      'passwordHash': widget.passwordHash,
      'emailVerified': true
    };
    if (!widget.emailAndPasswordAccountHasBeenCreated) {
      try {
        Map<String, dynamic> currentUserJson =
            FirebaseAuthUser.fromCurrentUser(currentUser).toJson();
        currentUserJson.addAll(updates);
        await FirestoreDB.updateUser(currentUserJson, currentUser.uid);
        await currentUser.updateEmail(widget.emailAddress);
        await currentUser.updatePassword(widget.passwordString);
      } catch (e, stackTrace) {
        logger.severe(e, stackTrace);
        await ApiRequest.genericGet(
            "link_user_with_password/${user.uid}/${widget.emailAddress}/${widget.passwordString}/${widget.timeStamp}");
      }
    }

    await AuthService.completeSignInWithEmailAndPasswordCleanUp(
        currentUser, widget.emailAddress, widget.passwordString);
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }
}
