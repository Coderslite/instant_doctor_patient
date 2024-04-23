import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg3.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "Policy",
                    style: boldTextStyle(),
                  ),
                  const Text("   "),
                ],
              ),
              20.height,
              Expanded(
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Card(
                        color: context.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Title",
                                style: boldTextStyle(size: 16),
                              ),
                              Text(
                                "thisjkjsdfkjddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddkjkkkkkkkkkk",
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        )),
      ),
    );
  }
}
