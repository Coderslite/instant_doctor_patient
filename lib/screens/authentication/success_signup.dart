import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../home/Root.dart';

class SuccessSignUp extends StatefulWidget {
  const SuccessSignUp({
    super.key,
  });

  @override
  State<SuccessSignUp> createState() => _SuccessSignUpState();
}

class _SuccessSignUpState extends State<SuccessSignUp> {
  final _formKey = GlobalKey<FormState>();
  var isChecked = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg3.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Image.asset("assets/images/logo1.png")),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Image.asset("assets/images/success.png")),
                // 30.height,
                Text("Sign up Successful",
                    style: boldTextStyle(
                      color: kPrimary,
                      size: 20,
                    )),
                20.height,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    color: kPrimary,
                    textColor: whiteColor,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        const Root().launch(context);
                      }
                    },
                    text: "Continue",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
