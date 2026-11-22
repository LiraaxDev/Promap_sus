import 'dart:convert';

import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/app_database.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';

/// Persistência criptografada local + Transactional Outbox (seção 5.3, passo 1).
class SqliteFichaRepository implements IFichaRepository {
  SqliteFichaRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<int> salvarLocamente(PacientePCD paciente, FichaTerritorial ficha) async {
    try {
      return await _db.db.transaction((txn) async {
        // 1) Paciente: reaproveita pelo cpf_hash (UNIQUE) e atualiza dados.
        final existente = await txn.query(
          'TB_PACIENTE_PCD',
          columns: ['id_paciente'],
          where: 'cpf_hash = ?',
          whereArgs: [paciente.cpfHash],
          limit: 1,
        );
        final dadosPaciente = <String, Object?>{
          'cpf_hash': paciente.cpfHash,
          'nome_criptografado': paciente.nomeCriptografado,
          'grau_limitacao_motora': paciente.grauLimitacaoMotora,
          'data_nascimento': paciente.dataNascimento,
        };
        final int idPaciente;
        if (existente.isNotEmpty) {
          idPaciente = existente.first['id_paciente']! as int;
          await txn.update('TB_PACIENTE_PCD', dadosPaciente,
              where: 'id_paciente = ?', whereArgs: [idPaciente]);
        } else {
          idPaciente = await txn.insert('TB_PACIENTE_PCD', dadosPaciente);
        }

        // 2) Ficha territorial (cada coleta gera um novo registro - histórico).
        final dadosFicha = <String, Object?>{
          'id_paciente': idPaciente,
          'latitude': ficha.coordenada.latitude,
          'longitude': ficha.coordenada.longitude,
          'tipo_acesso_via': ficha.tipoAcessoVia.codigo,
          'presenca_escada_rampa': ficha.presencaEscadaRampa.codigo,
          'valor_ial': ficha.valorIal,
          'cor_sinaleira': ficha.nivel.codigo,
          'data_coleta': ficha.dataColeta.toUtc().toIso8601String(),
        };
        final idFicha = await txn.insert('TB_FICHA_TERRITORIAL', dadosFicha);

        // 3) Outbox: mesma transação => ou grava tudo, ou nada.
        final payload = jsonEncode({
          'paciente': dadosPaciente,
          'ficha': {'id_ficha': idFicha, ...dadosFicha},
        });
        await txn.insert('TB_FILA_SINCRONIZACAO', {
          'tabela_origem': 'TB_FICHA_TERRITORIAL',
          'id_registro_local': idFicha,
          'payload_json': payload,
          'status_envio': ItemFilaSincronizacao.statusPendente,
          'timestamp_criacao': DateTime.now().toUtc().toIso8601String(),
        });
        return idFicha;
      });
    } catch (e) {
      throw PersistenciaException('Falha ao gravar a ficha localmente: $e');
    }
  }

  @override
  Future<List<FichaTerritorial>> listarFichas() async {
    final rows = await _db.db
        .query('TB_FICHA_TERRITORIAL', orderBy: 'data_coleta DESC');
    return rows
        .map((r) => FichaTerritorial(
              idFicha: r['id_ficha']! as int,
              idPaciente: r['id_paciente'] as int?,
              coordenada: CoordenadaGPS(
                (r['latitude']! as num).toDouble(),
                (r['longitude']! as num).toDouble(),
              ),
              tipoAcessoVia: TipoAcessoVia.deCodigo(r['tipo_acesso_via']! as String),
              presencaEscadaRampa:
                  PresencaEscadaRampa.deCodigo(r['presenca_escada_rampa']! as int),
              valorIal: (r['valor_ial']! as num).toDouble(),
              nivel: NivelAcessibilidade.deCodigo(r['cor_sinaleira']! as String),
              dataColeta: DateTime.parse(r['data_coleta']! as String),
            ))
        .toList();
  }
}
