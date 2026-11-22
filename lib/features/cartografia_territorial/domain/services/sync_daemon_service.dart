import 'dart:async';

import 'package:promap_sus/core/crypto/integridade.dart';
import 'package:promap_sus/core/network/connectivity_monitor.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';

/// Serviço de sincronização em segundo plano (seção 5.3, passos 2 e 3).
///
/// Ao detectar rede: lê pendências do Outbox, calcula o SHA-256 do payload,
/// envia via [ISyncApiAdapter] e marca como SINCRONIZADO somente após sucesso.
/// Em falha, interrompe (preservando a ordem) e mantém PENDENTE para a próxima
/// conexão - nunca perde nem descarta registros.
class SyncDaemonService {
  SyncDaemonService({
    required IFilaSincronizacaoRepository fila,
    required ISyncApiAdapter api,
    required ConnectivityMonitor conectividade,
  })  : _fila = fila,
        _api = api,
        _conectividade = conectividade;

  final IFilaSincronizacaoRepository _fila;
  final ISyncApiAdapter _api;
  final ConnectivityMonitor _conectividade;

  StreamSubscription<bool>? _assinatura;
  bool _executando = false;

  void iniciar() {
    _assinatura ??= _conectividade.onChange.listen((online) {
      if (online) unawaited(_tentarSilenciosamente());
    });
    unawaited(() async {
      if (await _conectividade.isOnline()) await _tentarSilenciosamente();
    }());
  }

  Future<void> parar() async {
    await _assinatura?.cancel();
    _assinatura = null;
  }

  Future<void> _tentarSilenciosamente() async {
    try {
      await sincronizarPendentes();
    } catch (_) {
      // Mantém os itens PENDENTES; nova tentativa na próxima mudança de rede.
    }
  }

  /// Retorna quantos itens foram sincronizados nesta execução.
  Future<int> sincronizarPendentes() async {
    if (_executando) return 0;
    _executando = true;
    var enviados = 0;
    try {
      final pendentes = await _fila.listarPendentes();
      for (final item in pendentes) {
        final pacote = PacoteSincronizacao(
          idItem: item.idItem,
          tabelaOrigem: item.tabelaOrigem,
          idRegistroLocal: item.idRegistroLocal,
          payloadJson: item.payloadJson,
          hashSha256: sha256Hex(item.payloadJson),
        );
        ResultadoEnvio resultado;
        try {
          resultado = await _api.enviar(pacote);
        } catch (e) {
          resultado = ResultadoEnvio.falha('$e');
        }
        if (!resultado.sucesso) break;
        await _fila.marcarComoSincronizado(item.idItem);
        enviados++;
      }
    } finally {
      _executando = false;
    }
    return enviados;
  }
}
