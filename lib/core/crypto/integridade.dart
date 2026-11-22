import 'dart:convert';

import 'package:crypto/crypto.dart' as c;

/// Hash SHA-256 (hex) usado na verificação de integridade do Outbox (seção 5.3).
String sha256Hex(String texto) => c.sha256.convert(utf8.encode(texto)).toString();
