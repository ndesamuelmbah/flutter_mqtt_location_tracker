import 'package:flutter/material.dart';

class CustomWidget {
  final BuildContext context;

  CustomWidget(this.context);

  showSuccessAlertDialog(String title, String message, {Function()? callBack}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: Alignment.topRight,
                    //const FractionalOffset(0.0, 0.5),
                    end: Alignment.bottomLeft,
                    //const FractionalOffset(1.0, 0.6),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              height: MediaQuery.of(context).size.height * 0.30,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSansBold',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 7.0, bottom: 10.0),
                      height: 2.0,
                      color: Colors.blue,
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.blue,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      child: GestureDetector(
                        onTap: callBack ??
                            () {
                              Navigator.of(context).pop(true);
                            },
                        child: Container(
                          width: 100,
                          height: 40,
                          margin:
                              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.blue],
                                begin: Alignment.topRight,
                                //const FractionalOffset(0.0, 0.5),
                                end: Alignment.bottomLeft,
                                //const FractionalOffset(1.0, 0.6),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "ok".toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: "OpenSansBold",
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
    // show the dialog
  }

  TextStyle commonTextStyles(FontWeight weight, Color color, double size,
      {TextDecoration? textDecoration, double? letterSpacing, double? height}) {
    return TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: size,
        fontFamily: weight == FontWeight.bold
            ? 'Poppins-Bold'
            : weight == FontWeight.w500
                ? 'Poppins-SemiBold'
                : 'Poppins-Regular',
        decoration: textDecoration,
        letterSpacing: letterSpacing,
        height: height);
  }
}
