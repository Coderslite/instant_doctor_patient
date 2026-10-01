import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/component/PremiumButton.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/services/GetUserId.dart';

class StripeCountryCurrency {
  final String countryName;
  final String countryCode; // ISO 2-letter
  final String currencyCode; // ISO 3-letter
  final String currencyName;
  final String flag;

  const StripeCountryCurrency({
    required this.countryName,
    required this.countryCode,
    required this.currencyCode,
    required this.currencyName,
    required this.flag,
  });
}

const List<StripeCountryCurrency> stripeSupportedCountries = [
  StripeCountryCurrency(countryName: 'United States', countryCode: 'US', currencyCode: 'USD', currencyName: 'US Dollar', flag: '🇺🇸'),
  StripeCountryCurrency(countryName: 'United Kingdom', countryCode: 'GB', currencyCode: 'GBP', currencyName: 'British Pound', flag: '🇬🇧'),
  StripeCountryCurrency(countryName: 'Canada', countryCode: 'CA', currencyCode: 'CAD', currencyName: 'Canadian Dollar', flag: '🇨🇦'),
  StripeCountryCurrency(countryName: 'Australia', countryCode: 'AU', currencyCode: 'AUD', currencyName: 'Australian Dollar', flag: '🇦🇺'),
  StripeCountryCurrency(countryName: 'New Zealand', countryCode: 'NZ', currencyCode: 'NZD', currencyName: 'New Zealand Dollar', flag: '🇳🇿'),
  StripeCountryCurrency(countryName: 'Japan', countryCode: 'JP', currencyCode: 'JPY', currencyName: 'Japanese Yen', flag: '🇯🇵'),
  StripeCountryCurrency(countryName: 'Singapore', countryCode: 'SG', currencyCode: 'SGD', currencyName: 'Singapore Dollar', flag: '🇸🇬'),
  StripeCountryCurrency(countryName: 'Hong Kong', countryCode: 'HK', currencyCode: 'HKD', currencyName: 'Hong Kong Dollar', flag: '🇭🇰'),
  StripeCountryCurrency(countryName: 'India', countryCode: 'IN', currencyCode: 'INR', currencyName: 'Indian Rupee', flag: '🇮🇳'),
  StripeCountryCurrency(countryName: 'United Arab Emirates', countryCode: 'AE', currencyCode: 'AED', currencyName: 'UAE Dirham', flag: '🇦🇪'),
  StripeCountryCurrency(countryName: 'Germany', countryCode: 'DE', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇩🇪'),
  StripeCountryCurrency(countryName: 'France', countryCode: 'FR', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇫🇷'),
  StripeCountryCurrency(countryName: 'Italy', countryCode: 'IT', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇮🇹'),
  StripeCountryCurrency(countryName: 'Spain', countryCode: 'ES', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇪🇸'),
  StripeCountryCurrency(countryName: 'Netherlands', countryCode: 'NL', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇳🇱'),
  StripeCountryCurrency(countryName: 'Belgium', countryCode: 'BE', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇧🇪'),
  StripeCountryCurrency(countryName: 'Austria', countryCode: 'AT', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇦🇹'),
  StripeCountryCurrency(countryName: 'Portugal', countryCode: 'PT', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇵🇹'),
  StripeCountryCurrency(countryName: 'Ireland', countryCode: 'IE', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇮🇪'),
  StripeCountryCurrency(countryName: 'Finland', countryCode: 'FI', currencyCode: 'EUR', currencyName: 'Euro', flag: '🇫🇮'),
  StripeCountryCurrency(countryName: 'Switzerland', countryCode: 'CH', currencyCode: 'CHF', currencyName: 'Swiss Franc', flag: '🇨🇭'),
  StripeCountryCurrency(countryName: 'Norway', countryCode: 'NO', currencyCode: 'NOK', currencyName: 'Norwegian Krone', flag: '🇳🇴'),
  StripeCountryCurrency(countryName: 'Sweden', countryCode: 'SE', currencyCode: 'SEK', currencyName: 'Swedish Krona', flag: '🇸🇪'),
  StripeCountryCurrency(countryName: 'Denmark', countryCode: 'DK', currencyCode: 'DKK', currencyName: 'Danish Krone', flag: '🇩🇰'),
  StripeCountryCurrency(countryName: 'Poland', countryCode: 'PL', currencyCode: 'PLN', currencyName: 'Polish Zloty', flag: '🇵🇱'),
  StripeCountryCurrency(countryName: 'Brazil', countryCode: 'BR', currencyCode: 'BRL', currencyName: 'Brazilian Real', flag: '🇧🇷'),
  StripeCountryCurrency(countryName: 'Mexico', countryCode: 'MX', currencyCode: 'MXN', currencyName: 'Mexican Peso', flag: '🇲🇽'),
  StripeCountryCurrency(countryName: 'Malaysia', countryCode: 'MY', currencyCode: 'MYR', currencyName: 'Malaysian Ringgit', flag: '🇲🇾'),
  StripeCountryCurrency(countryName: 'South Africa', countryCode: 'ZA', currencyCode: 'ZAR', currencyName: 'South African Rand', flag: '🇿🇦'),
  StripeCountryCurrency(countryName: 'Nigeria', countryCode: 'NG', currencyCode: 'NGN', currencyName: 'Nigerian Naira', flag: '🇳🇬'),
  StripeCountryCurrency(countryName: 'Ghana', countryCode: 'GH', currencyCode: 'GHS', currencyName: 'Ghanaian Cedi', flag: '🇬🇭'),
  StripeCountryCurrency(countryName: 'Kenya', countryCode: 'KE', currencyCode: 'KES', currencyName: 'Kenyan Shilling', flag: '🇰🇪'),
  StripeCountryCurrency(countryName: 'Tanzania', countryCode: 'TZ', currencyCode: 'TZS', currencyName: 'Tanzanian Shilling', flag: '🇹🇿'),
  StripeCountryCurrency(countryName: 'Uganda', countryCode: 'UG', currencyCode: 'UGX', currencyName: 'Ugandan Shilling', flag: '🇺🇬'),
  StripeCountryCurrency(countryName: 'Rwanda', countryCode: 'RW', currencyCode: 'RWF', currencyName: 'Rwandan Franc', flag: '🇷🇼'),
  StripeCountryCurrency(countryName: 'Egypt', countryCode: 'EG', currencyCode: 'EGP', currencyName: 'Egyptian Pound', flag: '🇪🇬'),
];

class SelectCountryCurrencyScreen extends StatefulWidget {
  final bool isSignupFlow;

  const SelectCountryCurrencyScreen({super.key, required this.isSignupFlow});

  @override
  State<SelectCountryCurrencyScreen> createState() => _SelectCountryCurrencyScreenState();
}

class _SelectCountryCurrencyScreenState extends State<SelectCountryCurrencyScreen> {
  final _searchController = TextEditingController();
  final _pricingService = Get.find<PricingService>();
  
  String _selectedCountryCode = 'US';
  String _selectedCurrencyCode = 'USD';
  List<StripeCountryCurrency> _filteredCountries = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = _pricingService.userCountry.value;
    _selectedCurrencyCode = _pricingService.userCurrency.value;
    _filteredCountries = stripeSupportedCountries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = stripeSupportedCountries.where((country) {
        return country.countryName.toLowerCase().contains(query) ||
               country.countryCode.toLowerCase().contains(query) ||
               country.currencyCode.toLowerCase().contains(query) ||
               country.currencyName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectCountry(StripeCountryCurrency country) {
    setState(() {
      _selectedCountryCode = country.countryCode;
      _selectedCurrencyCode = country.currencyCode;
    });
  }

  Future<void> _saveSelection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Update PricingService state, SharedPreferences cache, and Firestore profile
      await _pricingService.updateCountryAndCurrency(_selectedCountryCode, _selectedCurrencyCode);
      
      // 2. Double-check if we need to call getUserId to sync local variables
      await getUserId();

      if (!mounted) return;
      toast("Location and currency updated successfully");

      if (widget.isSignupFlow) {
        // Continue to Create PIN screen
        const CreatePinScreen().launch(context, isNewTask: true);
      } else {
        // Return to settings
        Get.back();
      }
    } catch (e) {
      toast("Failed to update preferences: $e");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;
    final activeBgColor = isDarkMode ? scaffoldColorDark : Colors.white;
    final textColor = isDarkMode ? Colors.white : kText;
    final cardBgColor = isDarkMode ? scaffoldSecondaryDark : const Color(0xFFF8FAFF);
    final borderColor = isDarkMode ? appButtonColorDark : kBorder;

    final selectedCountry = stripeSupportedCountries.firstWhere(
      (c) => c.countryCode == _selectedCountryCode,
      orElse: () => stripeSupportedCountries.first,
    );

    return Scaffold(
      backgroundColor: activeBgColor,
      appBar: AppBar(
        backgroundColor: activeBgColor,
        elevation: 0,
        leading: widget.isSignupFlow
            ? null
            : Padding(
                padding: const EdgeInsets.all(6.0),
                child: backButton(context),
              ),
        title: Text(
          widget.isSignupFlow ? "Billing Preference" : "Change Country/Currency",
          style: boldTextStyle(color: textColor, size: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isSignupFlow) ...[
                10.height,
                Text(
                  "Configure Region",
                  style: boldTextStyle(size: 26, color: textColor),
                ),
                8.height,
                Text(
                  "Select your country and preferred currency. This enables localized payment options and displays accurate subscription plans.",
                  style: secondaryTextStyle(color: isDarkMode ? Colors.grey : kSub, size: 14),
                ),
                20.height,
              ],
              
              // Active Selection Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  gradient: LinearGradient(
                    colors: isDarkMode 
                      ? [scaffoldSecondaryDark, scaffoldSecondaryDark.withOpacity(0.8)]
                      : [const Color(0xFFE0F7FF), const Color(0xFFF3FBFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCountry.flag,
                      style: const TextStyle(fontSize: 36),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCountry.countryName,
                            style: boldTextStyle(size: 16, color: textColor),
                          ),
                          4.height,
                          Text(
                            "${selectedCountry.currencyName} (${selectedCountry.currencyCode})",
                            style: secondaryTextStyle(size: 13, color: isDarkMode ? Colors.white70 : kSub),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        selectedCountry.currencyCode,
                        style: boldTextStyle(color: kPrimary, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
              20.height,

              // Search Box
              TextField(
                controller: _searchController,
                style: primaryTextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search country or currency...",
                  hintStyle: secondaryTextStyle(color: isDarkMode ? Colors.grey : kSub),
                  prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey : kSub),
                  filled: true,
                  fillColor: isDarkMode ? scaffoldSecondaryDark : const Color(0xFFF5F7FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary, width: 1.5),
                  ),
                ),
              ),
              15.height,

              // Countries List Label
              Text(
                "Stripe Supported Regions",
                style: boldTextStyle(size: 14, color: isDarkMode ? Colors.grey : kSub),
              ),
              10.height,

              // Country list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    final isSelected = country.countryCode == _selectedCountryCode;

                    return GestureDetector(
                      onTap: () => _selectCountry(country),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? kPrimary.withOpacity(isDarkMode ? 0.15 : 0.06) 
                            : (isDarkMode ? scaffoldSecondaryDark : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                              ? kPrimary 
                              : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              country.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            16.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.countryName,
                                    style: boldTextStyle(
                                      size: 14, 
                                      color: isSelected ? kPrimary : textColor
                                    ),
                                  ),
                                  2.height,
                                  Text(
                                    country.currencyName,
                                    style: secondaryTextStyle(
                                      size: 12, 
                                      color: isDarkMode ? Colors.grey : kSub
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: kPrimary,
                                size: 22,
                              )
                            else
                              Text(
                                country.currencyCode,
                                style: boldTextStyle(
                                  color: isDarkMode ? Colors.grey : kSub.withOpacity(0.7), 
                                  size: 13
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: PremiumButton(
                  onTap: _saveSelection,
                  isLoading: _isSaving,
                  text: widget.isSignupFlow ? "Confirm & Continue" : "Save Changes",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
