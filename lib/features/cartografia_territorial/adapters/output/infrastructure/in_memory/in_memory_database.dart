import 'dart:convert';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/outbound/i_consulta_ficha_local_repository.dart';

/// Banco de dados e repositórios 100% em memória para desenvolvimento, testes e visualização.
/// Não depende de bibliotecas nativas C (SQLCipher), executando em Web, Windows, Android, iOS e testes.
class InMemoryDatabase
    implements
        IFichaRepository,
        IFilaSincronizacaoRepository,
        IConsultaFichaLocalRepository {
  InMemoryDatabase({bool preencherDadosDemonstracao = false}) {
    if (preencherDadosDemonstracao) {
      carregarDadosDemonstracao();
    }
  }

  int _proximoIdPaciente = 1;
  int _proximoIdFicha = 1;
  int _proximoIdFila = 1;

  final List<Map<String, dynamic>> pacientes = [];
  final List<Map<String, dynamic>> fichas = [];
  final List<Map<String, dynamic>> fila = [];

  void limpar() {
    pacientes.clear();
    fichas.clear();
    fila.clear();
    _proximoIdPaciente = 1;
    _proximoIdFicha = 1;
    _proximoIdFila = 1;
  }

  void carregarDadosDemonstracao() {
    limpar();
    final agora = DateTime.now().toUtc();

    // 1. Paciente Verde (baixa barreira, via pavimentada)
    _inserirDemonstracao(
      cpfHash: 'hash_cpf_verde_001',
      nomeCriptografado: 'Maria da Silva (Demo)',
      grauLimitacao: 1,
      coordenada: CoordenadaGPS(-23.550520, -46.633308),
      tipoVia: TipoAcessoVia.pavimentada,
      escadaRampa: PresencaEscadaRampa.rampa,
      valorIal: 15.0,
      nivel: NivelAcessibilidade.verde,
      dataColeta: agora.subtract(const Duration(days: 2)),
    );

    // 2. Paciente Amarelo (barreiras moderadas)
    _inserirDemonstracao(
      cpfHash: 'hash_cpf_amarelo_002',
      nomeCriptografado: 'João Santos (Demo)',
      grauLimitacao: 3,
      coordenada: CoordenadaGPS(-23.552100, -46.634500),
      tipoVia: TipoAcessoVia.calcadaIrregular,
      escadaRampa: PresencaEscadaRampa.escadaComRampa,
      valorIal: 48.5,
      nivel: NivelAcessibilidade.amarelo,
      dataColeta: agora.subtract(const Duration(days: 1)),
    );

    // 3. Paciente Vermelho (alta barreira motora + escadaria)
    _inserirDemonstracao(
      cpfHash: 'hash_cpf_vermelho_003',
      nomeCriptografado: 'Ana Oliveira (Demo)',
      grauLimitacao: 5,
      coordenada: CoordenadaGPS(-23.555000, -46.639000),
      tipoVia: TipoAcessoVia.escadaria,
      escadaRampa: PresencaEscadaRampa.escada,
      valorIal: 85.0,
      nivel: NivelAcessibilidade.vermelho,
      dataColeta: agora,
    );
  }

  void _inserirDemonstracao({
    required String cpfHash,
    required String nomeCriptografado,
    required int grauLimitacao,
    required CoordenadaGPS coordenada,
    required TipoAcessoVia tipoVia,
    required PresencaEscadaRampa escadaRampa,
    required double valorIal,
    required NivelAcessibilidade nivel,
    required DateTime dataColeta,
  }) {
    final idPaciente = _proximoIdPaciente++;
    pacientes.add({
      'id_paciente': idPaciente,
      'cpf_hash': cpfHash,
      'nome_criptografado': nomeCriptografado,
      'grau_limitacao_motora': grauLimitacao,
      'data_nascimento': '1985-05-15',
    });

    final idFicha = _proximoIdFicha++;
    fichas.add({
      'id_ficha': idFicha,
      'id_paciente': idPaciente,
      'latitude': coordenada.latitude,
      'longitude': coordenada.longitude,
      'tipo_acesso_via': tipoVia.codigo,
      'presenca_escada_rampa': escadaRampa.codigo,
      'valor_ial': valorIal,
      'cor_sinaleira': nivel.codigo,
      'data_coleta': dataColeta.toIso8601String(),
    });

    final idFila = _proximoIdFila++;
    fila.add({
      'id_item': idFila,
      'tabela_origem': 'TB_FICHA_TERRITORIAL',
      'id_registro_local': idFicha,
      'payload_json': jsonEncode({'id_ficha': idFicha, 'ial': valorIal}),
      'status_envio': ItemFilaSincronizacao.statusPendente,
      'timestamp_criacao': dataColeta.toIso8601String(),
    });
  }

  // --- IFichaRepository ---

  @override
  Future<int> salvarLocamente(PacientePCD paciente, FichaTerritorial ficha) async {
    int idPaciente;
    final index = pacientes.indexWhere((p) => p['cpf_hash'] == paciente.cpfHash);
    final dadosPaciente = <String, Object?>{
      'cpf_hash': paciente.cpfHash,
      'nome_criptografado': paciente.nomeCriptografado,
      'grau_limitacao_motora': paciente.grauLimitacaoMotora,
      'data_nascimento': paciente.dataNascimento,
    };

    if (index >= 0) {
      idPaciente = pacientes[index]['id_paciente'] as int;
      pacientes[index] = {'id_paciente': idPaciente, ...dadosPaciente};
    } else {
      idPaciente = _proximoIdPaciente++;
      pacientes.add({'id_paciente': idPaciente, ...dadosPaciente});
    }

    final idFicha = _proximoIdFicha++;
    final dadosFicha = <String, Object?>{
      'id_ficha': idFicha,
      'id_paciente': idPaciente,
      'latitude': ficha.coordenada.latitude,
      'longitude': ficha.coordenada.longitude,
      'tipo_acesso_via': ficha.tipoAcessoVia.codigo,
      'presenca_escada_rampa': ficha.presencaEscadaRampa.codigo,
      'valor_ial': ficha.valorIal,
      'cor_sinaleira': ficha.nivel.codigo,
      'data_coleta': ficha.dataColeta.toUtc().toIso8601String(),
    };
    fichas.insert(0, dadosFicha);

    final payload = jsonEncode({
      'paciente': dadosPaciente,
      'ficha': dadosFicha,
    });

    final idItem = _proximoIdFila++;
    fila.add({
      'id_item': idItem,
      'tabela_origem': 'TB_FICHA_TERRITORIAL',
      'id_registro_local': idFicha,
      'payload_json': payload,
      'status_envio': ItemFilaSincronizacao.statusPendente,
      'timestamp_criacao': DateTime.now().toUtc().toIso8601String(),
    });

    return idFicha;
  }

  @override
  Future<List<FichaTerritorial>> listarFichas() async {
    return fichas.map((r) {
      return FichaTerritorial(
        idFicha: r['id_ficha'] as int,
        idPaciente: r['id_paciente'] as int?,
        coordenada: CoordenadaGPS(
          (r['latitude'] as num).toDouble(),
          (r['longitude'] as num).toDouble(),
        ),
        tipoAcessoVia: TipoAcessoVia.deCodigo(r['tipo_acesso_via'] as String),
        presencaEscadaRampa: PresencaEscadaRampa.deCodigo(r['presenca_escada_rampa'] as int),
        valorIal: (r['valor_ial'] as num).toDouble(),
        nivel: NivelAcessibilidade.deCodigo(r['cor_sinaleira'] as String),
        dataColeta: DateTime.parse(r['data_coleta'] as String),
      );
    }).toList();
  }

  // --- IFilaSincronizacaoRepository ---

  @override
  Future<List<ItemFilaSincronizacao>> listarPendentes() async {
    return fila
        .where((f) => f['status_envio'] == ItemFilaSincronizacao.statusPendente)
        .map((r) => ItemFilaSincronizacao(
              idItem: r['id_item'] as int,
              tabelaOrigem: r['tabela_origem'] as String,
              idRegistroLocal: r['id_registro_local'] as int,
              payloadJson: r['payload_json'] as String,
              statusEnvio: r['status_envio'] as String,
              timestampCriacao: DateTime.parse(r['timestamp_criacao'] as String),
            ))
        .toList();
  }

  @override
  Future<void> marcarComoSincronizado(int idItem) async {
    final idx = fila.indexWhere((item) => item['id_item'] == idItem);
    if (idx >= 0) {
      fila[idx]['status_envio'] = ItemFilaSincronizacao.statusSincronizado;
    }
  }

  // --- IConsultaFichaLocalRepository ---

  @override
  Future<FichaTerritorialConsulta?> ultimaFichaPorCpfHash(String cpfHash) async {
    final pac = pacientes.where((p) => p['cpf_hash'] == cpfHash).toList();
    if (pac.isEmpty) return null;
    final idPaciente = pac.first['id_paciente'] as int;

    final fichasPaciente = fichas.where((f) => f['id_paciente'] == idPaciente).toList();
    if (fichasPaciente.isEmpty) return null;

    fichasPaciente.sort((a, b) =>
        DateTime.parse(b['data_coleta'] as String).compareTo(DateTime.parse(a['data_coleta'] as String)));
    final r = fichasPaciente.first;

    return FichaTerritorialConsulta(
      valorIal: (r['valor_ial'] as num).toDouble(),
      nivel: NivelAcessibilidade.deCodigo(r['cor_sinaleira'] as String),
      dataColeta: DateTime.parse(r['data_coleta'] as String),
      latitude: (r['latitude'] as num).toDouble(),
      longitude: (r['longitude'] as num).toDouble(),
    );
  }
}
