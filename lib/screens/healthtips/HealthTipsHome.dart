import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:instant_doctor/screens/healthtips/SelectedHealthTip.dart';
import 'package:instant_doctor/services/HealthTipService.dart';
import 'package:nb_utils/nb_utils.dart';


class HealthTipsHome extends StatefulWidget {
  const HealthTipsHome({super.key});

  @override
  State<HealthTipsHome> createState() => _HealthTipsHomeState();
}

class _HealthTipsHomeState extends State<HealthTipsHome> {
  TextEditingController searchController = TextEditingController();
  List<HealthTipsCategoryModel> allCategories = [];
  List<HealthTipsCategoryModel> filteredCategories = [];
  bool isLoading = true;
  final healthTipService = Get.find<HealthTipService>();

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch the categories when the widget initializes
    searchController
        .addListener(_onSearchChanged); // Listen for search input changes
  }

  // Fetch categories and set both allCategories and filteredCategories
  void fetchCategories() async {
    List<HealthTipsCategoryModel> categories =
        await healthTipService.getHealthTipsCategory();
    setState(() {
      allCategories = categories;
      filteredCategories = categories;
      isLoading = false;
    });
  }

  // Update filteredCategories based on the search query
  void _onSearchChanged() {
    setState(() {
      filteredCategories = allCategories
          .where((category) => category.name!
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
                    "Health Tips Category",
                    style: boldTextStyle(size: 16),
                  ),
                  const SizedBox(width: 40), // Adds space for alignment
                ],
              ),
              10.height,
              Card(
                color: context.cardColor,
                child: AppTextField(
                  controller: searchController,
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search Category",
                    hintStyle: secondaryTextStyle(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              10.height,
              Expanded(
                child: isLoading
                    ? Loader()
                    : filteredCategories.isEmpty
                        ? Center(
                            child: Text("No categories found",
                                style: boldTextStyle()))
                        : CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final category =
                                          filteredCategories[index];
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: context.cardColor,
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: CachedNetworkImage(
                                                    imageUrl: category.image
                                                        .validate(),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              category.name.validate(),
                                              style: boldTextStyle(size: 10),
                                            ),
                                            StreamBuilder<int>(
                                                stream: healthTipService
                                                    .getArticleCount(
                                                        categoryId: category.id
                                                            .validate()),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    var count = snapshot.data!;
                                                    return Text(
                                                      count < 1
                                                          ? "no article yet"
                                                          : "+$count Articles",
                                                      style: secondaryTextStyle(
                                                          size: 10),
                                                    );
                                                  }
                                                  return SizedBox.shrink();
                                                }),
                                          ],
                                        ),
                                      ).onTap(() {
                                        SelectedHealthTip(
                                          healthTipsCategory: category,
                                        ).launch(context);
                                      });
                                    },
                                    childCount: filteredCategories.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
