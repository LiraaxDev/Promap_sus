import 'package:flutter/material.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';

Color corDaSinaleira(NivelAcessibilidade n) => switch (n) {
      NivelAcessibilidade.verde => const Color(0xFF1B7F3B),
      NivelAcessibilidade.amarelo => const Color(0xFFB8860B),
      NivelAcessibilidade.vermelho => const Color(0xFFB3261E),
    };

String rotuloDaSinaleira(NivelAcessibilidade n) => switch (n) {
      NivelAcessibilidade.verde => 'Verde - acesso adequado',
      NivelAcessibilidade.amarelo => 'Amarelo - obstáculos intermediários',
      NivelAcessibilidade.vermelho => 'Vermelho - acessibilidade crítica',
    };

/// Selo da sinaleira: a informação nunca depende só da cor (WCAG 1.4.1) -
/// há rótulo textual e descrição para leitores de tela (TalkBack/VoiceOver).
class SinaleiraBadge extends StatelessWidget {
  const SinaleiraBadge({super.key, required this.nivel, required this.valorIal});

  final NivelAcessibilidade nivel;
  final double valorIal;

  @override
  Widget build(BuildContext context) {
    final texto = rotuloDaSinaleira(nivel);
    return Semantics(
      container: true,
      label: 'Sinaleira de acessibilidade: $texto. '
          'Indicador de acessibilidade local: ${valorIal.toStringAsFixed(1)}.',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: corDaSinaleira(nivel),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$texto\nIAL: ${valorIal.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
