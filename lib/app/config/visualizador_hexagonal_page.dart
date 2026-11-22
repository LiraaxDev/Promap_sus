import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/sinaleira_visual.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_sincronizar_fichas.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';

/// Painel interativo de Visualização e Teste da Arquitetura Hexagonal.
/// Permite que avaliadores, desenvolvedores e testadores inspecionem as camadas,
/// testem as portas inbound em tempo real e visualizem os componentes gráficos.
class VisualizadorHexagonalPage extends StatefulWidget {
  const VisualizadorHexagonalPage({super.key});

  @override
  State<VisualizadorHexagonalPage> createState() => _VisualizadorHexagonalPageState();
}

class _VisualizadorHexagonalPageState extends State<VisualizadorHexagonalPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _logsExecucao = [];
  bool _executando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _adicionarLog(String mensagem) {
    setState(() {
      final horario = DateTime.now().toIso8601String().substring(11, 19);
      _logsExecucao.insert(0, '[$horario] $mensagem');
    });
  }

  Future<void> _testarRegistro(String cenario) async {
    setState(() => _executando = true);
    try {
      final registra = getIt<IRegistraFichaTerritorial>();
      RegistraFichaCommand comando;

      if (cenario == 'verde') {
        comando = RegistraFichaCommand(
          nome: 'Carlos Eduardo Verde',
          cpf: '529.982.247-25',
          grauLimitacaoMotora: 1,
          residencia: CoordenadaGPS(-23.550520, -46.633308),
          ubsReferencia: CoordenadaGPS(-23.550520, -46.633308),
          tipoAcessoVia: TipoAcessoVia.pavimentada,
          presencaEscadaRampa: PresencaEscadaRampa.rampa,
        );
      } else if (cenario == 'amarelo') {
        comando = RegistraFichaCommand(
          nome: 'Beatriz Lima Amarelo',
          cpf: '529.982.247-25',
          grauLimitacaoMotora: 3,
          residencia: CoordenadaGPS(-23.550520, -46.633308),
          ubsReferencia: CoordenadaGPS(-23.558000, -46.633308),
          tipoAcessoVia: TipoAcessoVia.calcadaIrregular,
          presencaEscadaRampa: PresencaEscadaRampa.escadaComRampa,
        );
      } else {
        comando = RegistraFichaCommand(
          nome: 'Roberto Alves Vermelho',
          cpf: '529.982.247-25',
          grauLimitacaoMotora: 5,
          residencia: CoordenadaGPS(-23.550520, -46.633308),
          ubsReferencia: CoordenadaGPS(-23.570000, -46.633308),
          tipoAcessoVia: TipoAcessoVia.escadaria,
          presencaEscadaRampa: PresencaEscadaRampa.escada,
        );
      }

      final res = await registra.executar(comando);
      _adicionarLog(
        'Sucesso [IRegistraFichaTerritorial]: Ficha #${res.idFicha} gerada | '
        'IAL: ${res.ial.valor.toStringAsFixed(1)} | Sinaleira: ${res.ial.nivel.codigo.toUpperCase()}',
      );
    } catch (e) {
      _adicionarLog('Erro ao registrar ficha: $e');
    } finally {
      setState(() => _executando = false);
    }
  }

  Future<void> _testarListagem() async {
    setState(() => _executando = true);
    try {
      final listar = getIt<IListarFichasTerritoriais>();
      final lista = await listar.executar();
      _adicionarLog('Sucesso [IListarFichasTerritoriais]: ${lista.length} ficha(s) obtida(s) do repositório.');
    } catch (e) {
      _adicionarLog('Erro ao listar fichas: $e');
    } finally {
      setState(() => _executando = false);
    }
  }

  Future<void> _testarGps() async {
    setState(() => _executando = true);
    try {
      final gps = getIt<ICapturarLocalizacao>();
      final pos = await gps.executar();
      _adicionarLog('Sucesso [ICapturarLocalizacao]: Lat ${pos.latitude.toStringAsFixed(6)}, Lon ${pos.longitude.toStringAsFixed(6)}');
    } catch (e) {
      _adicionarLog('Erro ao capturar GPS: $e');
    } finally {
      setState(() => _executando = false);
    }
  }

  Future<void> _testarSincronizacao() async {
    setState(() => _executando = true);
    try {
      final sinc = getIt<ISincronizarFichas>();
      final enviados = await sinc.executar();
      _adicionarLog('Sucesso [ISincronizarFichas]: $enviados registro(s) sincronizado(s) da fila outbox.');
    } catch (e) {
      _adicionarLog('Erro na sincronização: $e');
    } finally {
      setState(() => _executando = false);
    }
  }

  Future<void> _testarConsultaCidadao() async {
    setState(() => _executando = true);
    try {
      final consulta = getIt<IConsultaFichaCidadao>();
      final ficha = await consulta.executar('529.982.247-25');
      if (ficha != null) {
        _adicionarLog(
          'Sucesso [IConsultaFichaCidadao]: Ficha encontrada! IAL: ${ficha.valorIal.toStringAsFixed(1)} '
          '(${ficha.nivel.codigo.toUpperCase()}) em ${ficha.dataColeta.toLocal()}',
        );
      } else {
        _adicionarLog('Sucesso [IConsultaFichaCidadao]: Nenhuma ficha encontrada para o CPF testado.');
      }
    } catch (e) {
      _adicionarLog('Erro na consulta do cidadão: $e');
    } finally {
      setState(() => _executando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROMAP-SUS: Visualizador Arquitetura'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.hub), text: 'Camadas'),
            Tab(icon: Icon(Icons.play_circle_outline), text: 'Testar Portas'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'UI / Sinaleira'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirAbaCamadas(),
          _construirAbaTestes(),
          _construirAbaVisual(),
        ],
      ),
    );
  }

  Widget _construirAbaCamadas() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Isolamento de Camadas (Arquitetura Hexagonal)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'A estrutura garante que o Domínio Central permaneça independente de frameworks '
          'e bibliotecas externas, acoplado apenas a interfaces abstratas (Portas).',
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 16),
        _cartaoCamada(
          titulo: '1. Domínio Central (Núcleo Puro)',
          cor: Colors.teal.shade50,
          corBorda: Colors.teal,
          itens: const [
            'Entidades: PacientePCD, FichaTerritorial, ItemFilaSincronizacao',
            'Objetos de Valor: CoordenadaGPS, Cpf, NivelAcessibilidade, TipoAcessoVia, PresencaEscadaRampa',
            'Serviços de Domínio: IalCalculatorService (equação e sinaleira), SyncDaemonService (Outbox)',
            'Casos de Uso: RegistraFicha, ListarFichas, CapturarLocalizacao, Sincronizar, ConsultaCidadao',
          ],
        ),
        const SizedBox(height: 12),
        _cartaoCamada(
          titulo: '2. Portas de Entrada (Inbound / Driving Ports)',
          cor: Colors.blue.shade50,
          corBorda: Colors.blue,
          itens: const [
            'IRegistraFichaTerritorial: executa validação, cálculo do IAL e persistência',
            'IListarFichasTerritoriais: recupera histórico de fichas locais',
            'ICapturarLocalizacao: provê leitura de coordenadas GPS para a UI',
            'ISincronizarFichas: comanda o envio das pendências da fila Outbox',
            'IConsultaFichaCidadao: encapsula hash e busca da ficha do cidadão',
          ],
        ),
        const SizedBox(height: 12),
        _cartaoCamada(
          titulo: '3. Portas de Saída (Outbound / Driven Ports)',
          cor: Colors.purple.shade50,
          corBorda: Colors.purple,
          itens: const [
            'IFichaRepository: persistência atômica da ficha e do paciente',
            'IFilaSincronizacaoRepository: consulta e marcação na tabela Outbox',
            'ILocalizacaoService: abstração do sensor de geolocalização',
            'ISyncApiAdapter: transmissão com hash SHA-256 para servidor central',
            'IConsultaFichaLocalRepository: busca da última ficha por hash de CPF',
            'IProtecaoDadosPessoais: HMAC-SHA256 para CPF e AES-256-GCM para nome',
          ],
        ),
        const SizedBox(height: 12),
        _cartaoCamada(
          titulo: '4. Adaptadores (Input & Output Adapters)',
          cor: Colors.amber.shade50,
          corBorda: Colors.orange,
          itens: const [
            'Adaptadores de Entrada (UI): FichaController, CidadaoController, Pages (Acs, Ficha, Cidadao)',
            'Adaptadores de Saída (Produção): SqliteFichaRepository (SQLCipher), LocationServiceAdapter (GPS nativo)',
            'Adaptadores de Saída (Memória/Dev/Web): InMemoryDatabase, MockLocalizacaoService, LocalMockSyncApiAdapter',
          ],
        ),
      ],
    );
  }

  Widget _cartaoCamada({
    required String titulo,
    required Color cor,
    required MaterialColor corBorda,
    required List<String> itens,
  }) {
    return Card(
      color: cor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: corBorda, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: corBorda.shade900)),
            const Divider(),
            for (final it in itens)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: corBorda.shade800, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(it, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirAbaTestes() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disparo e Verificação de Portas Inbound em Tempo Real',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: _executando ? null : () => _testarRegistro('verde'),
                child: const Text('Registrar Ficha (Verde)'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : () => _testarRegistro('amarelo'),
                child: const Text('Registrar Ficha (Amarela)'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : () => _testarRegistro('vermelho'),
                child: const Text('Registrar Ficha (Vermelha)'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : _testarListagem,
                child: const Text('Listar Fichas'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : _testarGps,
                child: const Text('Capturar GPS'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : _testarSincronizacao,
                child: const Text('Sincronizar Fila'),
              ),
              FilledButton.tonal(
                onPressed: _executando ? null : _testarConsultaCidadao,
                child: const Text('Consultar Cidadão'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Console de Execução dos Casos de Uso:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _logsExecucao.clear()),
                child: const Text('Limpar Console'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logsExecucao.isEmpty
                  ? const Center(
                      child: Text(
                        'Clique em uma das portas acima para executar os casos de uso.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logsExecucao.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logsExecucao[i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAbaVisual() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Galeria de Componentes: Sinaleira Visual de Acessibilidade',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Componentes com alto contraste e atendimento aos requisitos de acessibilidade WCAG 2.1 AA.',
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nível Verde (IAL Baixo / Boa Acessibilidade)', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SinaleiraBadge(nivel: NivelAcessibilidade.verde, valorIal: 12.5),
                SizedBox(height: 16),
                Text('Nível Amarelo (IAL Intermediário / Atenção)', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SinaleiraBadge(nivel: NivelAcessibilidade.amarelo, valorIal: 45.0),
                SizedBox(height: 16),
                Text('Nível Vermelho (IAL Alto / Barreira Crítica)', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SinaleiraBadge(nivel: NivelAcessibilidade.vermelho, valorIal: 82.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
