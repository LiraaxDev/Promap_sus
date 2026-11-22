import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';

/// Adaptador de produção: HTTP POST (JSON) para a API centralizada do SUS.
///
/// PENDENTE: URL, autenticação e contrato da API do servidor corporativo não
/// são especificados. O [endpoint] é injetado por configuração
/// (--dart-define=PROMAP_API_URL=...). Sucesso = HTTP 2xx.
/// Obs.: o envio por HTTPS/TLS é delegado à plataforma; forçar TLS 1.3 exige
/// configuração nativa (ver lacuna L-12).
class HttpCentralServerApiAdapter implements ISyncApiAdapter {
  HttpCentralServerApiAdapter({
    required http.Client client,
    required Uri endpoint,
    Duration timeout = const Duration(seconds: 30),
  })  : _client = client,
        _endpoint = endpoint,
        _timeout = timeout;

  final http.Client _client;
  final Uri _endpoint;
  final Duration _timeout;

  @override
  Future<ResultadoEnvio> enviar(PacoteSincronizacao pacote) async {
    try {
      final resposta = await _client
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'X-Payload-SHA256': pacote.hashSha256,
            },
            body: jsonEncode({
              'id_item': pacote.idItem,
              'tabela_origem': pacote.tabelaOrigem,
              'id_registro_local': pacote.idRegistroLocal,
              'payload_sha256': pacote.hashSha256,
              'payload_json': pacote.payloadJson,
            }),
          )
          .timeout(_timeout);
      if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
        return const ResultadoEnvio.sucesso();
      }
      return ResultadoEnvio.falha('HTTP ${resposta.statusCode}');
    } on Exception catch (e) {
      return ResultadoEnvio.falha('$e');
    }
  }
}
