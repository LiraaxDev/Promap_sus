/// Espelha `TB_PACIENTE_PCD`. Dados pessoais já protegidos (hash/cifra).
class PacientePCD {
  const PacientePCD({
    this.idPaciente,
    required this.cpfHash,
    required this.nomeCriptografado,
    required this.grauLimitacaoMotora,
    this.dataNascimento,
  });

  final int? idPaciente;
  final String cpfHash;
  final String nomeCriptografado;
  final int grauLimitacaoMotora;

  /// TEXT na especificação; usamos ISO-8601 (yyyy-MM-dd).
  final String? dataNascimento;
}
