import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Banco SQLite criptografado (SQLCipher / AES-256) - RNF02.
/// Esquema conforme a seção 4.3 (MER/DER).
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const versaoEsquema = 1;

  /// Abre (ou cria) o banco cifrado. A [senha] vem do [ChaveLocalProvider].
  static Future<AppDatabase> initEncrypted(
    String nomeArquivo, {
    required String senha,
  }) async {
    final pasta = await getDatabasesPath();
    final db = await openDatabase(
      p.join(pasta, nomeArquivo),
      password: senha,
      version: versaoEsquema,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, _) => criarEsquema(d),
    );
    return AppDatabase._(db);
  }

  static Future<void> criarEsquema(DatabaseExecutor d) async {
    await d.execute('''
      CREATE TABLE TB_PACIENTE_PCD (
        id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
        cpf_hash TEXT NOT NULL UNIQUE,
        nome_criptografado TEXT NOT NULL,
        grau_limitacao_motora INTEGER NOT NULL,
        data_nascimento TEXT
      )''');
    await d.execute('''
      CREATE TABLE TB_FICHA_TERRITORIAL (
        id_ficha INTEGER PRIMARY KEY AUTOINCREMENT,
        id_paciente INTEGER,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        tipo_acesso_via TEXT NOT NULL,
        presenca_escada_rampa INTEGER NOT NULL,
        valor_ial REAL NOT NULL,
        cor_sinaleira TEXT NOT NULL,
        data_coleta DATETIME NOT NULL,
        FOREIGN KEY (id_paciente) REFERENCES TB_PACIENTE_PCD (id_paciente)
      )''');
    await d.execute('''
      CREATE TABLE TB_FILA_SINCRONIZACAO (
        id_item INTEGER PRIMARY KEY AUTOINCREMENT,
        tabela_origem TEXT NOT NULL,
        id_registro_local INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        status_envio TEXT DEFAULT 'PENDENTE',
        timestamp_criacao DATETIME NOT NULL
      )''');
  }

  Future<void> close() => db.close();
}
