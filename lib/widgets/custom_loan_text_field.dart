import 'package:flutter/material.dart';
import 'package:flutter_mqtt_location_tracker/utils/form_validators.dart';
import 'package:flutter_mqtt_location_tracker/utils/widget_helpers.dart';
import 'package:flutter_mqtt_location_tracker/widgets/action_button.dart';
import 'package:flutter_mqtt_location_tracker/widgets/default_center_container.dart';
import 'package:flutter_mqtt_location_tracker/widgets/select_one.dart';
import 'package:flutter_mqtt_location_tracker/widgets/signature_widget.dart';

class CustomLoanTextField extends StatelessWidget {
  final TextEditingController controller;
  final double? boxWidth;
  final String fieldLabelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? fontFamily;
  final bool isReadOnly;
  final FocusNode? focusNode;
  const CustomLoanTextField(
      {super.key,
      required this.controller,
      this.boxWidth,
      required this.fieldLabelText,
      this.validator,
      this.prefixIcon,
      this.suffixIcon,
      this.hintText,
      this.fontFamily,
      this.focusNode,
      this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fieldLabelText,
          style: TextStyle(
              fontSize: 16,
              //fontWeight: FontWeight.bold,
              fontFamily: fontFamily),
        ),
        SizedBox(
          width: boxWidth ?? 170,
          child: TextFormField(
            maxLines: 1,
            controller: controller,
            validator: validator,
            readOnly: isReadOnly,
            focusNode: focusNode,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hintText,
              //border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              prefixStyle: const TextStyle(
                decoration: TextDecoration.none,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class LoanApplicationPdfForm extends StatefulWidget {
  final bool isApplicant;
  final bool isGaurantor;
  final bool isAdmin;
  final String applicantPhoneNumber;
  const LoanApplicationPdfForm(
      {super.key,
      required this.isApplicant,
      required this.isGaurantor,
      required this.isAdmin,
      required this.applicantPhoneNumber});

  @override
  State<LoanApplicationPdfForm> createState() => LoanApplicationPdfFormState();
}

class LoanApplicationPdfFormState extends State<LoanApplicationPdfForm> {
  final _formKey = GlobalKey<FormState>();
  final nameOfApplicantController = TextEditingController();
  final idCardNumberController = TextEditingController();
  final issuedAtController = TextEditingController();
  final onTheController = TextEditingController();
  final byController = TextEditingController();
  final amountRequestedController = TextEditingController();
  final durationInMonthsController = TextEditingController();
  final amountInWordsController = TextEditingController();
  final pendingEngagementController = TextEditingController();
  final purposeOfTheAssistantController = TextEditingController();
  String? collateral;
  final mySavingsController = TextEditingController();
  final myNjangiController = TextEditingController();
  final otherCollateralsController = TextEditingController();
  final quarterController = TextEditingController();
  final telController = TextEditingController();
  final emailController = TextEditingController();
  final applicantsSignatureController = TextEditingController();
  final dateController = TextEditingController();

  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  final iTheUndersignerController = TextEditingController();
  final withIdCardNoController = TextEditingController();
  final issuedOnController = TextEditingController();
  final byUderDesignedController = TextEditingController();
  final hereByEngageMyselfAsSuretyToTheSumOfController =
      TextEditingController();
  final requestedByController = TextEditingController();
  final amountInWordsDesignedController = TextEditingController();
  final pendingEngagementDesignedController = TextEditingController();
  final suretyDateController = TextEditingController();

  final amountApprovedController = TextEditingController();
  final aprovedPaybackDurationInMonthsController = TextEditingController();
  final interestRateController = TextEditingController();
  final amountInWordsApprovedController = TextEditingController();
  final approvalNotesController = TextEditingController();

  final presidentSignatureDateController = TextEditingController();
  final loanOfficerSignatureDateController = TextEditingController();
  final treasurerSignatureDateController = TextEditingController();
  final memberSignatureDateController = TextEditingController();
  String? loanDecition;
  @override
  void initState() {
    telController.text = widget.applicantPhoneNumber;
    //applicationDateFocusNode.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const currencyPrefix = Text(
      'XAF ',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Fill your loan Application',
          textAlign: TextAlign.center,
        ),
      ),
      body: Form(
        key: _formKey,
        child: DefaultCenterContainer(isColumn: false, children: [
          Wrap(children: [
            CustomLoanTextField(
                controller: nameOfApplicantController,
                validator: validateName,
                //isReadOnly: true,
                fieldLabelText: 'Name of Applicant'),
            CustomLoanTextField(
              controller: idCardNumberController,
              fieldLabelText: 'Id Card Number',
              validator: validateIDCard,
            ),
            CustomLoanTextField(
                validator: (val) {
                  return validateStringLength(val, minLength: 4);
                },
                controller: issuedAtController,
                fieldLabelText: 'Issued At'),
            chooseDateField(
                onTheController,
                'On the',
                DateTime.now().add(const Duration(days: -30)),
                DateTime.now().add(const Duration(days: -10 * 365)),
                DateTime.now().add(const Duration(days: -30))),
            CustomLoanTextField(
              controller: byController,
              fieldLabelText: 'By',
              validator: (val) {
                return validateStringLength(val, minLength: 4);
              },
            ),
            CustomLoanTextField(
              controller: amountRequestedController,
              fieldLabelText: 'Am applying for a loan of',
              validator: validateAmount,
              prefixIcon: const Padding(
                  padding: EdgeInsets.all(10), child: currencyPrefix),
            ),
            TextFormField(
              maxLines: 2,
              controller: amountInWordsController,
              validator: validateAmountInWords,
              decoration: const InputDecoration(
                hintText: 'Amount in Words',
                //border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                prefixIcon: currencyPrefix,

                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                prefixStyle: TextStyle(
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            CustomLoanTextField(
              controller: durationInMonthsController,
              fieldLabelText: 'With Payback duration of',
              validator: validateMonth,
              boxWidth: 100,
              suffixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: formTextPrefix('Months.')),
            ),
          ]),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: containerDecoration.copyWith(
                color: Colors.white, border: Border.all(color: Colors.white)),
            child: TextFormField(
              maxLines: 3,
              controller: purposeOfTheAssistantController,
              validator: (value) {
                value = (value ?? '').trim();
                if (value.isEmpty) {
                  return 'Required';
                }
                if (value.length < 20 || value.split(' ').length < 4) {
                  return 'Too Short';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'What is the Purpose of Loan',
                //border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                //border: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration:
                containerDecoration.copyWith(color: Colors.grey.shade100),
            child: TextFormField(
              maxLines: 3,
              readOnly: !widget.isAdmin,
              controller: pendingEngagementController,
              validator: (value) {
                value = (value ?? '').trim();
                if (value.isEmpty) {
                  return 'Required';
                }
                if (value.length < 20 || value.split(' ').length < 4) {
                  return 'Too Short';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Any Pending Engagement (only execs can update)',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collateral Security.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Are you using your Njangi or Shares or both',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SelectOneOf(
                      strings: 'Shares and Njangi, Shares, Njangi',
                      sep: ', ',
                      selectedValue: collateral,
                      onObjectSelected: (str) {
                        collateral = str;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: containerDecoration.copyWith(
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        maxLines: 3,
                        controller: otherCollateralsController,
                        decoration: const InputDecoration(
                          hintText: 'Other Collateral Security',
                          //border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          //border: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address and Contact Information.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Provide your city, State and Country',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      children: [
                        CustomLoanTextField(
                          controller: quarterController,
                          fieldLabelText: 'Home(Quarter)',
                          validator: addressValidator,
                        ),
                        CustomLoanTextField(
                          controller: cityController,
                          fieldLabelText: 'City',
                          validator: addressValidator,
                        ),
                        CustomLoanTextField(
                          controller: stateController,
                          fieldLabelText: 'State or Region',
                          validator: addressValidator,
                        ),
                        CustomLoanTextField(
                          controller: countryController,
                          fieldLabelText: 'Country',
                          validator: addressValidator,
                        ),
                        CustomLoanTextField(
                          controller: emailController,
                          fieldLabelText: 'email',
                          validator: validateEmail,
                        ),
                        CustomLoanTextField(
                          boxWidth: 140,
                          controller: telController,
                          fieldLabelText: 'Phone Number',
                          isReadOnly: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Container(
              constraints: mobileScreenBox.copyWith(maxWidth: 310),
              child: SignatureWidget(
                  borderColor: Colors.grey,
                  onPressed: (pngBytes) async {},
                  onSignatureCleared: () async {}),
            ),
          ),
          Center(
            child: chooseDateField(
                dateController,
                'Application Date',
                DateTime.now(),
                DateTime.now(),
                DateTime.now().add(const Duration(days: 1))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'SURETY.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'To be filled and Signed by the surety (Suretee) for this loan',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      children: [
                        CustomLoanTextField(
                          controller: iTheUndersignerController,
                          fieldLabelText: 'I the underdesigned',
                          validator: validateName,
                        ),
                        CustomLoanTextField(
                          controller: cityController,
                          fieldLabelText: 'with ID card number',
                          validator: validateIDCard,
                        ),
                        chooseDateField(
                            issuedOnController,
                            'Issued On',
                            DateTime.now().add(const Duration(days: -3)),
                            DateTime.now().add(const Duration(days: -365 * 10)),
                            DateTime.now().add(const Duration(days: -1))),
                        CustomLoanTextField(
                          controller: byUderDesignedController,
                          fieldLabelText: 'by',
                          validator: addressValidator,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text(
                            'Here by engage myself as surety to the ',
                            style: TextStyle(
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                                fontFamily: 'Arial'),
                          ),
                        ),
                        CustomLoanTextField(
                          controller:
                              hereByEngageMyselfAsSuretyToTheSumOfController,
                          fieldLabelText: 'sum of',
                        ),
                        CustomLoanTextField(
                          controller: nameOfApplicantController,
                          fieldLabelText: 'requested by',
                          isReadOnly: true,
                        ),
                      ],
                    ),
                    TextFormField(
                      maxLines: 2,
                      validator: validateAmountInWords,
                      controller: amountInWordsDesignedController,
                      decoration: const InputDecoration(
                        hintText: 'Amount in Words',
                        //border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        prefixIcon: currencyPrefix,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        prefixStyle: TextStyle(
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: containerDecoration.copyWith(
                          color: Colors.grey.shade100),
                      child: TextFormField(
                        maxLines: 3,
                        readOnly: !widget.isAdmin,
                        //validator: validateName,
                        controller: pendingEngagementDesignedController,
                        decoration: const InputDecoration(
                          hintText:
                              'Any Pending Engagement (only execs can update)',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Center(
                      child: Container(
                        constraints: mobileScreenBox.copyWith(maxWidth: 310),
                        child: SignatureWidget(
                            borderColor: Colors.grey,
                            onPressed: (pngBytes) async {},
                            onSignatureCleared: () async {}),
                      ),
                    ),
                    Center(
                      child: chooseDateField(
                          suretyDateController,
                          'Surety Date',
                          DateTime.now(),
                          DateTime.now(),
                          DateTime.now().add(const Duration(days: 1))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'DECISION.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SelectOneOf(
                    alignment: WrapAlignment.center,
                    strings: 'ON HOLD, APPROVED, REJECTED',
                    sep: ', ',
                    selectedValue: loanDecition,
                    onObjectSelected: (str) {
                      loanDecition = str;
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'To be filled and Signed by Executives',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    children: [
                      CustomLoanTextField(
                        controller: amountApprovedController,
                        validator: validateAmount,
                        fieldLabelText: 'Approved Amount',
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(10), child: currencyPrefix),
                      ),
                      TextFormField(
                        maxLines: 2,
                        controller: amountInWordsApprovedController,
                        validator: validateAmountInWords,
                        decoration: const InputDecoration(
                          hintText: 'Approved Amount in Words',
                          //border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          prefixIcon: currencyPrefix,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          prefixStyle: TextStyle(
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      CustomLoanTextField(
                        controller: aprovedPaybackDurationInMonthsController,
                        fieldLabelText: 'With Payback duration of',
                        boxWidth: 100,
                        validator: validateMonth,
                        suffixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: formTextPrefix('Months.')),
                      ),
                      CustomLoanTextField(
                        controller: interestRateController,
                        fieldLabelText: 'Interest Rate',
                        boxWidth: 100,
                        validator: (value) {
                          return validateMonth(value,
                              minValue: 1, maxValue: 10);
                        },
                        suffixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: formTextPrefix('%')),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: containerDecoration.copyWith(
                        color: Colors.grey.shade100),
                    child: TextFormField(
                      maxLines: 3,
                      readOnly: !widget.isAdmin,
                      controller: approvalNotesController,
                      decoration: const InputDecoration(
                        hintText: 'Additional Notes',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildSignerWidget(suretyDateController, 'Date', 'President'),
                  const SizedBox(
                    height: 16,
                  ),
                  buildSignerWidget(loanOfficerSignatureDateController, 'Date',
                      'Loan Officer'),
                  const SizedBox(
                    height: 16,
                  ),
                  buildSignerWidget(
                      treasurerSignatureDateController, 'Date', 'Treasurer'),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ActionButton(
              text: 'Submit',
              color: Colors.blue,
              radius: 5,
              maxWidth: mobileScreenBox.maxWidth,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  print('Form is validated');
                } else {
                  print('invalid form');
                }
              })
        ]),
      ),
    );
  }

  String? addressValidator(String? val) {
    val = (val ?? '').trim();
    if (val.isEmpty) {
      return 'required';
    }
    if (val.length < 3) {
      return 'Short';
    }
    return null;
  }

  Widget formTextPrefix(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSignerWidget(TextEditingController signatureDateController,
      String dateLabel, String? signerRule) {
    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: mobileScreenBox.copyWith(maxWidth: 310),
                child: SignatureWidget(
                    signerRole: signerRule,
                    //borderColor: Colors.grey,
                    borderColor: Colors.transparent,
                    onPressed: (pngBytes) async {},
                    onSignatureCleared: () async {}),
              ),
              chooseDateField(
                  signatureDateController,
                  dateLabel,
                  DateTime.now(),
                  DateTime.now(),
                  DateTime.now().add(const Duration(days: 1))),
            ],
          ),
        ),
      ),
    );
  }

  Widget chooseDateField(
      TextEditingController controller,
      String fieldLabelText,
      DateTime initialDate,
      DateTime firstDate,
      DateTime lastDate) {
    return CustomLoanTextField(
      controller: controller,
      fieldLabelText: fieldLabelText,
      validator: validateDate,
      suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_month,
            color: Colors.blue,
          ),
          onPressed: () async {
            final date = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate);
            if (date != null) {
              controller.text = date.toIso8601String().split('T')[0];
            }
          }),
    );
  }
}
