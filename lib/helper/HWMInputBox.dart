import 'package:egp/Constants.dart';
import 'package:flutter/material.dart';

class HWMInputBox extends StatelessWidget {
  String hint;
  bool fieldValid;
  TextEditingController controller;
  String errorText;

  HWMInputBox(
      {required this.hint,
      required this.fieldValid,
      required this.controller,
      this.errorText = "Invalid Field"});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.7,
      // height: lines == 1 ? 50 : lines * 50,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      child: TextField(
        autocorrect: false,
        maxLines: 1,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: themeColor, width: 1.0)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: themeColor, width: 1.0)),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: themeColor, width: 1.0)),
            filled: true,
            fillColor: whiteColor,

            errorText: fieldValid ? null : errorText,
            hintStyle: const TextStyle(
                color: blackColor,
                fontSize: 18),
            labelText: hint),
        controller: controller,
        style: const TextStyle(color: blackColor),

      ),
    );
  }
}
