import 'package:promap_sus/core/errors/failures.dart';

/// Coluna `presenca_escada_rampa` (INTEGER).
///
/// PROVISÓRIO: a especificação define apenas o tipo INTEGER. A codificação
/// abaixo é uma premissa de implementação, a validar.
enum PresencaEscadaRampa {
  nenhuma(0, 0.0),
  rampa(1, 0.2),
  escadaComRampa(2, 0.5),
  escada(3, 1.0);

  const PresencaEscadaRampa(this.codigo, this.pesoBarreira);

  final int codigo;
  final double pesoBarreira;

  static PresencaEscadaRampa deCodigo(int codigo) => values.firstWhere(
        (e) => e.codigo == codigo,
        orElse: () => throw ValidacaoException(
            'Código escada/rampa desconhecido: $codigo'),
      );
}
