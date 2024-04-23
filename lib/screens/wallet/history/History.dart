import 'package:flutter/material.dart';
import 'package:instant_doctor/component/eachTransaction.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/TransactionModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../constant/color.dart';
import '../../../services/GetUserId.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int index = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      index = _tabController.index;
    });
  }

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
                BackButton(),
                Text(
                  "History",
                  style: boldTextStyle(
                    size: 16,
                    color: kPrimary,
                  ),
                ),
                StreamBuilder<UserModel>(
                    stream: userService.getProfile(
                        userId: userController.userId.value),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return profileImage(data, 50, 50, context: context);
                      }
                      return Container();
                    }),
              ],
            ),
            20.height,
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              physics: const NeverScrollableScrollPhysics(),
              labelStyle: primaryTextStyle(),
              onTap: (value) {
                index = value;
                print(index);
                setState(() {});
              },
              tabs: [
                Tab(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                    decoration: BoxDecoration(
                        color: index == 0 ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: kPrimary,
                        )),
                    child: Text(
                      "Received",
                      style: primaryTextStyle(color: index == 0 ? white : null),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                    decoration: BoxDecoration(
                        color: index == 1 ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: kPrimary,
                        )),
                    child: Text(
                      "Sent",
                      style: primaryTextStyle(color: index == 1 ? white : null),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  ReceivedTransaction(),
                  SentTransaction(),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class ReceivedTransaction extends StatelessWidget {
  const ReceivedTransaction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: StreamBuilder<List<TransactionModel>>(
                stream: transactionService.getReceivedTransaction(
                    userId: userController.userId.value),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return ListView.builder(
                        itemCount: 10,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var transaction = data[index];
                          return eachTransaction(
                              transaction: transaction, context: context);
                        });
                  }
                  return CircularProgressIndicator().center();
                }))
      ],
    );
  }
}

class SentTransaction extends StatelessWidget {
  const SentTransaction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: StreamBuilder<List<TransactionModel>>(
                stream: transactionService.getSentTransaction(
                    userId: userController.userId.value),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return ListView.builder(
                        itemCount: 10,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var transaction = data[index];
                          return eachTransaction(
                              transaction: transaction, context: context);
                        });
                  }
                  return CircularProgressIndicator().center();
                }))
      ],
    );
  }
}
