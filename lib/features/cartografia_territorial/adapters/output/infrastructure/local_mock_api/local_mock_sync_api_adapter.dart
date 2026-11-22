import 'dart:developer' as dev;

import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';

/// Simulador de sincronização para desenvolvimento local (RNF03): registra log
/// e retorna sucesso, sem qualquer acesso à rede.
class LocalMockSyncApiAdapter implements ISyncApiAdapter {
  /// Pacotes "enviados" - útil para inspeção em testes.
  final List<PacoteSincronizacao> enviados = [];

  @override
  Future<ResultadoEnvio> enviar(PacoteSincronizacao pacote) async {
    enviados.add(pacote);
    dev.log(
      'MOCK sync item=${pacote.idItem} tabela=${pacote.tabelaOrigem} '
      'sha256=${pacote.hashSha256}',
      name: 'promap.sync',
    );
    return const ResultadoEnvio.sucesso();
  }
}
