import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/api/api_requests.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/envvars.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/screens/verify_email_screen.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/firebase_auth_code_messages.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/custom_richtext_link.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class SignUpWithEmailAndPasswordForm extends StatefulWidget {
  const SignUpWithEmailAndPasswordForm({super.key, required this.onSignin});

  @override
  SignUpFormState createState() => SignUpFormState();

  final VoidCallback onSignin;
}

class SignUpFormState extends State<SignUpWithEmailAndPasswordForm> {
  //Add a global key to the form key to the form widget
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final logger = Logger('SignUpWithEmailAndPasswordForm');
  final generalBox = GetIt.I<GeneralBox>();

  bool isLoading = false;
  String? errorMessage, errorTitle;

  void _signUp() async {
    if (formKey.currentState!.validate()) {
      // Implement your signup logic here
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      setState(() {
        isLoading = true;
      });
      try {
        final userCreds = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        int timeStampNow = DateTime.now().toUtc().millisecondsSinceEpoch;
        if (userCreds.user != null) {
          print('Got a user with non null credentials');
          try {
            final user = userCreds.user!;
            await user.updateDisplayName(name);
            await user.reload();
            await user.sendEmailVerification(
              ActionCodeSettings(
                  url:
                      '${ApiRequest.baseUrl}notify_email_verification/${user.uid}/$timeStampNow',
                  handleCodeInApp: true),
            );
            final firebaseAuthUser = FirebaseAuthUser.fromCurrentUser(user);
            await generalBox.put(Keys.firebaseAuthUser, firebaseAuthUser);
            // FirestoreDB()
            //     .createUser(firebaseAuthUser.toJson(), user.uid)
            //     .then((value) => null);
            final envVars = generalBox.get(Keys.envVars) as EnvVars;
            final passwordString = _passwordController.text.trim();
            final base64hash = encryptWithEncrypt(
                envVars.EMAIL_PASSWORD_HASH_KEY, passwordString);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VerifyEmailScreen(
                      passwordHash: base64hash,
                      emailAddress: email,
                      passwordString: passwordString,
                      timeStamp: timeStampNow,
                      emailAndPasswordAccountHasBeenCreated: true,
                    )));
          } catch (e, s) {
            print(e.toString());
            print('');
            print(s.toString());
            logger.severe(e, s);
          }
        } else {
          print('Got a user with null credentials');
        }
      } on FirebaseAuthException catch (e, stactTrace) {
        logger.severe(e, stactTrace);
        errorTitle = e.message ?? 'An Error Occurred';
        errorMessage = getFirebaseAuthCodeMessage(e.code);
        print(e.toString());
        print('');
        print(e.code);
        print('');
        print(e.message);
        print('');
        print(stactTrace.toString());
        if (e.code.contains('invalid-credential')) {
          errorMessage = 'Invalid email';
        } else if (e.code.contains('user-disabled')) {
          errorMessage = 'User is disabled';
          errorTitle = 'This account has been disables $email';
        } else if (e.code.contains('user-not-found')) {
          errorMessage = 'User not found';
        } else if (e.code.contains('wrong-password')) {
          errorMessage = 'Wrong password';
          errorTitle = 'Please enter the right password for the email $email';
        } else if (e.code.contains('email-already-in-use')) {
          errorMessage =
              'Another user already taken that email. Please use another email address or sign in';
          errorTitle = 'Email already in use';
        } else if (e.code.contains('weak-password')) {
          errorMessage =
              'Weak password, enter a strong password of 6 or more characters';
        } else if (e.code.contains('invalid-verification-code')) {
          errorMessage = 'Invalid verification code';
        } else if (e.code.contains('invalid-phone-number')) {
          errorMessage = 'Invalid phone number';
        } else if (e.code.contains('quota-exceeded')) {
          errorMessage = 'You have attempted to sign in too many times';
        } else {
          errorMessage = 'An error occurred';
        }
      } catch (e, s) {
        logger.severe(e, s);
      } finally {
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
      }
    }

    // You can now navigate to another screen or perform further actions
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCenterContainer(
      children: [
        Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (errorTitle != null) ...[
              const SizedBox(height: 16.0),
              WarningWidget(
                tileColor: Colors.red.shade100,
                warningMessage: errorTitle!,
                subtitle: errorMessage,
              )
            ],
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _nameController,
              validator: validateName,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Firstname Lastname',
                  labelText: 'Full Name',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'example@gmail.com',
                  labelText: 'Email',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              validator: validatePassword,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Strong-Password',
                  labelText: 'Password',
                  border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) {
                var validatedValue = validatePassword(value);
                value = value?.trim() ?? ' ';
                if (validatedValue == null) {
                  if (!_passwordController.text.trim().startsWith(value)) {
                    return 'Both passwords have mismatched';
                  }
                  if (value != _passwordController.text.trim()) {
                    return 'Both Passwords must Match';
                  }
                }
                return validatedValue;
              },
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Strong-Password',
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32.0),
          ]),
        ),
        isLoading
            ? const DefaultLoadingProgressIndicator()
            : ActionButton(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                horizontalPadding: 0,
                radius: 10,
                backgroundColor: const Color.fromRGBO(209, 196, 233, 1),
                onPressed: _signUp,
                text: 'Create My Account',
              ),
        const SizedBox(height: 40.0),
        CustomRichTextLink(
            onTextLinkClicked: widget.onSignin,
            textPrefix: 'Already have an account? ',
            linkText: 'Login instead.')
      ],
    );
  }
}
