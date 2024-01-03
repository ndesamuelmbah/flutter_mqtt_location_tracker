import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';
import 'package:flutter_mqtt_location_tracker/screens/phone_auth.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';

class SignInWithPhoneNumber extends StatefulWidget {
  final VoidCallback onGoBack;
  const SignInWithPhoneNumber({super.key, required this.onGoBack});

  @override
  SignInWithPhoneNumberState createState() => SignInWithPhoneNumberState();
}

class SignInWithPhoneNumberState extends State<SignInWithPhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  CountryCode _selectedCountryCode = CountryCode.fromCountryCode('US');

  void _submitPhoneNumber() {
    if (_formKey.currentState!.validate()) {
      final phone =
          _phoneNumberController.text.trim().replaceAll(RegExp(r'\s+'), '');
      if (phone.length > 7 &&
          phone.isNumericOnly &&
          RegExp(_selectedCountryCode.mobileRegex!).hasMatch(phone)) {
        final phoneNumber = '${_selectedCountryCode.dialCode}$phone';
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              StartPhoneVerification(phoneNumber: phoneNumber),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCenterContainer(
      isColumn: false,
      children: [
        Card(
          //color: Colors.blue,
          elevation: 0,
          child: ListTile(
            tileColor: Colors.grey[300],
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Welcome! ',
                style: TextStyle(fontSize: 19.0),
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(bottom: 12.0, top: 3),
              child: Text(
                'Please Enter Your phone number to Sign in or Create an Account.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 50),
              decoration: containerDecoration,
              child: CountryCodePicker(
                onChanged: (code) {
                  _selectedCountryCode = code;
                  setState(() {});
                },
                initialSelection: _selectedCountryCode.iso2CountryCode,
                showCountryOnly: true,
                favorite: const [
                  'US',
                  'CN',
                  "CA",
                  "CM",
                  "TZ",
                  'GB',
                  'CA',
                  'FR',
                  'DE'
                ],
                //countryFilter: const ['PK', 'IN'],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Container(
                decoration: containerDecoration,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Phone Number',
                        contentPadding: EdgeInsets.symmetric(horizontal: 13)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.isNumericOnly) {
                        return 'Numbers Only, no letters or spaces';
                      }
                      if (value.length < 7) {
                        return 'Number Too Short';
                      }
                      if (!RegExp(_selectedCountryCode.mobileRegex!)
                          .hasMatch(value)) {
                        return 'Invalid Phone Number for ${_selectedCountryCode.dialCode}';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        //const Spacer(),
        const SizedBox(height: 60.0),
        Row(
          children: [
            ActionButton(
              flex: 2,
              text: 'Go Back',
              fontWeight: FontWeight.bold,
              radius: 5,
              onPressed: widget.onGoBack,
              backgroundColor: Colors.white,
            ),
            ActionButton(
              flex: 6,
              text: 'Verify Phone Number',
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.deepPurple.shade100,
              radius: 5,
              onPressed: _submitPhoneNumber,
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
