import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen_with_bg.dart';
import 'package:get_it/get_it.dart';

import 'package:logging/logging.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/envvars.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/registered_phone_numbers.dart';
import 'package:flutter_mqtt_location_tracker/screens/enter_user_name.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/flutter_toasts.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';

class StartPhoneVerification extends StatefulWidget {
  final String phoneNumber;

  const StartPhoneVerification({super.key, required this.phoneNumber});

  @override
  StartPhoneVerificationState createState() => StartPhoneVerificationState();
}

class StartPhoneVerificationState extends State<StartPhoneVerification> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final logger = Logger('phoneAuth');
  late String _verificationId;

  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _isCodeVerified = false;

  final _auth = FirebaseAuth.instance;

  final generalBox = GetIt.I<GeneralBox>();

  Future linkUserWithEmail(User user) async {
    try {
      if (user.email == null) {
        final email = 'vc${user.uid}@vcdefault.com'.toLowerCase();
        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: email,
          password: (generalBox.get(Keys.envVars) as EnvVars).EMAIL_PASSWORD,
        );
        final newCreds = await user.linkWithCredential(emailCredential);

        var updatedUser = FirebaseAuthUser.fromCurrentUser(newCreds.user!);
        var firebaseAuthUserMap = updatedUser.toJson();
        generalBox.put(Keys.firebaseAuthUser,
            FirebaseAuthUser.fromJson(firebaseAuthUserMap));
        final userRef = FirestoreDB.customersRef.doc(user.uid);
        await userRef.set(firebaseAuthUserMap, SetOptions(merge: true));
      }
    } catch (error, stackTrace) {
      logger.severe(error, stackTrace);
    }
  }

  Future verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
    try {
      final credential = await _auth.signInWithCredential(phoneAuthCredential);
      _isCodeVerified = true;
      _isLoading = false;
      setState(() {});
      var user = _auth.currentUser;
      if (user != null && user.email.isNullOrWhiteSpace) {
        await linkUserWithEmail(user);
      } else if (credential.user?.email.isNullOrWhiteSpace == true) {
        await linkUserWithEmail(credential.user!);
      } else {
        final uid = user?.uid ?? credential.user?.uid ?? '';
        final userRef = await FirestoreDB.customersRef.doc(uid).get();
        final userMap = userRef.data()! as Map<String, dynamic>;
        generalBox.put(
            Keys.firebaseAuthUser, FirebaseAuthUser.fromJson(userMap));
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return user?.displayName.isNullOrWhiteSpace == true
                ? const EnterUserNameScreen()
                : const HomeScreen();
          },
        ),
      );
    } catch (error, stackTrace) {
      logger.severe(error, stackTrace);

      setState(() {
        _isLoading = false;
      });
      if (error is FirebaseAuthException) {
        showErrorToast('Verification Failed: ${error.message}');
      }
      // else {
      //   print('Error $error');
      //   print('StackTrace $stackTrace');
      // }
    }
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    verificationFailed(FirebaseAuthException authException) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification Failed: ${authException.message}'),
        ),
      );
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      setState(() {
        _isCodeSent = true;
        _verificationId = verificationId;
        _isLoading = false;
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
      setState(() {
        _verificationId = verificationId;
        _isLoading = false;
      });
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 119),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> _submitVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text.trim(),
      );
      verificationCompleted(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Center(child: Text('Phone Verification')),
      ),
      body: Center(
        child: Container(
          constraints: mobileScreenBox,
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 70),
                decoration: containerDecoration,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Verify your phone number (${widget.phoneNumber})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_isCodeSent)
                Container(
                  constraints: const BoxConstraints(minHeight: 70),
                  decoration: containerDecoration,
                  child: Center(
                    child: Text(
                      'We have sent a verification code to ${widget.phoneNumber}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              if (!_isCodeVerified && _isCodeSent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    Form(
                      key: _formKey,
                      child: Container(
                        decoration: containerDecoration,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Verification Code (6 digit)',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10)),
                          controller: _codeController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          //maxLength: 6,
                          //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          keyboardType: TextInputType.number,
                          validator: validatePinCode,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _isLoading
                        ? const LoadingProgressIndicator()
                        : ActionButton(
                            text: 'Submit',
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            radius: 15,
                            onPressed: _submitVerificationCode,
                          ),
                  ],
                ),
              if (!_isLoading && !_isCodeSent)
                ActionButton(
                  text: 'Request Verification Code',
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  radius: 15,
                  onPressed: _verifyPhoneNumber,
                ),
              if (_isCodeVerified)
                Text(
                  'Phone number has been verified!',
                  style:
                      TextStyle(fontSize: 18.0, color: Colors.green.shade700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
