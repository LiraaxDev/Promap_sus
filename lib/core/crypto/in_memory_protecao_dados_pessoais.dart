import 'dart:convert';
import 'package:crypto/crypto.dart' as c;
import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';

/// Implementação 100% em Dart puro de [IProtecaoDadosPessoais] para testes,
/// visualização em navegadores Web e plataformas desktop onde o SecureStorage
/// nativo pode não estar disponível.
class InMemoryProtecaoDadosPessoais implements IProtecaoDadosPessoais {
  InMemoryProtecaoDadosPessoais({String sal = 'promap_sus_test_salt'})
      : _sal = utf8.encode(sal);

  final List<int> _sal;

  @override
  Future<String> hashCpf(String cpfApenasDigitos) async {
    return c.Hmac(c.sha256, _sal)
        .convert(utf8.encode(cpfApenasDigitos))
        .toString();
  }

  @override
  Future<String> cifrarNome(String nome) async {
    final bytes = utf8.encode(nome);
    return 'ENC:${base64Encode(bytes)}';
  }

  @override
  Future<String> decifrarNome(String nomeCriptografado) async {
    final limpo = nomeCriptografado.startsWith('ENC:')
        ? nomeCriptografado.substring(4)
        : nomeCriptografado;
    return utf8.decode(base64Decode(limpo));
  }
}
