import 'dart:convert';

import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart' show AesGcm, SecretBox, SecretKey;
import 'package:promap_sus/core/crypto/chave_local_provider.dart';
import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';

/// - CPF: HMAC-SHA256 com chave local (um SHA-256 puro de CPF seria trivialmente
///   reversível por força bruta, dado o espaço de 11 dígitos).
/// - Nome: AES-256-GCM, nonce aleatório, saída em base64 (nonce + texto + MAC).
class ProtecaoDadosPessoaisAdapter implements IProtecaoDadosPessoais {
  ProtecaoDadosPessoaisAdapter(this._chaves);

  final ChaveLocalProvider _chaves;
  final AesGcm _aes = AesGcm.with256bits();

  @override
  Future<String> hashCpf(String cpfApenasDigitos) async {
    final chave = await _chaves.chaveCampos();
    return c.Hmac(c.sha256, chave)
        .convert(utf8.encode(cpfApenasDigitos))
        .toString();
  }

  @override
  Future<String> cifrarNome(String nome) async {
    final chave = SecretKey(await _chaves.chaveCampos());
    final caixa = await _aes.encrypt(utf8.encode(nome), secretKey: chave);
    return base64Encode(caixa.concatenation());
  }

  @override
  Future<String> decifrarNome(String nomeCriptografado) async {
    final chave = SecretKey(await _chaves.chaveCampos());
    final caixa = SecretBox.fromConcatenation(
      base64Decode(nomeCriptografado),
      nonceLength: 12,
      macLength: 16,
    );
    return utf8.decode(await _aes.decrypt(caixa, secretKey: chave));
  }
}
