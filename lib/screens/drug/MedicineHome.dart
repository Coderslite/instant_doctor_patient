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
  var isLoading = true;
  final orderController = Get.find<OrderController>();

  final drugService = Get.find<DrugService>();
  final pharmacyService = Get.find<PharmacyService>();
  @override
  void initState() {
    super.initState();
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
              10.height,
              SizedBox(
                height: 25,
                child: StreamBuilder(
                    stream: drugService.getDrugCat(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return ListView.builder(
                            itemCount: data.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              var cat = data[index];
                              return Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color:
                                      selectedindex == index ? kPrimary : grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cat.name.validate(),
                                  style: boldTextStyle(
                                    color: white,
                                    size: 10,
                                  ),
                                ),
                              ).onTap(() {
                                selectedindex = index;
                                setState(() {});
                              });
                            });
                      }
                      return Loader();
                    }),
              ),
              10.height,
              Expanded(
                child: StreamBuilder<List<DrugModel>>(
                    stream: pharmacyService.getPharmacyDrug(
                        pharmacyId: widget.pharmacyId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return MasonryGridView.builder(
                          itemCount: data.length,
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return eachMedicine(context,
                                drug: data[index],
                                pharmacyName: widget.pharmacyName);
                          },
                        );
                      }
                      return Loader();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
