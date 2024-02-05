import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/TransactionModel.dart';

Padding eachTransaction({required TransactionModel transaction}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    transaction.transactionType ==
                            TransactionType.debit.toString()
                        ? CupertinoIcons.arrow_up_right
                        : CupertinoIcons.arrow_down_left,
                    color: transaction.transactionType ==
                            TransactionType.debit.toString()
                        ? redColor
                        : mediumSeaGreen,
                  ),
                ),
                10.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Booked Appointment",
                      style: boldTextStyle(size: 14),
                    ),
                    10.height,
                    Text(
                      timeago.format(transaction.createdAt!.toDate()),
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              transaction.transactionType == TransactionType.debit.toString()
                  ? "-NGN ${transaction.amount}"
                  : "NGN ${transaction.amount}",
              style: boldTextStyle(
                color: transaction.transactionType ==
                        TransactionType.debit.toString()
                    ? redColor
                    : mediumSeaGreen,
                size: 12,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
