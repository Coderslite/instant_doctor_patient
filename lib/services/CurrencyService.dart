import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/CurrencyModel.dart';

class CurrencyService {
  var currencyCol = db.collection("Currencies");
  Future<List<CurrencyModel>> getAvailableCurrencies() async {
    var result = await currencyCol.get();
    var res = result.docs.map((e) => CurrencyModel.fromJson(e.data())).toList();
    print(res);
    return res;
  }
}
