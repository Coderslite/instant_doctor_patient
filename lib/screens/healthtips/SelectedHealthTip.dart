import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';
import '../../component/eachTips.dart';
import '../../services/HealthTipService.dart';

class SelectedHealthTip extends StatefulWidget {
  final HealthTipsCategoryModel healthTipsCategory;
  const SelectedHealthTip({super.key, required this.healthTipsCategory});

  @override
  State<SelectedHealthTip> createState() => _SelectedHealthTipState();
}

class _SelectedHealthTipState extends State<SelectedHealthTip> {
  TextEditingController searchController = TextEditingController();
  List<HealthTipModel> allArticles = [];
  List<HealthTipModel> filteredArticles = [];
  final healthTipService = Get.find<HealthTipService>();

  @override
  void initState() {
    super.initState();
    fetchArticles();
    searchController.addListener(_onSearchChanged);
  }

  // Fetch articles and set both allArticles and filteredArticles
  void fetchArticles() async {
    List<HealthTipModel> articles =
        await healthTipService.getHealthTipsByCategory(
      categoryId: widget.healthTipsCategory.id.validate(),
    );
    setState(() {
      allArticles = articles;
      filteredArticles = articles;
    });
  }

  // Update filteredArticles based on the search query
  void _onSearchChanged() {
    setState(() {
      filteredArticles = allArticles
          .where((article) => article.title!
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "${widget.healthTipsCategory.name} Category",
                    style: boldTextStyle(size: 16),
                  ),
                  const SizedBox(width: 40), // Space for alignment
                ],
              ),
              Card(
                color: context.cardColor,
                child: AppTextField(
                  controller: searchController,
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search Article",
                    hintStyle: secondaryTextStyle(),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              10.height,
              Expanded(
                child: filteredArticles.isEmpty
                    ? Center(
                        child:
                            Text("No articles found", style: boldTextStyle()))
                    : ListView.builder(
                        itemCount: filteredArticles.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return eachTips(context, filteredArticles[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
