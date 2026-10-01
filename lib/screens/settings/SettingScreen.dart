import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/screens/authentication/select_country_currency.dart';
import '../../component/backButton.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _pricingService = Get.find<PricingService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingsController.isDarkMode.value ? scaffoldColorDark : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Settings",
                    style: boldTextStyle(
                      color: settingsController.isDarkMode.value ? Colors.white : kText,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 44), // balance backButton
                ],
              ),
              20.height,
              
              // Dark Mode Switch
              SwitchListTile(
                value: settingsController.isDarkMode.value,
                activeTrackColor: kPrimary,
                inactiveTrackColor: kPrimaryLight,
                onChanged: (val) {
                  settingsController.handleChangeTheme();
                  setState(() {});
                },
                title: Text(
                  "Dark Mode",
                  style: primaryTextStyle(
                    color: settingsController.isDarkMode.value ? Colors.white : kText,
                  ),
                ),
              ),
              const Divider(),

              // Country & Currency Selector
              Obx(() {
                final isDarkMode = settingsController.isDarkMode.value;
                final textColor = isDarkMode ? Colors.white : kText;
                final subColor = isDarkMode ? Colors.grey : kSub;
                
                final country = stripeSupportedCountries.firstWhere(
                  (c) => c.countryCode == _pricingService.userCountry.value,
                  orElse: () => stripeSupportedCountries.first,
                );

                return ListTile(
                  title: Text(
                    "Country & Currency",
                    style: primaryTextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    "${country.flag} ${country.countryName} (${country.currencyCode})",
                    style: secondaryTextStyle(color: subColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: subColor,
                  ),
                  onTap: () {
                    const SelectCountryCurrencyScreen(isSignupFlow: false).launch(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
