// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionReceipt _$TransactionReceiptFromJson(Map<String, dynamic> json) {
  return TransactionReceipt(
    json['blockHash'] as String,
    json['blockNumber'] as int,
    json['transactionIndex'] as int,
    json['from'] as String,
    json['transactionHash'] as String,
    (json['contractAddress'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$TransactionReceiptToJson(TransactionReceipt instance) =>
    <String, dynamic>{
      'blockHash': instance.blockHash,
      'blockNumber': instance.blockNumber,
      'transactionIndex': instance.transactionIndex,
      'from': instance.from,
      'transactionHash': instance.transactionHash,
      'contractAddress': instance.contractAddress,
    };
