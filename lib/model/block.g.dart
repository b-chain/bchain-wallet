// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) {
  return Block(
    json['CurBlock'] as int,
    json['TargetBlock'] as int,
  );
}

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'CurBlock': instance.CurBlock,
      'TargetBlock': instance.TargetBlock,
    };
