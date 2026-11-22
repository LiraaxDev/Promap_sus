import 'package:flutter/foundation.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';

/// Controller da UI do Cidadão (Adaptador de Entrada).
/// Depende ESTRITAMENTE da porta de entrada [IConsultaFichaCidadao].
/// A lógica de hash, criptografia e acesso a dados está completamente isolada no use case.
class CidadaoController extends ChangeNotifier {
  CidadaoController({
    required IConsultaFichaCidadao consulta,
  }) : _consulta = consulta;

  final IConsultaFichaCidadao _consulta;

  bool carregando = false;
  bool consultou = false;
  String? erro;
  FichaTerritorialConsulta? ficha;

  Future<void> consultar(String cpfDigitado) async {
    carregando = true;
    erro = null;
    ficha = null;
    notifyListeners();
    try {
      ficha = await _consulta.executar(cpfDigitado);
      consultou = true;
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
