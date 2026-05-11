import 'package:pay/pay.dart';

const String defaultApplePayConfigString = '''{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.instantdoctor",
    "displayName": "Instant Doctor",
"merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
    "countryCode": "NG",
    "currencyCode": "NGN"
  }
}''';

const List<String> supportedAfricanCurrencies = [
  'NGN',
  'GHS',
  'KES',
  'UGX',
  'TZS',
  'RWF',
  'ZAR',
  'MWK',
  'ZMW',
  'XAF',
  'XOF'
];

const String defaultGooglePayConfigString = '''{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["AMEX", "DISCOVER", "MASTERCARD", "VISA"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "flutterwave",
            "gatewayMerchantId": "100610409"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "BCR2DN5T3OAMXUZH",
      "merchantName": "Instant Doctor"
    },
    "transactionInfo": {
      "countryCode": "NG",
      "currencyCode": "NGN"
    }
  }
}''';
