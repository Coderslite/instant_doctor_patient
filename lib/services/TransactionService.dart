// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/models/TransactionModel.dart';

import '../main.dart';

class TransactionType {
  static const credit = "Credit";
  static const debit = "Debit";
}

class TransactionService {
  var transactionCollection = db.collection("Transactions");

  Stream<List<TransactionModel>> getAllTransaction({required String userId}) {
    return transactionCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((event) => event.docs
            .map((e) => TransactionModel.fromJson(e.data()))
            .toList());
  }

  Stream<List<TransactionModel>> getReceivedTransaction(
      {required String userId}) {
    return transactionCollection
        .where('transactionType', isEqualTo: 'Credit')
        .snapshots()
        .map((event) => event.docs
            .map((e) => TransactionModel.fromJson(e.data()))
            .toList());
  }

  Stream<List<TransactionModel>> getSentTransaction({required String userId}) {
    return transactionCollection
        .where('transactionType', isEqualTo: 'Debit')
        .snapshots()
        .map((event) => event.docs
            .map((e) => TransactionModel.fromJson(e.data()))
            .toList());
  }

  Future<void> newTransaction(
      {required String title,
      required String userId,
      required int amount,
      required String type}) async {
    var data = TransactionModel(
      title: title,
      userId: userId,
      transactionType: type.toString(),
      amount: amount,
      createdAt: Timestamp.now(),
    );
    var res = await transactionCollection.add(data.toJson());
    await transactionCollection.doc(res.id).update({
      "id": res.id,
    });
  }
}
