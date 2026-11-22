import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';

/// Acesso à tabela Outbox `TB_FILA_SINCRONIZACAO` pelo serviço de sincronização.
abstract class IFilaSincronizacaoRepository {
  /// Itens com `status_envio = 'PENDENTE'`, do mais antigo para o mais novo.
  Future<List<ItemFilaSincronizacao>> listarPendentes();

  Future<void> marcarComoSincronizado(int idItem);
}
