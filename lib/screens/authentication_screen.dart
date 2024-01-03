import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/screens/signin_with_phone_number.dart';
import 'package:flutter_mqtt_location_tracker/widgets/choose_authentication_method.dart';
import 'package:flutter_mqtt_location_tracker/widgets/enter_email_to_reset_password.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signin_form.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signup_form.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool hasChosenAuthenticationMethod = false;
  bool chosenSignup = false;
  bool wantToUsePhoneNumber = false;
  bool wantToResetPassword = false;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple.shade50,
          title: Center(child: getAppBarTitle()),
        ),
        body: authBody(screenHeight));
  }

  Widget getAppBarTitle() {
    if (!hasChosenAuthenticationMethod) {
      return const Text('Choose An authentication method');
    } else {
      return chosenSignup
          ? const Text('Creating an Account')
          : const Text('Signing in with email and password');
    }
  }

  Widget authBody(double screenHeight) {
    if (!hasChosenAuthenticationMethod) {
      return ChooseAnAuthenticationMethod(
          screenHeight: screenHeight,
          onSignup: () {
            setState(() {
              hasChosenAuthenticationMethod = true;
              chosenSignup = true;
            });
          },
          onSigninWithEmailAndPassword: () {
            setState(() {
              hasChosenAuthenticationMethod = true;
              chosenSignup = false;
            });
          },
          onSigninWithPhoneNumber: () {
            setState(() {
              hasChosenAuthenticationMethod = true;
              wantToUsePhoneNumber = true;
            });
          });
    } else if (wantToUsePhoneNumber) {
      return SignInWithPhoneNumber(
        onGoBack: () {
          setState(() {
            hasChosenAuthenticationMethod = false;
            wantToUsePhoneNumber = false;
          });
        },
      );
    } else if (wantToResetPassword) {
      return EnterEmailToResetPassword(onSignup: () {
        setState(() {
          hasChosenAuthenticationMethod = true;
          wantToResetPassword = true;
        });
      }, onWantToUsePhoneNumber: () {
        setState(() {
          hasChosenAuthenticationMethod = true;
          wantToUsePhoneNumber = true;
        });
      });
    } else {
      return chosenSignup
          ? SignUpWithEmailAndPasswordForm(onSignin: () {
              setState(() {
                hasChosenAuthenticationMethod = true;
                chosenSignup = false;
              });
            })
          : SignInWithEmailAndPasswordForm(
              autoSignIn: true,
              onGoBack: () {
                setState(() {
                  hasChosenAuthenticationMethod = false;
                });
              },
              onForgotPassword: () {
                setState(() {
                  hasChosenAuthenticationMethod = true;
                  chosenSignup = false;
                  wantToResetPassword = true;
                });
              },
              onWantToSignup: () {
                setState(() {
                  hasChosenAuthenticationMethod = true;
                  chosenSignup = true;
                });
              },
            );
    }
  }
}
