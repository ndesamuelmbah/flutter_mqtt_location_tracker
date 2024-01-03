import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/progress_indicator.dart';

import '../screens/verify_email_screen.dart';

class EmailAndPasswordForm extends StatefulWidget {
  final void Function() submitButtonAction;
  const EmailAndPasswordForm({super.key, required this.submitButtonAction});

  @override
  EmailAndPasswordFormState createState() => EmailAndPasswordFormState();
}

class EmailAndPasswordFormState extends State<EmailAndPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isReadOnly = false;
  bool isLoading = false;
  bool _passwordVisible = false;
  final generalBox = GetIt.I<GeneralBox>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: mobileScreenBox,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8.0),
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                    controller: _emailController,
                    readOnly: isReadOnly,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Enter your email',
                      hintText: 'eg example@gmail.com',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                    validator: validateEmail,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.none,
                    obscureText: !_passwordVisible,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Enter password (Min Length 8)',
                      hintText: 'Enter password (Min Length 8)',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(8.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          //color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          _passwordVisible = !_passwordVisible;
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {});
                        },
                      ),
                    ),
                    validator: (value) {
                      value = (value ?? '').trim();
                      if (value.isEmpty) {
                        return 'Enter A Password';
                      }
                      if (value.length < 8) {
                        return 'Too Short';
                      }
                      if (RegExp(r'\s').hasMatch(value)) {
                        return 'White space is not allowed in password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: containerDecoration,
                  child: TextFormField(
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      textCapitalization: TextCapitalization.none,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        hintText: 'Confirm password',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(8.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            //color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _passwordVisible = !_passwordVisible;
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {});
                          },
                        ),
                      ),
                      validator: (value) {
                        var validatedValue = validatePassword(value);
                        value = value?.trim() ?? ' ';
                        if (validatedValue == null) {
                          if (!_passwordController.text
                              .trim()
                              .startsWith(value)) {
                            return 'Both passwords have mismatched';
                          }
                          if (value != _passwordController.text.trim()) {
                            return 'Both Passwords must Match';
                          }
                        }
                        return validatedValue;
                      }),
                ),
                const SizedBox(height: 16.0),
                isLoading
                    ? const LoadingProgressIndicator()
                    : Center(
                        child: ActionButton(
                          text: 'Submit',
                          color: Colors.blue.shade900,
                          radius: 5,
                          maxWidth: mobileScreenBox.maxWidth,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() == true) {
                              final envVars = generalBox.get(Keys.envVars);
                              final passwordString =
                                  _passwordController.text.trim();
                              final base64hash = encryptWithEncrypt(
                                  envVars.EMAIL_PASSWORD_HASH_KEY,
                                  passwordString);
                              final newEmail =
                                  _emailController.text.trim().toLowerCase();
                              widget.submitButtonAction();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => VerifyEmailScreen(
                                        passwordHash: base64hash,
                                        emailAddress: newEmail,
                                        passwordString: passwordString,
                                        timeStamp: DateTime.now()
                                            .toUtc()
                                            .millisecondsSinceEpoch,
                                        emailAndPasswordAccountHasBeenCreated:
                                            false,
                                      )));
                            }
                          },
                        ),
                      ),
              ]),
        ),
      ),
    );
  }
}
