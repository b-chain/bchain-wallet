import 'dart:async';
import 'dart:convert';
import 'package:bchain_app/model/asset.dart';
import 'package:bchain_app/model/block.dart';
import 'package:bchain_app/model/rpc_method.dart';
import 'package:bchain_app/model/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class RepoHttpException implements Exception {
  final int code;
  final String message;
  final String body;

  RepoHttpException(this.code, this.message, [this.body]);

  String toString() => "[$code:$message]$body";
}

class BusinessException implements Exception {
  final String code;
  final String message;

  BusinessException(this.code, this.message);

  String toString() => "[$code:$message]";
}

abstract class WebsocketMessageListener {
  void onBlockMessage(Repository repository, Block message);
}

typedef T ContentConverter<T>(content, http.Response response);

class Repository {
  static final Repository _singleton = Repository._internal();
  static final Duration defaultTimeout = const Duration(seconds: 20);

  static ContentConverter<T> rpcResultConvert<T>(T convert(e)) => (data, _) {
        final error = data["error"];
        if (error != null) throw Exception("${error["code"]}:${error["message"]}");
        return convert(data["result"]);
      };

  static ContentConverter<List<T>> rpcListResultConvert<T>(T convert(e)) => (data, _) {
        final error = data["error"];
        if (error != null) throw Exception("${error["code"]}:${error["message"]}");
        return (data["result"] as Iterable).map((e) => convert(e)).toList();
      };

  factory Repository() => _singleton;

  Repository._internal();

  final baseRepositoryUrl = "http://127.0.0.1:8989";
  final _websocketRepositoryUrl = "ws://127.0.0.1:9999";

  /*
  final baseRepositoryUrl = "http://dev.bt.cool:18989";
  final _websocketRepositoryUrl = "ws://dev.bt.cool:19999";
   */

  final List<WebsocketMessageListener> _messageListeners = [];
  IOWebSocketChannel _webSocketChannel;
  bool __webSocketChannelError = false;

  Block _currentBlock;

  void registerListener(WebsocketMessageListener listener) {
    if (_messageListeners.contains(listener)) return;
    _messageListeners.add(listener);
    _checkWebsocketConnection();
  }

  void unregisterListener(WebsocketMessageListener listener) {
    _messageListeners.remove(listener);
    if (_messageListeners.isEmpty && _webSocketChannel != null) {
      _webSocketChannel.sink.close();
      _webSocketChannel = null;
    }
  }

  void _checkWebsocketConnection() {
    if (_webSocketChannel == null || __webSocketChannelError) {
      __webSocketChannelError = false;
      _webSocketChannel = IOWebSocketChannel.connect(Repository()._websocketRepositoryUrl);
      _webSocketChannel.stream.listen((event) {
        Block block;
        try {
          block = Block.fromJson(json.decode(event));
        } catch (e) {
          print(e);
        }
        if (block != null) {
          if (_currentBlock == null || _currentBlock.CurBlock < block.CurBlock) {
            _currentBlock = block;
            _fireListener((l) => l.onBlockMessage(this, block));
          }
        }
      }, onError: (e) {
        print(e);
        __webSocketChannelError = true;
        Future.delayed(Duration(seconds: 2)).then((t) => _checkWebsocketConnection());
      }, onDone: () => _webSocketChannel = null, cancelOnError: true);
    }
  }

  void _fireListener(void callback(WebsocketMessageListener listener)) {
    _messageListeners.forEach(callback);
  }

  Future<T> _apply<T>(Future<http.Response> future, ContentConverter<T> convert) => future.then((response) {
        print("${response.statusCode}:${response.reasonPhrase}");
        print(response.body);
        if (response.statusCode < 200 || response.statusCode >= 300) throw RepoHttpException(response.statusCode, response.reasonPhrase, response.body);
        final body = response.body;
        return body == null || body.isEmpty ? null : convert == null ? json.decode(body) : convert(json.decode(body), response);
      });

  String _checkUrl(String url) => url == null || url.isEmpty ? baseRepositoryUrl : url.indexOf("://") > 0 ? url : url.startsWith("/") ? baseRepositoryUrl + url : "$baseRepositoryUrl/$url";

  Map<String, String> _checkHeader(Map<String, String> headers, {bool json = true}) {
    final map = headers == null ? Map<String, String>() : headers;
    if (json) map.putIfAbsent("content-type", () => "application/json");
    return map;
  }

  String _jsonEncode(obj, [String defaultValue = "{}"]) {
    return json.encode(obj) ?? defaultValue;
  }

