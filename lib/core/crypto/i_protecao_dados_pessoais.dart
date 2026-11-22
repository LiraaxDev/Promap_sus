/// Porta para proteção de campos pessoais em nível de coluna
/// (`cpf_hash` e `nome_criptografado` de TB_PACIENTE_PCD).
abstract class IProtecaoDadosPessoais {
  /// Hash determinístico do CPF (apenas dígitos), para busca e unicidade.
  Future<String> hashCpf(String cpfApenasDigitos);

  Future<String> cifrarNome(String nome);

  Future<String> decifrarNome(String nomeCriptografado);
}
