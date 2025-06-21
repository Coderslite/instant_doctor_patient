import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachMedicine.dart';
import '../../controllers/OrderController.dart';
import '../../services/DrugService.dart';
import '../../services/PharmacyService.dart';
import 'Cart.dart';

class MedicineHome extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;
  const MedicineHome(
      {super.key, required this.pharmacyId, required this.pharmacyName});

  @override
  State<MedicineHome> createState() => _MedicineHomeState();
}

class _MedicineHomeState extends State<MedicineHome> {
  int selectedindex = 0;
  int selectedCategoryIndex = 0;
  var isLoading = true;
  final orderController = Get.find<OrderController>();

  final drugService = Get.find<DrugService>();
  final pharmacyService = Get.find<PharmacyService>();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _categories = ['All']; // Default 'All' category

  @override
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
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
                    widget.pharmacyName,
                    style: boldTextStyle(
                      size: 18,
                    ),
                  ),
                  Obx(
                    () => Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary,
                          ),
                          child: Icon(
                            Icons.shopping_cart_checkout,
                            color: white,
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Badge(
                            label: Text(
                              "${orderController.cart.length}",
                              style: secondaryTextStyle(size: 12, color: white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    CartScreen().launch(context);
                  }),
                ],
              ),
              Card(
                color: context.cardColor,
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintStyle: secondaryTextStyle(),
                    hintText: "Search Medicine",
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              _buildCategoryChips(),
              Expanded(child: _buildMedicineGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return StreamBuilder<List<DrugCategoryModel>>(
      stream: drugService.getDrugCat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _categories =
              ['All'] + snapshot.data!.map((e) => e.name.validate()).toList();
          print(_categories);
          return Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _categories[index],
                      style: boldTextStyle(
                        size: 12,
                        color: selectedCategoryIndex == index
                            ? white
                            : Colors.black,
                      ),
                    ),
                    selected: selectedCategoryIndex == index,
                    selectedColor: kPrimary,
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                );
              },
            ),
          );
        }
        return SizedBox(height: 50, child: Center(child: Loader()));
      },
    );
  }

  Widget _buildMedicineGrid() {
    return StreamBuilder<List<DrugModel>>(
      stream: pharmacyService.getPharmacyDrug(pharmacyId: widget.pharmacyId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading medicines"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loader());
        }

        if (snapshot.hasData) {
          var data = snapshot.data!;

          // Apply filters
          var filteredData = data.where((drug) {
            // Apply category filter
            final categoryMatch = selectedCategoryIndex == 0 ||
                drug.category == _categories[selectedCategoryIndex];

            // Apply search filter
            final searchMatch = _searchQuery.isEmpty ||
                drug.name.validate().toLowerCase().contains(_searchQuery) ||
                (drug.description?.toLowerCase().contains(_searchQuery) ??
                    false);

            return categoryMatch && searchMatch;
          }).toList();

          if (filteredData.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No medicines found",
                  style: boldTextStyle(size: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Try a different search or category",
                  style: secondaryTextStyle(),
                ),
              ],
            );
          }

          return MasonryGridView.builder(
            padding: EdgeInsets.only(top: 0),
            itemCount: filteredData.length,
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              return eachMedicine(
                context,
                drug: filteredData[index],
                pharmacyName: widget.pharmacyName,
              );
            },
          );
        }

        return Center(child: Loader());
      },
    );
  }
}
