import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  List<String> allCurrencies = [
    "USD",
    "EUR",
    "JPY",
    "GBP",
    "AUD",
    "CAD",
    "CHF",
    "CNY",
    "SEK",
    "NZD",
    "MXN",
    "SGD",
    "HKD",
    "NOK",
    "KRW",
    "TRY",
    "INR",
    "RUB",
    "BRL",
    "ZAR",
    "AED",
    "SAR",
    "QAR",
    "MYR",
    "THB",
    "IDR",
    "PHP",
    "PLN",
    "ILS",
    "DKK",
    "HUF",
    "CZK",
    "CLP",
    "ARS",
    "TWD",
    "EGP",
    "NGN",
    "KWD",
    "PKR",
    "IQD",
    "OMR",
    "JOD",
    "BHD",
    "LKR",
    "NPR",
    "CRC",
    "PEN",
    "UYU",
    "VEF",
    "DZD",
    "KZT",
    "BDT",
    "QAR",
    "RSD",
    "XOF",
    "COP",
    "VND",
    "TND",
    "MAD",
    "HRK",
    "BYN",
    "GTQ",
    "MOP",
    "AWG",
    "BOB",
    "BWP",
    "CUP",
    "DJF",
    "ERN",
    "ETB",
    "FJD",
    "GEL",
    "GYD",
    "KHR",
    "KGS",
    "KWD",
    "LAK",
    "MKD",
    "MWK",
    "MVR",
    "MNT",
    "MUR",
    "MZN",
    "NAD",
    "NIO",
    "PGK",
    "PYG",
    "RWF",
    "SBD",
    "SCR",
    "SOS",
    "SZL",
    "TJS",
    "TMT",
    "TOP",
    "TTD",
    "UGX",
    "UZS",
    "VUV",
    "WST",
    "XAF",
    "XCD",
    "XPF",
    "YER",
    "ZMW",
  ];

  List<String> filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    filteredCurrencies = allCurrencies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/thumbnail1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Text(
                      "Choose Currency",
                      style: boldTextStyle(),
                    ),
                    Container(),
                  ],
                ),
                10.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  textStyle: primaryTextStyle(size: 14),
                  onChanged: (value) {
                    filterCurrencies(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.cardColor,
                    hintText: "Search Currency",
                    hintStyle: primaryTextStyle(size: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                20.height,
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Add your refresh logic here
                      await Future.delayed(const Duration(seconds: 2));
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        var currency = filteredCurrencies[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                currency,
                                style: boldTextStyle(size: 16),
                              ),
                            ),
                          ).onTap(() {
                            finish(context, currency);
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void filterCurrencies(String query) {
    setState(() {
      filteredCurrencies = allCurrencies
          .where((currency) =>
              currency.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
