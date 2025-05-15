import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("             "),
                Text(
                  "Live Chat",
                  style: boldTextStyle(),
                ),
                Text(
                  "Done",
                  style: boldTextStyle(color: kPrimary),
                ).onTap(() {
                  finish(context);
                }),
              ],
            ).paddingSymmetric(horizontal: 10),
            10.height,
            Expanded(
              child: Tawk(
                placeholder: Loader(),
                onLinkTap: (p0) {},
                onLoad: () {
                  toast("connecting to instant doctor agent...");
                },
                directChatLink:
                    'https://tawk.to/chat/678bf9ff825083258e075072/1ihtch414',
                visitor: TawkVisitor(
                  email: userController.userId.value,
                  name: userController.fullName.value,
                  hash: userController.userId.hashCode.toString(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
