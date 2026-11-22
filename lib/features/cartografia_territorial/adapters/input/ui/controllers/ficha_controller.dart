import 'package:flutter/foundation.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';

/// Controller da UI da ACS (Adaptador de Entrada).
/// Depende ESTRITAMENTE de Portas de Entrada (Inbound Ports / UseCases).
/// Nunca se comunica diretamente com infraestrutura nem com portas outbound.
class FichaController extends ChangeNotifier {
  FichaController({
    required IRegistraFichaTerritorial registra,
    required ICapturarLocalizacao capturarLocalizacao,
    required IListarFichasTerritoriais listarFichas,
  })  : _registra = registra,
        _capturarLocalizacao = capturarLocalizacao,
        _listarFichas = listarFichas;

  final IRegistraFichaTerritorial _registra;
  final ICapturarLocalizacao _capturarLocalizacao;
  final IListarFichasTerritoriais _listarFichas;

  bool carregando = false;
  String? erro;
  CoordenadaGPS? posicaoAtual;
  ResultadoRegistro? ultimoResultado;
  List<FichaTerritorial> fichasColetadas = const [];

  Future<void> capturarGps() => _executar(() async {
        posicaoAtual = await _capturarLocalizacao.executar();
      });

  Future<void> salvarFicha({
    required String nome,
    required String cpf,
    String? dataNascimento,
    required int grauLimitacaoMotora,
    required double ubsLatitude,
    required double ubsLongitude,
    required TipoAcessoVia tipoAcessoVia,
    required PresencaEscadaRampa presencaEscadaRampa,
  }) =>
      _executar(() async {
        final residencia = posicaoAtual;
        if (residencia == null) {
          throw const ValidacaoException(
              'Capture a posição GPS da residência antes de salvar.');
        }
        ultimoResultado = await _registra.executar(RegistraFichaCommand(
          nome: nome,
          cpf: cpf,
          dataNascimento: dataNascimento,
          grauLimitacaoMotora: grauLimitacaoMotora,
          residencia: residencia,
          ubsReferencia: CoordenadaGPS(ubsLatitude, ubsLongitude),
          tipoAcessoVia: tipoAcessoVia,
          presencaEscadaRampa: presencaEscadaRampa,
        ));
      });

  Future<void> carregarFichas() => _executar(() async {
        fichasColetadas = await _listarFichas.executar();
      });

  Future<void> _executar(Future<void> Function() acao) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      await acao();
    } on PromapException catch (e) {
      erro = e.mensagem;
    } catch (_) {
      erro = 'Ocorreu um erro inesperado. Tente novamente.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
