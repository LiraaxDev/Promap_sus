import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/app_database.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/i_consulta_ficha_local_repository.dart';

class SqliteConsultaFichaRepository implements IConsultaFichaLocalRepository {
  SqliteConsultaFichaRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<FichaTerritorialConsulta?> ultimaFichaPorCpfHash(String cpfHash) async {
    final rows = await _db.db.rawQuery('''
      SELECT f.valor_ial, f.cor_sinaleira, f.data_coleta, f.latitude, f.longitude
      FROM TB_FICHA_TERRITORIAL f
      JOIN TB_PACIENTE_PCD p ON p.id_paciente = f.id_paciente
      WHERE p.cpf_hash = ?
      ORDER BY f.data_coleta DESC
      LIMIT 1''', [cpfHash]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return FichaTerritorialConsulta(
      valorIal: (r['valor_ial']! as num).toDouble(),
      nivel: NivelAcessibilidade.deCodigo(r['cor_sinaleira']! as String),
      dataColeta: DateTime.parse(r['data_coleta']! as String),
      latitude: (r['latitude']! as num).toDouble(),
      longitude: (r['longitude']! as num).toDouble(),
    );
  }
}
