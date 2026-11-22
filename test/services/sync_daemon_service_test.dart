import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/crypto/integridade.dart';
import 'package:promap_sus/core/network/connectivity_monitor.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/sync_daemon_service.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';

class _FilaFalsa implements IFilaSincronizacaoRepository {
  _FilaFalsa(List<String> payloads) {
    for (var i = 0; i < payloads.length; i++) {
      _status[i + 1] = ItemFilaSincronizacao.statusPendente;
      _payloads[i + 1] = payloads[i];
    }
  }
  final _status = <int, String>{};
  final _payloads = <int, String>{};

  String status(int id) => _status[id]!;

  @override
  Future<List<ItemFilaSincronizacao>> listarPendentes() async => [
        for (final e in _status.entries)
          if (e.value == ItemFilaSincronizacao.statusPendente)
            ItemFilaSincronizacao(
              idItem: e.key,
              tabelaOrigem: 'TB_FICHA_TERRITORIAL',
              idRegistroLocal: e.key,
              payloadJson: _payloads[e.key]!,
              statusEnvio: e.value,
              timestampCriacao: DateTime.utc(2026),
            ),
      ];

  @override
  Future<void> marcarComoSincronizado(int idItem) async =>
      _status[idItem] = ItemFilaSincronizacao.statusSincronizado;
}

class _ApiFalsa implements ISyncApiAdapter {
  _ApiFalsa({this.falharNoItem});
  final int? falharNoItem;
  final recebidos = <PacoteSincronizacao>[];

  @override
  Future<ResultadoEnvio> enviar(PacoteSincronizacao p) async {
    if (p.idItem == falharNoItem) return const ResultadoEnvio.falha('sem rede');
    recebidos.add(p);
    return const ResultadoEnvio.sucesso();
  }
}

class _ConectividadeFalsa implements ConnectivityMonitor {
  final controller = StreamController<bool>.broadcast();
  bool online = false;
  @override
  Future<bool> isOnline() async => online;
  @override
  Stream<bool> get onChange => controller.stream;
}

void main() {
  test('envia pendências com hash SHA-256 e marca como SINCRONIZADO', () async {
    final fila = _FilaFalsa(['{"a":1}', '{"b":2}']);
    final api = _ApiFalsa();
    final s = SyncDaemonService(fila: fila, api: api, conectividade: _ConectividadeFalsa());

    expect(await s.sincronizarPendentes(), 2);
    expect(fila.status(1), ItemFilaSincronizacao.statusSincronizado);
    expect(fila.status(2), ItemFilaSincronizacao.statusSincronizado);
    expect(api.recebidos.first.hashSha256, sha256Hex('{"a":1}'));
  });

  test('em falha mantém PENDENTE o item que falhou e os seguintes (ordem preservada)', () async {
    final fila = _FilaFalsa(['{"a":1}', '{"b":2}', '{"c":3}']);
    final s = SyncDaemonService(
      fila: fila,
      api: _ApiFalsa(falharNoItem: 2),
      conectividade: _ConectividadeFalsa(),
    );

    expect(await s.sincronizarPendentes(), 1);
    expect(fila.status(1), ItemFilaSincronizacao.statusSincronizado);
    expect(fila.status(2), ItemFilaSincronizacao.statusPendente);
    expect(fila.status(3), ItemFilaSincronizacao.statusPendente);
  });

  test('sincroniza automaticamente quando a rede volta', () async {
    final fila = _FilaFalsa(['{"a":1}']);
    final conn = _ConectividadeFalsa();
    final s = SyncDaemonService(fila: fila, api: _ApiFalsa(), conectividade: conn)..iniciar();

    await Future<void>.delayed(Duration.zero);
    expect(fila.status(1), ItemFilaSincronizacao.statusPendente); // offline

    conn.controller.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(fila.status(1), ItemFilaSincronizacao.statusSincronizado);
    await s.parar();
  });
}
