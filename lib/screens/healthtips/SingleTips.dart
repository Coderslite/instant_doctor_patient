import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/styleText.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';
import '../../component/eachTips.dart';
import '../../services/HealthTipService.dart';

class SingleTipScreen extends StatefulWidget {
  final HealthTipModel healthTip;
  const SingleTipScreen({
    super.key,
    required this.healthTip,
  });

  @override
  State<SingleTipScreen> createState() => _SingleTipScreenState();
}

class _SingleTipScreenState extends State<SingleTipScreen> {
  bool isLiked = false;
  final healthTipService = Get.find<HealthTipService>();

  handleUpdateLike() async {
    isLiked = !isLiked;
    healthTipService.likeTip(healthTipId: widget.healthTip.id.validate());
    setState(() {});
  }

  handleGetLiked() async {
    isLiked = await healthTipService.isLiked(
        healthTipId: widget.healthTip.id.validate());
    setState(() {});
  }

  handleViewTip() {
    healthTipService.viewHealthTip(healthTipId: widget.healthTip.id.validate());
  }

  @override
  void initState() {
    handleGetLiked();
    handleViewTip();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: MediaQuery.of(context).size.height / 2.2,
            toolbarHeight: 60,
            forceMaterialTransparency: true,
            systemOverlayStyle:
                SystemUiOverlayStyle(statusBarColor: transparentColor),
            actions: [
              Card(
                color: context.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 30,
                    color: kPrimary,
                  ),
                ),
              ).onTap(() {
                handleUpdateLike();
              }),
              10.height,
              const SizedBox(width: 10),
              Card(
                color: context.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Ionicons.share_social,
                    size: 30,
                    color: kPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            title: CachedNetworkImage(
              imageUrl: widget.healthTip.image.validate(),
              fit: BoxFit.cover,
            ),
            leading: backButton(context),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.healthTip.image.validate(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 10),
                Text(
                  widget.healthTip.title.validate(),
                  style: boldTextStyle(size: 20),
                ),
                const SizedBox(height: 10),
                StyledText(widget.healthTip.description.validate()),
                const SizedBox(height: 20),
                Text(
                  "Related Tips",
                  style: boldTextStyle(size: 20),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: FutureBuilder<List<HealthTipModel>>(
                future: healthTipService.getRelatedHealthTips(
                  categoryId: widget.healthTip.categoryId.validate(),
                  healthTipId: widget.healthTip.id.validate(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return eachTips(context, snapshot.data![index]);
                        },
                        childCount: snapshot.data!.length,
                      ),
                    );
                  }
                  return SliverToBoxAdapter(child: Loader());
                }),
          ),
        ],
      ),
    );
  }
}
