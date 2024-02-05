import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachDoctor.dart';
import '../../models/UserModel.dart';
import 'SingleDoctor.dart';

class AllDoctorsScreen extends StatefulWidget {
  const AllDoctorsScreen({super.key});

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "Doctors",
                    style: boldTextStyle(size: 20),
                  ),
                  const Icon(Icons.sort).onTap(() {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            decoration: const BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Filter Doctors",
                                  style: boldTextStyle(
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  })
                ],
              ),
              10.height,
              TextFormField(
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: context.iconColor,
                  ),
                  hintText: "Search doctor",
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
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        return ListView.builder(
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              UserModel doctor = data[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: eachDoctor(doctor: doctor).onTap(
                                  () {
                                 SingleDoctorScreen(doctor: doctor,).launch(context);
                                  },
                                ),
                              );
                            });
                      }
                      return const CircularProgressIndicator(
                        color: kPrimary,
                      ).center();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
