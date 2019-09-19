// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) {
  return Asset(
    json['ConAddr'] as String,
    json['ConSymbol'] as String,
    json['BtCreator'] as String,
    json['BtDecimals'] as String,
    json['BtSupply'] as String,
    json['BtName'] as String,
  );
}

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'ConAddr': instance.ConAddr,
      'ConSymbol': instance.ConSymbol,
      'BtCreator': instance.BtCreator,
      'BtDecimals': instance.BtDecimals,
      'BtSupply': instance.BtSupply,
      'BtName': instance.BtName,
    };
