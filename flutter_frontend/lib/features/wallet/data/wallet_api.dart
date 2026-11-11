import 'package:flutter_frontend/core/network/api_client.dart';

class WalletApi {
  WalletApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final WalletApi instance = WalletApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> summary() async =>
      (await _client.get('/wallet/summary'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> transactions({
    int page = 1,
    String? type,
    String? direction,
  }) async =>
      _client.get(
        '/wallet/transactions',
        query: {
          'page': '$page',
          if (type != null && type.isNotEmpty) 'type': type,
          if (direction != null && direction.isNotEmpty) 'direction': direction,
        },
      );

  Future<Map<String, dynamic>> topUp({
    required int amountTc,
    String channel = 'qris_sandbox',
  }) async =>
      (await _client.post(
            '/wallet/top-up',
            body: {'amount_tc': amountTc, 'payment_channel': channel},
          ))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> recipients({String? query}) async {
    final rows = (await _client.get(
      '/wallet/recipients',
      query: {if (query != null && query.trim().isNotEmpty) 'q': query.trim()},
    ))['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> transfer({
    required String recipientIdentifier,
    required int amountTc,
  }) async =>
      (await _client.post(
            '/wallet/transfer',
            body: {
              'recipient_identifier': recipientIdentifier.trim(),
              'amount_tc': amountTc,
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> cashOut({
    required int amountTc,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async =>
      (await _client.post(
            '/wallet/cash-out',
            body: {
              'amount_tc': amountTc,
              'bank_name': bankName.trim(),
              'account_number': accountNumber.trim(),
              'account_holder_name': accountHolderName.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> bankAccounts() async {
    final rows = (await _client.get('/wallet/bank-accounts'))['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> storeBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    bool isPrimary = true,
  }) async =>
      (await _client.post(
            '/wallet/bank-accounts',
            body: {
              'bank_name': bankName.trim(),
              'account_number': accountNumber.trim(),
              'account_holder_name': accountHolderName.trim(),
              'is_primary': isPrimary,
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> rewards() async =>
      (await _client.get('/wallet/rewards'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> redeemReward(int rewardId) async =>
      (await _client.post('/wallet/rewards/$rewardId/redeem'))['data']
          as Map<String, dynamic>;
}

