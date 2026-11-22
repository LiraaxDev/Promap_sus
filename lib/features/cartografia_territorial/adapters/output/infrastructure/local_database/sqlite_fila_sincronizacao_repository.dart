import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/app_database.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';

class SqliteFilaSincronizacaoRepository implements IFilaSincronizacaoRepository {
  SqliteFilaSincronizacaoRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<List<ItemFilaSincronizacao>> listarPendentes() async {
    final rows = await _db.db.query(
      'TB_FILA_SINCRONIZACAO',
      where: 'status_envio = ?',
      whereArgs: [ItemFilaSincronizacao.statusPendente],
      orderBy: 'id_item ASC',
    );
    return rows
        .map((r) => ItemFilaSincronizacao(
              idItem: r['id_item']! as int,
              tabelaOrigem: r['tabela_origem']! as String,
              idRegistroLocal: r['id_registro_local']! as int,
              payloadJson: r['payload_json']! as String,
              statusEnvio: r['status_envio']! as String,
              timestampCriacao: DateTime.parse(r['timestamp_criacao']! as String),
            ))
        .toList();
  }

  @override
  Future<void> marcarComoSincronizado(int idItem) async {
    await _db.db.update(
      'TB_FILA_SINCRONIZACAO',
      {'status_envio': ItemFilaSincronizacao.statusSincronizado},
      where: 'id_item = ?',
      whereArgs: [idItem],
    );
  }
}
