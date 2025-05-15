import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/PrescriptionModel.dart';

class Prescriptiondetails extends StatefulWidget {
  final Prescriptionmodel? prescription;
  const Prescriptiondetails({super.key, this.prescription});

  @override
  State<Prescriptiondetails> createState() => _PrescriptiondetailsState();
}

class _PrescriptiondetailsState extends State<Prescriptiondetails> {
  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textController.text = widget.prescription!.prescription.validate();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Prescribed Drug",
                    style: boldTextStyle(
                      size: 16,
                    ),
                  ),
                  Text("     ")
                ],
              ),
              Expanded(
                child: Card(
                  color: context.cardColor,
                  child: AppTextField(
                    readOnly: true,
                    controller: textController,
                    textFieldType: TextFieldType.MULTILINE,
                    autoFocus: true,
                    decoration: InputDecoration(
                      hintText:
                          "Enter your drug prescription / recommendation here",
                      hintStyle: secondaryTextStyle(size: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
