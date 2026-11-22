import 'package:promap_sus/core/errors/failures.dart';

/// Sinaleira de acessibilidade (RF02).
enum NivelAcessibilidade {
  /// Baixo risco e acesso adequado.
  verde('VERDE'),

  /// Risco moderado, obstáculos intermediários.
  amarelo('AMARELO'),

  /// Acessibilidade crítica e extrema restrição de mobilidade.
  vermelho('VERMELHO');

  const NivelAcessibilidade(this.codigo);

  /// Valor gravado em `TB_FICHA_TERRITORIAL.cor_sinaleira`.
  /// (O formato textual não é definido na especificação - ver lacunas.)
  final String codigo;

  static NivelAcessibilidade deCodigo(String codigo) => values.firstWhere(
        (e) => e.codigo == codigo,
        orElse: () =>
            throw ValidacaoException('Cor de sinaleira desconhecida: $codigo'),
      );
}
