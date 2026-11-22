import 'package:promap_sus/core/errors/failures.dart';

/// Coluna `tipo_acesso_via` (TEXT).
///
/// PROVISÓRIO: a especificação não lista os valores possíveis nem seus pesos.
/// Valores e pesos abaixo são premissas de implementação, a validar com as ACS.
enum TipoAcessoVia {
  pavimentada('PAVIMENTADA', 0.0),
  calcadaIrregular('CALCADA_IRREGULAR', 0.4),
  vielaNaoPavimentada('VIELA_NAO_PAVIMENTADA', 0.7),
  escadaria('ESCADARIA', 1.0);

  const TipoAcessoVia(this.codigo, this.pesoBarreira);

  final String codigo;
  final double pesoBarreira;

  static TipoAcessoVia deCodigo(String codigo) => values.firstWhere(
        (e) => e.codigo == codigo,
        orElse: () =>
            throw ValidacaoException('Tipo de acesso desconhecido: $codigo'),
      );
}
