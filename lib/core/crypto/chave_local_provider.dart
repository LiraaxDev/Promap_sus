import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gera e guarda, no armazenamento seguro do SO (Keystore/Keychain), as chaves
/// locais: senha do SQLCipher (AES-256) e chave dos campos sensíveis.
///
/// DECISÃO PENDENTE: a especificação não define a gestão do ciclo de vida das
/// chaves (rotação, recuperação, descarte). Ver docs/LACUNAS_E_DECISOES_PENDENTES.md.
class ChaveLocalProvider {
  ChaveLocalProvider([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String> _obterOuGerar(String nome) async {
    var valor = await _storage.read(key: nome);
    if (valor == null) {
      final r = Random.secure();
      valor = base64Encode(List<int>.generate(32, (_) => r.nextInt(256)));
      await _storage.write(key: nome, value: valor);
    }
    return valor;
  }

  Future<String> senhaBanco() => _obterOuGerar('promap_db_key');

  Future<List<int>> chaveCampos() async =>
      base64Decode(await _obterOuGerar('promap_field_key'));
}
