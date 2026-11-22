/// Parâmetros do Indicador de Acessibilidade Local (IAL).
///
/// ATENÇÃO - PROVISÓRIO: a especificação (RF03) diz que o IAL pondera
/// (1) grau de limitação motora, (2) distância até a UBS e (3) fatores de
/// barreira do trajeto, mas NÃO publica a equação, os pesos, a escala do grau
/// de limitação nem os limiares da sinaleira. Os valores de
/// [IalParametros.provisorio] são premissas de implementação e DEVEM ser
/// substituídos pelos valores validados pela equipe responsável.
/// Ver docs/LACUNAS_E_DECISOES_PENDENTES.md (itens L-01 a L-05).
class IalParametros {
  const IalParametros({
    this.pesoLimitacao = 0.40,
    this.pesoDistancia = 0.30,
    this.pesoBarreiras = 0.30,
    this.grauLimitacaoMin = 1,
    this.grauLimitacaoMax = 5,
    this.distanciaReferenciaMetros = 3000,
    this.limiteAmarelo = 35,
    this.limiteVermelho = 65,
  }) : assert(
          (pesoLimitacao + pesoDistancia + pesoBarreiras) > 0.999 &&
              (pesoLimitacao + pesoDistancia + pesoBarreiras) < 1.001,
          'Os pesos devem somar 1.',
        );

  const IalParametros.provisorio() : this();

  final double pesoLimitacao;
  final double pesoDistancia;
  final double pesoBarreiras;
  final int grauLimitacaoMin;
  final int grauLimitacaoMax;

  /// Distância a partir da qual o fator distância satura em 1,0.
  final double distanciaReferenciaMetros;

  /// IAL >= limiteAmarelo => amarelo; IAL >= limiteVermelho => vermelho.
  final double limiteAmarelo;
  final double limiteVermelho;
}
