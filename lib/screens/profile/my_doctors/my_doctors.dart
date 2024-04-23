import 'package:flutter/material.dart';
import 'package:instant_doctor/component/eachDoctor.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:nb_utils/nb_utils.dart';

class MyDoctors extends StatefulWidget {
  const MyDoctors({super.key});

  @override
  State<MyDoctors> createState() => _MyDoctorsState();
}

class _MyDoctorsState extends State<MyDoctors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.bottomCenter,
            image: AssetImage("assets/images/bg6.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "My Doctors",
                    style: boldTextStyle(color: kPrimary),
                  ),
                  const Text("   "),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int x = 0; x < 5; x++)
                      eachDoctor(doctor: UserModel(), context: context)
                          .onTap(() {
                        SingleDoctorScreen(
                          doctor: UserModel(),
                        ).launch(context);
                      })
                  ],
                ),
              ))
            ],
          ),
        )),
      ),
    );
  }
}
