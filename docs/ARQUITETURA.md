# Arquitetura e artefatos de modelagem

Diagramas em Mermaid (renderizam no GitHub/GitLab/VS Code). Os fluxos abaixo reproduzem os textos da seção 4 da especificação; **não são BPMN/UML em notação XML formal** — para isso, importe-os em uma ferramenta de modelagem.

## Hexágono (Camadas Estritamente Isoladas)

```mermaid
flowchart LR
  subgraph ADAPTERS_INPUT["Adaptadores de Entrada (Driving / UI)"]
    FichaCtrl["FichaController"]
    CidadaoCtrl["CidadaoController"]
    Pages["AcsHomePage · FichaFormPage<br/>FichasListaPage · CidadaoHomePage<br/>VisualizadorHexagonalPage"]
  end

  subgraph PORTS_IN["Portas de Entrada (Inbound / Driving Ports)"]
    IN_REG["IRegistraFichaTerritorial"]
    IN_LIST["IListarFichasTerritoriais"]
    IN_GPS["ICapturarLocalizacao"]
    IN_SYNC["ISincronizarFichas"]
    IN_CID["IConsultaFichaCidadao"]
  end

  subgraph DOMAIN["Domínio Central (Núcleo Puro)"]
    UC_REG["RegistraFichaTerritorialUseCase"]
    UC_LIST["ListarFichasTerritoriaisUseCase"]
    UC_GPS["CapturarLocalizacaoUseCase"]
    UC_SYNC["SincronizarFichasUseCase"]
    UC_CID["ConsultaFichaCidadaoUseCase"]
    DOM_SVC["IalCalculatorService · SyncDaemonService"]
    ENT_VO["PacientePCD · FichaTerritorial · ItemFilaSincronizacao<br/>CoordenadaGPS · Cpf · NivelAcessibilidade"]
  end

  subgraph PORTS_OUT["Portas de Saída (Outbound / Driven Ports)"]
    OUT_FICHA["IFichaRepository"]
    OUT_FILA["IFilaSincronizacaoRepository"]
    OUT_GPS["ILocalizacaoService"]
    OUT_API["ISyncApiAdapter"]
    OUT_CID["IConsultaFichaLocalRepository"]
    OUT_CRYPTO["IProtecaoDadosPessoais"]
  end

  subgraph ADAPTERS_OUT["Adaptadores de Saída (Driven / Infraestrutura)"]
    DB_SQL["SqliteFichaRepository<br/>(SQLCipher / AES-256)"]
    DB_MEM["InMemoryDatabase<br/>(Web / Desktop / Visualização)"]
    GPS_NATIVE["LocationServiceAdapter<br/>(GPS NATIVO)"]
    GPS_MOCK["MockLocalizacaoService<br/>(Simulado)"]
    API_HTTP["HttpCentralServerApiAdapter<br/>(Produção)"]
    API_MOCK["LocalMockSyncApiAdapter<br/>(Dev / Testes)"]
    CRYPTO_SEC["ProtecaoDadosPessoaisAdapter<br/>(Keystore/Keychain)"]
    CRYPTO_MEM["InMemoryProtecaoDadosPessoais<br/>(Puro Dart)"]
  end

  ADAPTERS_INPUT --> PORTS_IN
  PORTS_IN --> DOMAIN
  DOMAIN --> PORTS_OUT
  PORTS_OUT --> ADAPTERS_OUT
```

## 4.1 Processo — Cadastro territorial em campo

```mermaid
flowchart TD
  A([Início do atendimento]) --> B[ACS acessa o aplicativo]
  B --> C[Caracterização do paciente e barreiras do entorno]
  C --> D[Leitura automática das coordenadas GPS]
  D --> E[Execução embarcada do IAL]
  E --> F[Salvamento atômico no SQLite local]
  F --> G[Enfileiramento na tabela Outbox]
  G --> H([Fim da etapa de campo])
```

## 4.1 Processo — Sincronização e triagem na UBS

```mermaid
flowchart TD
  A([Chegada da ACS à UBS]) --> B[Conexão automática ao Wi-Fi]
  B --> C[Leitura dos registros pendentes na Outbox]
  C --> D[Transmissão via API REST]
  D --> E[Atualização do mapa de calor do território]
  E --> F[Identificação de casos em Grau Vermelho]
  F --> G[Agendamento prioritário de visita - eMulti]
  G --> H([Encaminhamento com contrarreferência])
```
> No app móvel, só as etapas A–D estão implementadas (`SyncDaemonService`). E–H pertencem ao servidor (L-13).

## 4.2 Sequência — Sincronização offline-first

```mermaid
sequenceDiagram
  participant UI as FormPage
  participant C as FichaController
  participant U as RegistraFichaTerritorialUseCase
  participant S as IalCalculatorService
  participant R as SqliteFichaRepository / InMemoryDatabase
  participant D as SyncDaemonService
  participant A as ISyncApiAdapter (Mock/HTTP)
  UI->>C: dados do formulário
  C->>U: executar(comando)
  U->>S: calcular()
  S-->>U: valor IAL + cor
  U->>R: salvarLocamente(paciente, ficha)
  Note over R: transação única: TB_PACIENTE_PCD,<br/>TB_FICHA_TERRITORIAL, TB_FILA_SINCRONIZACAO
  D->>D: detecta rede
  D->>A: enviar(pacote + SHA-256)
  A-->>D: sucesso
  D->>R: marca item SINCRONIZADO
```

## 4.2 Atividades — Cálculo do IAL (implementação provisória, ver L-01)

```mermaid
flowchart TD
  A([Entrada]) --> B{Grau e distância válidos?}
  B -- não --> X([ValidacaoException])
  B -- sim --> C[Normaliza limitação 0..1]
  C --> D[Normaliza distância 0..1, saturando na referência]
  D --> E[Barreiras = 0,5·via + 0,5·escada/rampa]
  E --> F[IAL = 100·Σ pesos·fatores]
  F --> G{IAL ≥ limite vermelho?}
  G -- sim --> V([Vermelho])
  G -- não --> H{IAL ≥ limite amarelo?}
  H -- sim --> Y([Amarelo])
  H -- não --> Gv([Verde])
```

## 4.3 DER

```mermaid
erDiagram
  TB_PACIENTE_PCD ||--o{ TB_FICHA_TERRITORIAL : possui
  TB_PACIENTE_PCD {
    INTEGER id_paciente PK
    TEXT cpf_hash UK
    TEXT nome_criptografado
    INTEGER grau_limitacao_motora
    TEXT data_nascimento
  }
  TB_FICHA_TERRITORIAL {
    INTEGER id_ficha PK
    INTEGER id_paciente FK
    REAL latitude
    REAL longitude
    TEXT tipo_acesso_via
    INTEGER presenca_escada_rampa
    REAL valor_ial
    TEXT cor_sinaleira
    DATETIME data_coleta
  }
  TB_FILA_SINCRONIZACAO {
    INTEGER id_item PK
    TEXT tabela_origem
    INTEGER id_registro_local
    TEXT payload_json
    TEXT status_envio
    DATETIME timestamp_criacao
  }
```
`TB_FILA_SINCRONIZACAO` referencia o registro de origem logicamente (`tabela_origem` + `id_registro_local`), sem FK, como na especificação.
