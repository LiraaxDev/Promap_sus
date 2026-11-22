import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/network/connectivity_monitor.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/sync_daemon_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/sincronizar_fichas_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';

class _FilaMock implements IFilaSincronizacaoRepository {
  final List<ItemFilaSincronizacao> pendentes = [];
  final List<int> sincronizados = [];

  @override
  Future<List<ItemFilaSincronizacao>> listarPendentes() async => List.of(pendentes);

  @override
  Future<void> marcarComoSincronizado(int idItem) async {
    sincronizados.add(idItem);
    pendentes.removeWhere((p) => p.idItem == idItem);
  }
}

class _ApiMock implements ISyncApiAdapter {
  @override
  Future<ResultadoEnvio> enviar(PacoteSincronizacao pacote) async =>
      const ResultadoEnvio.sucesso();
}

class _RedeOnline implements ConnectivityMonitor {
  @override
  Future<bool> isOnline() async => true;
  @override
  Stream<bool> get onChange => const Stream.empty();
}

void main() {
  test('SincronizarFichasUseCase comanda a sincronização das pendências outbox', () async {
    final fila = _FilaMock();
    fila.pendentes.add(ItemFilaSincronizacao(
      idItem: 1,
      tabelaOrigem: 'TB_FICHA_TERRITORIAL',
      idRegistroLocal: 100,
      payloadJson: '{"id": 100}',
      statusEnvio: ItemFilaSincronizacao.statusPendente,
      timestampCriacao: DateTime.utc(2026, 1, 1),
    ));

    final daemon = SyncDaemonService(
      fila: fila,
      api: _ApiMock(),
      conectividade: _RedeOnline(),
    );

    final useCase = SincronizarFichasUseCase(daemon);
    final enviados = await useCase.executar();

    expect(enviados, 1);
    expect(fila.sincronizados, contains(1));
    expect(fila.pendentes, isEmpty);
  });
}
