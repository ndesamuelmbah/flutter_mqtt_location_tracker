import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/cloud_firestore/firestore_db.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/screens/enter_user_name.dart';
import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
// import 'package:flutter_mqtt_location_tracker/screens/home_screen.dart';
// import 'package:flutter_mqtt_location_tracker/screens/home_screen_with_bg.dart';
import 'package:flutter_mqtt_location_tracker/services/auth_service.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/firebase_auth_code_messages.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/toast_messages.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/custom_richtext_link.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/warning_widget.dart';
import 'package:get_it/get_it.dart';

class SignInWithEmailAndPasswordForm extends StatefulWidget {
  const SignInWithEmailAndPasswordForm(
      {super.key,
      required this.onWantToSignup,
      required this.onForgotPassword,
      required this.onGoBack,
      this.autoSignIn = false});
  final VoidCallback onWantToSignup;
  final VoidCallback onGoBack;
  final VoidCallback onForgotPassword;
  final bool autoSignIn;

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInWithEmailAndPasswordForm> {
//Add a global key to the form key to the form widget
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage, errorTitle;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final generalBox = GetIt.I<GeneralBox>();

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((value) async {
      await generalBox.put(Keys.firebaseMessagingToken, value);
    });
    if (widget.autoSignIn) {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        _emailController.text = 'fastexpay@gmail.com';
        _passwordController.text = '24April@91';
        _signIn();
      });
    }
  }

  void _signIn() async {
    if (formKey.currentState!.validate()) {
      // Implement your signup logic here
      String email = _emailController.text;
      String password = _passwordController.text;

      setState(() {
        isLoading = true;
      });
      try {
        final cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (cred.user != null) {
          await AuthService.completeSignInWithEmailAndPasswordCleanUp(
              cred.user!, email, password);

          if (mounted) {
            final user = cred.user!;
            if (user.displayName.isNullOrWhiteSpace) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EnterUserNameScreen()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            }
          }
          Map<String, dynamic>? userMap =
              await FirestoreDB.getUserInfoByFirebaseId(cred.user!.uid, 'uid');
          final envVars = generalBox.get(Keys.envVars);
          if (userMap != null) {
            final passwordHash =
                encryptWithEncrypt(envVars.EMAIL_PASSWORD_HASH_KEY, password);
            userMap['passwordHash'] = passwordHash;
            var authUser = FirebaseAuthUser.fromJson(userMap);
            await generalBox.put(Keys.firebaseAuthUser, authUser);
            await FirestoreDB.updateUser(userMap, cred.user!.uid);
          } else {
            var authUser = FirebaseAuthUser.fromCurrentUser(cred.user!);
            authUser.passwordHash =
                encryptWithEncrypt(envVars.EMAIL_PASSWORD_HASH_KEY, password);
            Map<String, dynamic> jsonUser = authUser.toJson();

            await generalBox.put(Keys.firebaseAuthUser, authUser);
            await FirestoreDB.updateUser(jsonUser, cred.user!.uid);
          }
          if (cred.user == null) {
            errorTitle = 'No Account for this email';
            errorMessage = 'Please create an account';
          } else {
            errorTitle = 'Invalid email or password';
            errorMessage = 'Please check your email and password and try again';
          }
        } else {
          showErrorToast('Something went wrong');
        }
      } on FirebaseAuthException catch (e, s) {
        errorTitle = e.message ?? 'An Error Occurred';
        errorMessage = getFirebaseAuthCodeMessage(e.code);
        print(e.toString());
        print('');
        print(e.code);
        print('');
        print(e.message);
        print('');
        print(s.toString());
        if (e.code.contains('invalid-credential')) {
          errorMessage = 'Invalid email';
          final user =
              await FirestoreDB.getUserInfoByFirebaseId(email, 'email');
          if (user == null) {
            errorTitle = 'No Account for this email';
            errorMessage = 'Please create an account';
          } else {
            errorTitle = 'Incorrect Password for email';
            errorMessage = 'Please check your email and password and try again';
          }
        } else if (e.code.contains('user-disabled')) {
          errorMessage = 'User is disabled';
        } else if (e.code.contains('user-not-found')) {
          errorMessage = 'User not found';
        } else if (e.code.contains('wrong-password')) {
          errorMessage = 'Wrong password';
        } else if (e.code.contains('email-already-in-use')) {
          errorMessage = 'Email already in use';
        } else if (e.code.contains('weak-password')) {
          errorMessage = 'Weak password, enter a strong password';
        } else if (e.code.contains('invalid-verification-code')) {
          errorMessage = 'Invalid verification code';
        } else if (e.code.contains('invalid-phone-number')) {
          errorMessage = 'Invalid phone number';
        } else if (e.code.contains('quota-exceeded')) {
          errorMessage = 'You have attempted to sign in too many times';
        } else {
          errorMessage = 'An error occurred';
        }

        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text(errorMessage),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
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
              validator: validatePassword,
              decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Strong-Password',
                  labelText: 'Password',
                  border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            buildSubmitButton(),
            const SizedBox(height: 30.0),
            CustomRichTextLink(
              textPrefix: 'Forgot your password? ',
              linkText: 'Reset it here.',
              onTextLinkClicked: widget.onForgotPassword,
            ),
            const SizedBox(height: 10.0),
            CustomRichTextLink(
              textPrefix: 'Not having an account ',
              linkText: 'Create my account.',
              onTextLinkClicked: widget.onWantToSignup,
            ),
          ]),
        ),
      ],
    );
  }

  Widget buildSubmitButton() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: ActionButton(
              color: Colors.deepPurple.withRed(199),
              fontWeight: FontWeight.bold,
              horizontalPadding: 0,
              radius: 10,
              onPressed: () {
                widget.onGoBack();
              },
              text: 'Go back',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ActionButton(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              horizontalPadding: 0,
              radius: 10,
              backgroundColor: Colors.deepPurple.shade100,
              onPressed: _signIn,
              text: 'Sign In',
            ),
          )
        ]);
  }
}
