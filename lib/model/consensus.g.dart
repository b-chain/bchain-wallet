// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consensus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consensus _$ConsensusFromJson(Map<String, dynamic> json) {
  return Consensus(
    json['id'] as String,
    json['data'] as String,
  );
}

Map<String, dynamic> _$ConsensusToJson(Consensus instance) => <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
    };
