import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachDoctor.dart';
import '../../models/UserModel.dart';
import '../../services/DoctorService.dart';
import 'SingleDoctor.dart';

class AllDoctorsScreen extends StatefulWidget {
  const AllDoctorsScreen({super.key});

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  final doctorService = Get.find<DoctorService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Doctors",
                    style: boldTextStyle(size: 20),
                  ),
                  Container(),
                ],
              ),
              10.height,
              AppTextField(
                textFieldType: TextFieldType.NAME,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: settingsController.isDarkMode.value?white:black,
                  ),
                  hintText: "Search doctor by name or speciality",
                  hintStyle: secondaryTextStyle(),
                  border: OutlineInputBorder(
                    // borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                    stream: doctorService.getAllDocs(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text(
                          snapshot.error.toString(),
                          style: boldTextStyle(),
                        );
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        return ListView.builder(
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              UserModel doctor = data[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child:
                                    eachDoctor(doctor: doctor, context: context)
                                        .onTap(
                                  () {
                                    SingleDoctorScreen(
                                      doctor: doctor,
                                    ).launch(context);
                                  },
                                ),
                              );
                            });
                      }
                      return Loader();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
