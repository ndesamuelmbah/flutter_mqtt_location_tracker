import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';

class EnterEmailToResetPassword extends StatefulWidget {
  const EnterEmailToResetPassword(
      {super.key,
      required this.onSignup,
      required this.onWantToUsePhoneNumber});
  final VoidCallback onSignup;
  final VoidCallback onWantToUsePhoneNumber;

  @override
  EnterEmailToResetPasswordState createState() =>
      EnterEmailToResetPasswordState();
}

class EnterEmailToResetPasswordState extends State<EnterEmailToResetPassword> {
  final TextEditingController _emailController = TextEditingController();

  void _signIn() {
    // Implement your signup logic here
    String email = _emailController.text;

    // Validate the form data
    if (email.isEmpty) {
      // Display an error message or handle accordingly
      print("All fields are required");
      return;
    }

    // Perform signup logic here

    // Example: Print the signup information
    print("Email: $email");

    // Clear the form fields
    _emailController.clear();

    // You can now navigate to another screen or perform further actions
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCenterContainer(
      children: [
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
        const SizedBox(height: 32.0),
        buildSubmitButton(),
        const SizedBox(height: 30.0),
        Container(
          padding: EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              text: 'Want to sign in with phone number instead? ',
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: 'Enter your phone number.',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      widget.onWantToUsePhoneNumber();
                    },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildSubmitButton() {
    Widget defaultButton = Expanded(
      flex: 4,
      child: ActionButton(
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
        horizontalPadding: 0,
        radius: 10,
        backgroundColor: Colors.deepPurple.shade100,
        onPressed: _signIn,
        text: 'Sign In',
      ),
    );
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 3,
            child: ActionButton(
              color: Colors.deepPurple.withRed(199),
              fontWeight: FontWeight.bold,
              horizontalPadding: 0,
              radius: 10,
              onPressed: () {
                widget.onSignup();
              },
              text: 'Go back',
            ),
          ),
          const SizedBox(width: 8.0),
          defaultButton
        ]);
  }
}
