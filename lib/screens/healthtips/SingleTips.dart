import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SingleTipScreen extends StatefulWidget {
  final HealthTipModel tip;
  const SingleTipScreen({super.key, required this.tip});

  @override
  State<SingleTipScreen> createState() => _SingleTipScreenState();
}

class _SingleTipScreenState extends State<SingleTipScreen> {
  var controller = PanelController();

  handleViewTip() {
    var newView = widget.tip.views.validate() + 1;
    healthTipService.tipView(tipId: widget.tip.id!, newView: newView);
  }

  @override
  void initState() {
    handleViewTip();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SlidingUpPanel(
        controller: controller,
        defaultPanelState: PanelState.CLOSED,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < 0) {
              controller.open();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                // padding: const EdgeInsets.only(bottom: 60),
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.tip.image.validate(),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackButton(color: white).marginOnly(top: 10),
                    Text(
                      widget.tip.title.validate(),
                      style: boldTextStyle(
                        size: 35,
                        color: white,
                      ),
                    ).center(),
                    AvatarGlow(
                      startDelay: const Duration(milliseconds: 1000),
                      glowColor: Colors.white,
                      glowShape: BoxShape.circle,
                      animate: true,
                      curve: Curves.fastOutSlowIn,
                      child: CircleAvatar(
                        radius: 20,
                        child: Icon(
                          Icons.arrow_downward,
                          size: 20,
                        ),
                      ).onTap(() {
                        controller.open();
                      }).center(),
                    ).paddingOnly(bottom: 30),
                  ],
                ),
              )
            ],
          ),
        ),
        color: context.cardColor,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        panel: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: StreamBuilder<List<HealthTipModel>>(
                stream: healthTipService.getHealthTipsByCategory(
                    category: widget.tip.category.validate()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 2,
                          color: dimGray,
                        ).center(),
                        20.height,
                        Text(
                          widget.tip.description.validate(),
                          style: primaryTextStyle(size: 12),
                        ),
                        30.height,
                        Text(
                          "Related Articles",
                          style: boldTextStyle(size: 20, color: kPrimary),
                        ),
                        20.height,
                        for (int x = 0; x < data.length; x++)
                          Card(
                            color: context.cardColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CachedNetworkImage(
                                    imageUrl: data[x].image.validate(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                10.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "How to avoid cancer",
                                        style: boldTextStyle(
                                          size: 14,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "3hrs ago",
                                            style: secondaryTextStyle(
                                              size: 10,
                                            ),
                                          ),
                                          Text(
                                            "3hrs ago",
                                            style: secondaryTextStyle(
                                              size: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }
                  return CircularProgressIndicator().center();
                }),
          ),
        ),
      )),
    );
  }
}
