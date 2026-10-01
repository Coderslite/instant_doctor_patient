import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/services/formatDuration.dart';

class PricingService extends GetxService {
  // ── Appointment Packages (fetched from Firestore) ──────────────────────
  final RxList<Appointmentpricingmodel> appointmentPackages =
      <Appointmentpricingmodel>[].obs;

  // ── Base Prices (USD) - Populated from AppointmentPricing collection ──
  final RxMap<String, double> basePrices = <String, double>{}.obs;

  // ── State ────────────────────────────────────────────────────────────────
  RxString userCountry = 'US'.obs;
  RxString userCurrency = 'USD'.obs;
  RxDouble exchangeRate = 1.0.obs;
  RxBool isLoading = false.obs;

  // List of African country codes for the 50% discount
  final List<String> africanCountries = [
    'DZ', 'AO', 'BJ', 'BW', 'BF', 'BI', 'CV', 'CM', 'CF', 'TD', 'KM', 'CD',
    'CG', 'DJ', 'EG', 'GQ', 'ER', 'SZ', 'ET', 'GA', 'GM', 'GH', 'GN', 'GW',
    'CI', 'KE', 'LS', 'LR', 'LY', 'MG', 'MW', 'ML', 'MR', 'MU', 'MA', 'MZ',
    'NA', 'NE', 'NG', 'RW', 'ST', 'SN', 'SC', 'SL', 'SO', 'ZA', 'SS', 'SD',
    'TZ', 'TG', 'TN', 'UG', 'ZM', 'ZW'
  ];

  @override
  void onInit() {
    super.onInit();
    initPricing();
    _listenToAppointmentPricing();
  }

