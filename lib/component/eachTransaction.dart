import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/TransactionModel.dart';

Container eachTransaction(
    {required TransactionModel transaction, required BuildContext context}) {
  return Container(
    padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(vertical: 2),
    
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.9,
                    child: Text(
                      transaction.title!,
                      style: boldTextStyle(size: 14),
                    ),
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
        ),
        Text(
          transaction.transactionType == TransactionType.debit.toString()
              ? "-${formatAmount(transaction.amount!)}"
              : formatAmount(transaction.amount!),
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
  );
}
