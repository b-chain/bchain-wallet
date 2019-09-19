// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcMethod _$RpcMethodFromJson(Map<String, dynamic> json) {
  return RpcMethod(
    json['method'] as String,
    (json['params'] as List)?.map((e) => e as String)?.toList(),
    json['id'] as String,
    json['jsonrpc'] as String,
  );
}

Map<String, dynamic> _$RpcMethodToJson(RpcMethod instance) => <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'method': instance.method,
      'id': instance.id,
      'params': instance.params,
    };