  /// Listens to the AppointmentPricing Firestore collection for dynamic pricing.
  /// Each document has: id, name, amount (USD), description, duration.
  void _listenToAppointmentPricing() {
    db.collection('AppointmentPricing')
        .orderBy('amount', descending: false)
        .snapshots()
        .listen((snapshot) {
      appointmentPackages.value = snapshot.docs
          .map((doc) => Appointmentpricingmodel.fromJson(doc.data()))
          .toList();

      // Populate basePrices keyed by document ID
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final id = data['id'] ?? doc.id;
        basePrices[id] = (data['amount'] as num).toDouble();
      }

      print("🔥 Appointment Pricing Updated: ${appointmentPackages.length} packages | basePrices: $basePrices");
    }, onError: (e) {
      log('Appointment Pricing Error: $e');
    });
  }

  Future<void> initPricing() async {
    isLoading.value = true;
    try {
      // 1. Load Country and Currency from SharedPreferences cache
      final prefs = await SharedPreferences.getInstance();
      userCountry.value = prefs.getString('userCountry') ?? 'US';
      userCurrency.value = prefs.getString('userCurrency') ?? 'USD';
      
      print("🌍 Initial Cached Region: ${userCountry.value} | Currency: ${userCurrency.value}");

      // 2. Fetch Exchange Rate
      await fetchExchangeRate();
    } catch (e) {
      log('Pricing Init Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExchangeRate() async {
    try {
      final response =
          await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        exchangeRate.value = (rates[userCurrency.value] ?? 1.0).toDouble();
        print(
            "💰 Exchange Rate Fetched: 1 USD = ${exchangeRate.value} ${userCurrency.value}");
      }
    } catch (e) {
      log('Failed to fetch exchange rates: $e');
    }
  }

  Future<void> updateCountryAndCurrency(String countryCode, String currencyCode) async {
    userCountry.value = countryCode;
    userCurrency.value = currencyCode;

    // Cache locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userCountry', countryCode);
    await prefs.setString('userCurrency', currencyCode);

    // Update Firestore user document if logged in
    try {
      final userController = Get.find<UserController>();
      if (userController.userId.value.isNotEmpty) {
        final userService = Get.find<UserService>();
        await userService.updateProfile(
          data: {
            "country": countryCode,
            "currency": currencyCode,
          },
          userId: userController.userId.value,
        );
        print("🔥 Updated country & currency in Firestore for user ${userController.userId.value}");
      }
    } catch (e) {
      log("Error updating user profile country/currency in Firestore: $e");
    }

    // Refresh exchange rate
    await fetchExchangeRate();
  }

  String getCurrencyFromCountry(String countryCode) {
    Map<String, String> mapping = {
      // Africa
      'NG': 'NGN', 'GH': 'GHS', 'KE': 'KES', 'ZA': 'ZAR', 'TZ': 'TZS',
      'UG': 'UGX', 'RW': 'RWF', 'EG': 'EGP',
      // Europe
      'GB': 'GBP', 'DE': 'EUR', 'FR': 'EUR', 'IT': 'EUR', 'ES': 'EUR',
      'NL': 'EUR', 'IE': 'EUR', 'CH': 'CHF',
      // Americas
      'US': 'USD', 'CA': 'CAD', 'BR': 'BRL', 'MX': 'MXN',
      // Asia/Oceania
      'JP': 'JPY', 'CN': 'CNY', 'IN': 'INR', 'AU': 'AUD', 'NZ': 'NZD',
      'SG': 'SGD', 'MY': 'MYR', 'KR': 'KRW',
      // Middle East
      'AE': 'AED', 'SA': 'SAR', 'QA': 'QAR', 'TR': 'TRY'
    };
    return mapping[countryCode] ?? 'USD';
  }

  // ── Price Calculation Logic ──────────────────────────────────────────────

  double _roundUp(double price, String currency) {
    if (price <= 0) return 0.0;
    
    switch (currency.toUpperCase()) {
      case 'NGN':
        return ((price / 100).ceil() * 100).toDouble();
      case 'UGX':
      case 'TZS':
      case 'RWF':
      case 'KRW':
        return ((price / 1000).ceil() * 1000).toDouble();
      case 'JPY':
        return ((price / 100).ceil() * 100).toDouble();
      case 'INR':
      case 'KES':
      case 'GHS':
      case 'ZAR':
      case 'EGP':
      case 'TRY':
        return ((price / 10).ceil() * 10).toDouble();
      default:
        return price.ceilToDouble();
    }
  }

  /// Calculates the final price for a specific product ID (in user's local currency).
  /// Applies African discount (50%), current exchange rate, and rounds up.
  /// Calculates the final price for a specific product ID or type (in user's local currency).
  /// Applies African discount (50%), current exchange rate, and rounds up.
  double getFinalPrice(String packageIdOrType) {
    double price = basePrices[packageIdOrType] ?? 0.0;
    if (price == 0.0) {
      final pkg = appointmentPackages.firstWhereOrNull(
        (p) => p.type?.toLowerCase() == packageIdOrType.toLowerCase() || p.id == packageIdOrType,
      );
      if (pkg != null && pkg.id != null) {
        price = basePrices[pkg.id!] ?? 0.0;
      }
    }

    // Apply 50% discount for African countries
    if (africanCountries.contains(userCountry.value)) {
      price = price * 0.5;
    }

    // Apply exchange rate and round up the final local price
    return _roundUp(price * exchangeRate.value, userCurrency.value);
  }

  /// Calculates the price in USD (applies African discount but not exchange rate)
  double getPriceInUSD(String packageIdOrType) {
    double price = basePrices[packageIdOrType] ?? 0.0;
    if (price == 0.0) {
      final pkg = appointmentPackages.firstWhereOrNull(
        (p) => p.type?.toLowerCase() == packageIdOrType.toLowerCase() || p.id == packageIdOrType,
      );
      if (pkg != null && pkg.id != null) {
        price = basePrices[pkg.id!] ?? 0.0;
      }
    }

    // Apply 50% discount for African countries
    if (africanCountries.contains(userCountry.value)) {
      price = price * 0.5;
    }

    return price;
  }

  String getFormattedPrice(String productId) {
    final price = getFinalPrice(productId);
    // Formatting based on currency
    if (userCurrency.value == 'NGN') return '₦${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'GHS') return '₵${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'JPY') return '¥${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'EUR') return '€${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'GBP') return '£${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'INR') return '₹${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'CNY') return '¥${price.toStringAsFixed(2)}';
    return '${userCurrency.value} ${price.toStringAsFixed(2)}';
  }

  bool isAfrican() => africanCountries.contains(userCountry.value.trim().toUpperCase());

  String getPackageType(String? packageIdOrType) {
    if (packageIdOrType.isEmptyOrNull) return 'standard';
    final lower = packageIdOrType!.toLowerCase().trim();
    if (lower == 'basic' || lower == 'standard' || lower == 'special') {
      return lower;
    }
    final matchingPkg = appointmentPackages.firstWhereOrNull((p) => p.id == packageIdOrType);
    if (matchingPkg != null && matchingPkg.type.validate().isNotEmpty) {
      return matchingPkg.type!.toLowerCase();
    }
    // Fallback based on ID name
    if (lower.contains('basic')) return 'basic';
    if (lower.contains('premium') || lower.contains('special')) return 'special';
    return 'standard';
  }

  bool isAppointmentExpired(AppointmentModel appt) {
    if (appt.endTime == null) return true;
    final now = DateTime.now();
    final type = getPackageType(appt.package);

    if (type == 'special' && appt.startTime != null) {
      final start = appt.startTime!.toDate();
      final end7Days = start.add(const Duration(days: 7));
      return now.isAfter(end7Days);
    }

    // Default standard/basic behavior
    return now.isAfter(appt.endTime!.toDate());
  }

  bool isAppointmentYetToStart(AppointmentModel appt) {
    if (appt.startTime == null) return false;
    final now = DateTime.now();
    return now.isBefore(appt.startTime!.toDate());
  }

  bool isAppointmentOngoing(AppointmentModel appt) {
    if (appt.startTime == null || appt.endTime == null) return false;
    final now = DateTime.now();
    final type = getPackageType(appt.package);

    if (type == 'special') {
      final start = appt.startTime!.toDate();
      final end7Days = start.add(const Duration(days: 7));
      if (now.isAfter(start) && now.isBefore(end7Days)) {
        final startToday = DateTime(now.year, now.month, now.day, start.hour, start.minute);
        final endToday = startToday.add(const Duration(hours: 1));
        return now.isAfter(startToday) && now.isBefore(endToday);
      }
      return false;
    }

    // Default standard/basic behavior
    final start = appt.startTime!.toDate();
    final end = appt.endTime!.toDate();
    return now.isAfter(start) && now.isBefore(end);
  }

  String getAppointmentStatusText(AppointmentModel appt) {
    if (appt.startTime == null || appt.endTime == null) return "Expired Session";
    final now = DateTime.now();
    final type = getPackageType(appt.package);
    final start = appt.startTime!.toDate();
    final end = appt.endTime!.toDate();

    if (type == 'special') {
      final diffDays = now.difference(start).inDays;
      if (diffDays >= 0 && diffDays <= 7) {
        final startToday = DateTime(now.year, now.month, now.day, start.hour, start.minute);
        final endToday = startToday.add(const Duration(hours: 1));
        if (now.isAfter(startToday) && now.isBefore(endToday)) {
          final timeRemaining = endToday.difference(now);
          return "Ongoing Follow-up (${formatDuration(timeRemaining)})";
        } else if (now.isBefore(startToday)) {
          final timeRemaining = startToday.difference(now);
          return "Starts in ${formatDuration(timeRemaining)} (Daily Follow-up)";
        } else {
          // If today's slot has passed, show next day's slot
          final nextStart = startToday.add(const Duration(days: 1));
          final timeRemaining = nextStart.difference(now);
          if (diffDays < 7) {
            return "Next follow-up in ${formatDuration(timeRemaining)}";
          }
        }
      }
      return "Expired 7-day Session";
    }

    // Default standard/basic behavior
    if (now.isBefore(start)) {
      return "Starts in ${formatDuration(start.difference(now))}";
    } else if (now.isAfter(start) && now.isBefore(end)) {
      return "Ongoing ${formatDuration(end.difference(now))}";
    } else {
      return "Expired Session";
    }
  }
}
