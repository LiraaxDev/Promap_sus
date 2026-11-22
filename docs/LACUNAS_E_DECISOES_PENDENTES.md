# Lacunas, ambiguidades e decisões pendentes

Conforme a orientação de uso da especificação ("não presuma informações que não estejam especificadas; sinalize lacunas explicitamente"), esta lista registra tudo o que **não está definido** no documento e como a implementação lidou com cada ponto. Itens **[PROVISÓRIO]** têm um valor no código que precisa ser validado/substituído.

## A. Núcleo de negócio (IAL e sinaleira)

| ID | Lacuna | Tratamento no código |
|---|---|---|
| L-01 | **Equação do IAL** (RF03): citam-se 3 fatores (limitação motora, distância à UBS, barreiras do trajeto), mas não a fórmula, os pesos nem a normalização. O diagrama de atividades (4.2) fala em "ramificações condicionais das barreiras", sem detalhá-las. | **[PROVISÓRIO]** Soma ponderada normalizada, escala 0–100 (maior = pior): pesos 0,40 / 0,30 / 0,30. Isolado em `IalParametros` e `IalCalculatorService`; trocar a fórmula não afeta o resto. |
| L-02 | **Escala do grau de limitação motora** (`INTEGER NOT NULL`, sem faixa). | **[PROVISÓRIO]** 1 a 5 (`IalParametros.grauLimitacaoMin/Max`). |
| L-03 | **Limiares das cores** (RF02) e o formato textual de `cor_sinaleira`. | **[PROVISÓRIO]** IAL ≥ 35 amarelo; ≥ 65 vermelho. Texto gravado: `VERDE`/`AMARELO`/`VERMELHO`. |
| L-04 | **Valores de `tipo_acesso_via` (TEXT) e `presenca_escada_rampa` (INTEGER)**. Além disso, RF01 cita pavimentação, largura de vielas e iluminação, mas o DER só tem essas duas colunas. | **[PROVISÓRIO]** Enums com códigos e pesos próprios (`TipoAcessoVia`, `PresencaEscadaRampa`). Largura de viela e iluminação **não** foram modeladas (sem coluna no DER). |
| L-05 | **Distância até a UBS**: método (linha reta × trajeto) e origem das coordenadas da UBS (não há tabela de UBS). | Haversine (linha reta). A ACS informa lat/long da UBS no formulário. |

## B. Escopo funcional

| ID | Lacuna | Tratamento |
|---|---|---|
| L-06 | **Pontos de apoio** na comunidade (Perfil Micro, 1.1): sem entidade/esquema. | Não implementado. |
| L-07 | **RF04 / status de encaminhamentos**: não há tabelas de encaminhamento, referência e contrarreferência no DER. | Não implementado. |
| L-13 | **RF05 (painel web), microsserviços, mapa de calor, agendamento eMulti, interoperabilidade e-SUS APS**: pertencem ao servidor/web; a seção 5 só detalha o app móvel. | Não implementado. |
| L-14 | **Mapas offline**: a seção 3.2 os cita como motivação para Flutter, mas nenhum RF descreve mapa no app. | Não implementado (coordenadas são exibidas como texto). |
| L-15 | "Registrar **e atualizar**" ficha (RF01): não define se atualizar sobrescreve ou cria histórico. | Cada coleta cria nova linha em `TB_FICHA_TERRITORIAL` (histórico); o paciente é reaproveitado por `cpf_hash`. |

## C. Segurança e LGPD

| ID | Lacuna | Tratamento |
|---|---|---|
| L-08 | **Autenticação e RBAC** (RNF02): papéis citados (ACS, Profissional, Gestor, Paciente), sem fluxo de login, credenciais ou matriz de permissões. | Apenas uma guarda de rota por perfil de sessão (`SessaoPerfil`). **Não é controle de acesso real.** |
| L-09 | **Algoritmo e chaves de `cpf_hash` e `nome_criptografado`**; ciclo de vida das chaves (rotação, recuperação, descarte). | Chaves aleatórias de 256 bits no armazenamento seguro do SO. CPF: HMAC-SHA256 (SHA-256 puro seria reversível por força bruta). Nome: AES-256-GCM. |
| L-12 | **TLS 1.3**: o `package:http` não permite fixar a versão do TLS no Dart. | Usa HTTPS da plataforma. Forçar TLS 1.3 exige configuração nativa/servidor. |
| L-18 | Base legal, consentimento, retenção e exclusão de dados (LGPD). | Não tratados. |

## D. Integração e sincronização

| ID | Lacuna | Tratamento |
|---|---|---|
| L-11 | **Contrato da API**: URL, autenticação, formato do lote, resposta e **chave de idempotência** (a seção 5.3 cita idempotência e validação de hash, mas só descreve o hash). | URL por `--dart-define=PROMAP_API_URL` (sem valor padrão). Envelope JSON com `id_item`, `tabela_origem`, `id_registro_local`, `payload_sha256`, `payload_json`; cabeçalho `X-Payload-SHA256`. Sucesso = HTTP 2xx. **[PROVISÓRIO]** |
| L-19 | Estados do Outbox: só `PENDENTE` (padrão) e `SINCRONIZADO` são citados; nada sobre erro/limite de tentativas. | Só esses dois estados; falhas deixam o item `PENDENTE` e a fila para na primeira falha (preserva ordem). |

## E. Inconsistências internas do documento

| ID | Observação | Decisão |
|---|---|---|
| L-10 | Nomes divergentes: `RegistraFichaTerritorialUseCase` (5.1) × `RegistraFichaUseCase` (4.2); `HttpCentralServerApiAdapter` (5.2) × `HttpSyncApiAdapter` (4.2); `salvarLocamente` (grafia provável de "salvarLocalmente"). | Adotados `RegistraFichaTerritorialUseCase` e `HttpCentralServerApiAdapter` (árvore e código de DI); `salvarLocamente` **mantido como escrito** para preservar o identificador. Renomear é trivial se desejado. |
| L-16 | Formatação do arquivo: a tabela da 3.1 está colada ao parágrafo anterior; a 4.3 usa `` ``TB_...`` `` com crases duplas; o resumo diz que Híbrido foi "superado por compilação nativa" embora Flutter não seja "nativo" no sentido estrito (compila AOT). | Sem impacto no código. |
| L-20 | A DI do exemplo (5.2) chama `AppDatabase.initEncrypted(...)` de forma síncrona; abrir SQLCipher e ler a chave são operações assíncronas. | `setupDependencies` e `initEncrypted` são `async` (`main` aguarda). Registro feito pelos tipos das **portas**, não das classes concretas. |
| L-17 | Formato de `data_coleta` (DATETIME) e `data_nascimento` (TEXT). | ISO-8601 (UTC para `data_coleta`; `AAAA-MM-DD` para nascimento). |

## F. Decisões necessárias antes de produção

1. Fórmula, pesos e limiares oficiais do IAL (L-01 a L-04), com validação clínica/ACS e atualização dos testes em `test/domain/ial_calculator_service_test.dart`.
2. Contrato da API central e política de idempotência (L-11).
3. Autenticação/RBAC (L-08) e política de chaves (L-09).
4. Esquema de encaminhamentos e pontos de apoio (L-06, L-07).
