// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    json['TimeStamp'] as int,
    json['TrHash'] as String,
    json['TrType'] as int,
    json['BlkNumber'] as int,
    json['Amount'] as String,
    json['Contract'] as String,
    json['Symbol'] as String,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'TimeStamp': instance.TimeStamp,
      'TrType': instance.TrType,
      'TrHash': instance.TrHash,
      'BlkNumber': instance.BlkNumber,
      'Amount': instance.Amount,
      'Contract': instance.Contract,
      'Symbol': instance.Symbol,
    };
