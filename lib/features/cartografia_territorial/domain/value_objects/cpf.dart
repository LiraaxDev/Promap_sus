import 'package:promap_sus/core/errors/failures.dart';

/// CPF válido (dígitos verificadores conferidos). Guarda apenas os dígitos.
class Cpf {
  Cpf._(this.digitos);

  factory Cpf(String entrada) {
    final d = entrada.replaceAll(RegExp(r'\D'), '');
    if (!_valido(d)) throw const ValidacaoException('CPF inválido.');
    return Cpf._(d);
  }

  final String digitos;

  static bool _valido(String d) {
    if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;
    int dv(int n) {
      var soma = 0;
      for (var i = 0; i < n; i++) {
        soma += int.parse(d[i]) * (n + 1 - i);
      }
      final r = (soma * 10) % 11;
      return r == 10 ? 0 : r;
    }

    return dv(9) == int.parse(d[9]) && dv(10) == int.parse(d[10]);
  }
}
