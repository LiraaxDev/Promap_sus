import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Isolamento de Camadas da Arquitetura Hexagonal', () {
    List<File> obterArquivosDart(String caminhoRelativo) {
      final dir = Directory('lib/$caminhoRelativo');
      if (!dir.existsSync()) return [];
      return dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
    }

    test('Entidades e Objetos de Valor no Domínio não importam portas nem adaptadores', () {
      final arquivos = [
        ...obterArquivosDart('features/cartografia_territorial/domain/entities'),
        ...obterArquivosDart('features/cartografia_territorial/domain/value_objects'),
        ...obterArquivosDart('features/prontuario_cidadao/domain/entities'),
      ];

      for (final arquivo in arquivos) {
        final conteudo = arquivo.readAsStringSync();
        expect(
          conteudo.contains('/adapters/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: Entidade/VO não pode importar adaptadores.',
        );
        expect(
          conteudo.contains('/ports/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: Entidade/VO pura não pode importar portas.',
        );
      }
    });

    test('Portas de Entrada (Inbound Ports) não importam Adaptadores nem Portas Outbound', () {
      final arquivos = [
        ...obterArquivosDart('features/cartografia_territorial/ports/inbound'),
        ...obterArquivosDart('features/prontuario_cidadao/ports/inbound'),
      ];

      for (final arquivo in arquivos) {
        final conteudo = arquivo.readAsStringSync();
        expect(
          conteudo.contains('/adapters/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: Porta inbound não pode importar adaptadores.',
        );
        expect(
          conteudo.contains('/ports/outbound/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: Porta inbound não pode importar portas outbound.',
        );
      }
    });

    test('Adaptadores de Entrada (UI / Controllers) não importam Portas Outbound diretamente', () {
      final arquivos = [
        ...obterArquivosDart('features/cartografia_territorial/adapters/input'),
        ...obterArquivosDart('features/prontuario_cidadao/adapters/input'),
      ];

      for (final arquivo in arquivos) {
        final conteudo = arquivo.readAsStringSync();
        expect(
          conteudo.contains('/ports/outbound/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: UI / Controller deve depender exclusivamente de portas inbound.',
        );
        expect(
          conteudo.contains('sqflite'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: UI / Controller não pode ter dependência direta de banco de dados.',
        );
      }
    });

    test('Portas de Saída (Outbound Ports) não dependem de Adaptadores', () {
      final arquivos = [
        ...obterArquivosDart('features/cartografia_territorial/ports/outbound'),
        ...obterArquivosDart('features/prontuario_cidadao/ports/outbound'),
      ];

      for (final arquivo in arquivos) {
        final conteudo = arquivo.readAsStringSync();
        expect(
          conteudo.contains('/adapters/'),
          isFalse,
          reason: 'Violação em ${arquivo.path}: Contratos outbound não podem conhecer adaptadores.',
        );
      }
    });
  });
}