  Future<T> _invokeRpc<T>(String method, {List<String> params, ContentConverter<T> convert, String id: "1"}) {
    final m = RpcMethod(method, params, id, "2.0");
    // print(_jsonEncode(m));
    return post<T>(body: m, convert: convert);
  }

  Future<T> head<T>({String url, Map<String, String> headers, ContentConverter<T> convert}) => _apply(http.head(_checkUrl(url), headers: _checkHeader(headers)), convert);

  Future<T> get<T>({String url, Map<String, String> headers, ContentConverter<T> convert}) => _apply(http.get(_checkUrl(url), headers: _checkHeader(headers)), convert);

  Future<T> post<T>({String url, Map<String, String> headers, body, ContentConverter<T> convert, jsonBody = true}) =>
      _apply(http.post(_checkUrl(url), headers: _checkHeader(headers, json: jsonBody), body: jsonBody ? _jsonEncode(body) : body), convert);

  Future<T> put<T>({String url, Map<String, String> headers, body, ContentConverter<T> convert, jsonBody = true}) =>
      _apply(http.put(_checkUrl(url), headers: _checkHeader(headers, json: jsonBody), body: jsonBody ? _jsonEncode(body) : body), convert);

  Future<T> patch<T>({String url, Map<String, String> headers, body, ContentConverter<T> convert, jsonBody = true}) =>
      _apply(http.patch(_checkUrl(url), headers: _checkHeader(headers, json: jsonBody), body: jsonBody ? _jsonEncode(body) : body), convert);

  Future<T> delete<T>({String url, Map<String, String> headers, ContentConverter<T> convert}) => _apply(http.delete(_checkUrl(url), headers: _checkHeader(headers)), convert);

  Future<List<String>> getAccountAddresses() => _invokeRpc("wallet_getAccounts", convert: rpcListResultConvert((e) => e.toString()));

  Future<String> createAccountAddress(String password) => _invokeRpc("wallet_newAccount", params: [password], convert: rpcResultConvert((e) => e.toString()));

  Future<String> modifyAccountAddressPassword(String address, String oldPassword, String newPassword) =>
      _invokeRpc("wallet_modifyAccount", params: [address, oldPassword, newPassword], convert: rpcResultConvert((e) => e.toString()));

  Future<String> getBalance(String address, String token, String contract) =>
      _invokeRpc("wallet_actionCallBalanceOf", params: [contract, token, address], convert: rpcResultConvert((e) => e.toString()));

  Future<List<Transaction>> getTransactions(String address) => _invokeRpc("wallet_getTransferRecord", params: [address], convert: rpcListResultConvert((e) => Transaction.fromJson(e)));

  Future<Block> getChainInfo() => _invokeRpc("wallet_getSiInfo", convert: rpcResultConvert((e) => Block.fromJson(e)));

  Future<List<Asset>> getAssets() => _invokeRpc("wallet_getAssets", convert: rpcListResultConvert((e) => Asset.fromJson(e)));

  Future<String> createToken(String address, String password, double fee, String symbol, String decimal, String amount, String contract)
  => _invokeRpc("wallet_sendTokenCreateTransaction", params: [address, password, fee.toString(), symbol, decimal, symbol, amount, contract], convert: rpcResultConvert((e) => e.toString()));

  Future<String> createBigTokenContract(String address, String password, double fee) => _invokeRpc("wallet_sendContractCreateTransaction", params: [address, password, fee.toString()], convert: rpcResultConvert((e) => e.toString()));

  Future<List<String>> getAddressCreatedContract(String address) => _invokeRpc("wallet_getConAddr", params: [address], convert: rpcListResultConvert((e) => e['ContractAddr']));

  Future<String> exportKeystore(String address, String password) => _invokeRpc("wallet_export", params: [address, password], convert: rpcResultConvert((e) => e.toString()));

  Future<String> importKeystore(String keystore, String password) => _invokeRpc("wallet_import", params: [keystore, password], convert: rpcResultConvert((e) => e.toString()));

  Future<String> sendTransaction(String address, String password, double fee, String toAddress, String amount, String token, String memo, String contract)
  => _invokeRpc("wallet_sendTokenTransferTransaction", params: [address, password, fee.toString(), toAddress, amount, token, memo, contract], convert: rpcResultConvert((e) => e.toString()));

  Future<String> addContractIndex(String contract) => _invokeRpc("wallet_addScanContract", params: [contract], convert: rpcResultConvert((e) => e.toString()));

  Future<String> jumpPage(String url) => _invokeRpc("wallet_jumpPage", params: [url], convert: rpcResultConvert((e) => e.toString()));

}
