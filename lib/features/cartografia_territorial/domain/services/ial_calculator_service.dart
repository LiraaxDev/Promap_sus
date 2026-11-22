import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_parametros.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';

class ResultadoIAL {
  const ResultadoIAL({required this.valor, required this.nivel});

  /// Escala 0-100; quanto MAIOR, maior a restrição de acesso.
  final double valor;
  final NivelAcessibilidade nivel;
}

/// Representa um fator individual que compõe o cálculo do IAL.
/// Incorpora a lógica funcional ponderada inspirada na modelagem de cálculo motor.
class ComponenteIAL {
  const ComponenteIAL({required this.valor, required this.peso});

  final double valor;
  final double peso;
}

/// Serviço de domínio puro (sem dependência de UI, banco ou rede): calcula o
/// IAL e a cor da sinaleira, de forma 100% offline (RF02, RF03, RNF01).
///
/// Utiliza agregação por média ponderada de componentes normalizados em [0, 1].
class IalCalculatorService {
  const IalCalculatorService({this.parametros = const IalParametros.provisorio()});

  final IalParametros parametros;

  /// Agregação robusta de componentes ponderados.
  double calcularMediaPonderada(List<ComponenteIAL> componentes) {
    if (componentes.isEmpty) {
      throw const ValidacaoException('Nenhum componente informado para o cálculo do IAL.');
    }

    if (componentes.any((c) =>
        !c.valor.isFinite ||
        !c.peso.isFinite ||
        c.valor < 0 ||
        c.valor > 1 ||
        c.peso < 0)) {
      throw const ValidacaoException('Componente de cálculo ou peso com valor inválido.');
    }

    final somaPonderada = componentes.fold<double>(0.0, (acc, c) => acc + (c.valor * c.peso));
    final somaPesos = componentes.fold<double>(0.0, (acc, c) => acc + c.peso);

    if (somaPesos <= 0) {
      throw const ValidacaoException('A soma dos pesos do IAL deve ser positiva.');
    }

    return (somaPonderada / somaPesos) * 100;
  }

  ResultadoIAL calcular({
    required int grauLimitacaoMotora,
    required double distanciaUbsMetros,
    required TipoAcessoVia tipoAcessoVia,
    required PresencaEscadaRampa presencaEscadaRampa,
  }) {
    final p = parametros;
    if (grauLimitacaoMotora < p.grauLimitacaoMin ||
        grauLimitacaoMotora > p.grauLimitacaoMax) {
      throw ValidacaoException(
        'Grau de limitação motora deve estar entre '
        '${p.grauLimitacaoMin} e ${p.grauLimitacaoMax}.',
      );
    }
    if (!distanciaUbsMetros.isFinite || distanciaUbsMetros < 0) {
      throw const ValidacaoException('Distância até a UBS inválida.');
    }

    final limitacaoNormalizada = (grauLimitacaoMotora - p.grauLimitacaoMin) /
        (p.grauLimitacaoMax - p.grauLimitacaoMin);
    final distanciaNormalizada =
        (distanciaUbsMetros / p.distanciaReferenciaMetros).clamp(0.0, 1.0);

    // Componentes individuais ponderados
    final componentes = [
      ComponenteIAL(
        valor: limitacaoNormalizada,
        peso: p.pesoLimitacao,
      ),
      ComponenteIAL(
        valor: distanciaNormalizada,
        peso: p.pesoDistancia,
      ),
      ComponenteIAL(
        valor: tipoAcessoVia.pesoBarreira,
        peso: p.pesoBarreiras * 0.5,
      ),
      ComponenteIAL(
        valor: presencaEscadaRampa.pesoBarreira,
        peso: p.pesoBarreiras * 0.5,
      ),
    ];

    final bruto = calcularMediaPonderada(componentes);
    final valor = (bruto * 100).roundToDouble() / 100;

    final nivel = valor >= p.limiteVermelho
        ? NivelAcessibilidade.vermelho
        : valor >= p.limiteAmarelo
            ? NivelAcessibilidade.amarelo
            : NivelAcessibilidade.verde;

    return ResultadoIAL(valor: valor, nivel: nivel);
  }
}
