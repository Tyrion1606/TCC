# Plano rastreável das 28 melhorias pendentes do TCC

## Finalidade deste arquivo

Este documento preserva, em formato portátil, os 28 pontos identificados durante a auditoria técnica do projeto. Ele pode ser anexado a outro chat, entregue a outro revisor ou usado como backlog de redação e validação sem exigir nova leitura dos históricos originais.

Cada ponto contém:

- a situação observada;
- o motivo técnico ou acadêmico;
- o trabalho necessário;
- os artefatos esperados;
- um critério objetivo de conclusão.

O arquivo não afirma que todos os pontos são defeitos de firmware. Alguns são lacunas documentais, outros exigem novos ensaios, outros são inconsistências da aplicação e alguns dependem de decisões de segurança e metodologia que não podem ser resolvidas apenas por edição textual.

## Fotografia do projeto usada nesta análise

| Componente | Referência auditada |
|---|---|
| TCC e dossiê | repositório `Tyrion1606/TCC`, fonte acadêmica importada no commit `3609c18`; dossiê consolidado no commit `c596159` |
| Firmware | `Tyrion1606/blackpill_ads1256-display`, commit `7fc7d6d724f3d762ea08447b26180b6c7ec7d27a` |
| Aplicação | `AlexAndrei3663/processamento_biomedico`, commit `d34b56bec961cbea028f5cc8573e845f4e215c63` |
| Captura de firmware | 100.005 frames, sequência observada 15–100.019, aproximadamente 1.000 frames/s |
| Protocolo atual | `FRAME,sequence_id,timestamp_us,d1,d2,d3,d4` |
| Conversor | ADS1256, PGA 1, DRATE `0xF0`, quatro pares diferenciais sequenciais |
| Microcontrolador | STM32F411CEU6, núcleo a 96 MHz, aplicação em `0x08004000` |

A referência técnica completa é [DOCUMENTACAO_TECNICA_CRONOLOGICA.md](DOCUMENTACAO_TECNICA_CRONOLOGICA.md).

## Legenda de prioridade e dependências

| Classe | Significado |
|---|---|
| P0 | Pode invalidar interpretação, segurança, reprodução ou operação prolongada. |
| P1 | Necessário para rigor experimental e conclusão acadêmica sólida. |
| P2 | Melhora manutenção, clareza, apresentação ou sustentação das conclusões. |

Ordem recomendada de execução:

1. congelar fontes e preservar os dados brutos;
2. corrigir conceitos, metadados e contradições documentais;
3. fechar esquemático, alimentação e segurança;
4. corrigir incompatibilidades atuais entre firmware e software;
5. definir metodologia metrológica;
6. executar os novos ensaios;
7. reprocessar resultados com scripts versionados;
8. atualizar figuras, conclusões e indicadores de portabilidade.

---

# Parte I — Integridade editorial e descrição física

## 1. Corrigir ano e metadados

**Prioridade:** P0 documental.

### Situação observada

O texto contém julho de 2025 e ano 2025, enquanto commits, ensaios, documentação e referências alcançam julho de 2026.

### Por que precisa ser resolvido

Uma data incorreta compromete a cronologia da pesquisa, a identificação da versão examinada pela banca e a coerência com as referências bibliográficas.

### Trabalho necessário

1. conferir capa, folha de rosto, ficha catalográfica, folha de aprovação e cabeçalhos;
2. definir se a data acadêmica correta é julho de 2026 ou a data efetiva de defesa;
3. conferir datas em legendas, metodologia, commits e apêndices;
4. recompilar o PDF e procurar ocorrências remanescentes de `2025`.

### Entregáveis

- fonte TeX corrigida;
- PDF recompilado;
- registro da data de corte dos códigos e dos dados.

### Critério de aceite

Todas as datas institucionais estão coerentes entre si e a data de corte técnico é declarada explicitamente.

## 2. Eliminar todos os placeholders

**Prioridade:** P0 documental.

### Situação observada

Permanecem informações provisórias sobre bateria, fotografia final, dimensões, massa, custo, largura de banda do osciloscópio e marcações como `[ph...]` e `[50/70/100] MHz`.

### Trabalho necessário

1. pesquisar no TeX por colchetes, `TODO`, `TBD`, `ph`, interrogações editoriais e textos alternativos;
2. preencher somente com dados medidos ou confirmados em manuais e etiquetas;
3. excluir campos que não possam ser recuperados, declarando a limitação quando relevante;
4. revisar também legendas, tabelas, lista de materiais e apêndices.

### Entregáveis

- inventário dos placeholders encontrados;
- fonte sem texto provisório;
- evidência da origem de cada valor acrescentado.

### Critério de aceite

Uma busca automatizada e uma leitura do PDF não encontram nenhum placeholder ou escolha editorial aberta.

## 3. Fechar o esquemático analógico real

**Prioridade:** P0; depende de inspeção física.

### Situação observada

O mapeamento digital do ADS1256 é conhecido, mas não existe registro suficiente para reconstruir AINP/AINN, referências, filtros, proteção e alimentação analógica de cada canal.

### Trabalho necessário

Para cada par `01`, `23`, `45` e `67`, registrar:

1. origem do sinal e terminal positivo;
2. sinal ligado ao terminal negativo;
3. common-mode e referência do sensor;
4. resistores série, divisores, capacitores e frequências de corte;
5. diodos, TVS, limitadores e proteção ESD;
6. alimentação AVDD−AGND, DVDD−DGND e VREFP−VREFN medidas;
7. continuidade entre AGND e DGND;
8. impedância de saída do frontend e carregamento pela entrada do ADS1256;
9. identidade e função real do quarto canal;
10. conectores e numeração física.

O ADS1256 não possui pino `AVSS`; eventual rail negativo externo do módulo deve receber seu nome elétrico correto.

### Entregáveis

- esquemático versionado em formato fonte e PDF/SVG;
- tabela de nets e conectores;
- fotografias anotadas dos dois lados da placa;
- tabela de tensões medidas.

### Critério de aceite

Uma segunda pessoa consegue refazer a montagem sem inferir nenhuma conexão analógica ou de alimentação.

## 4. Corrigir a descrição da aquisição sequencial

**Prioridade:** P0 conceitual.

### Situação observada

Os quatro pares aparecem em um frame comum, mas o ADS1256 possui um único caminho de conversão e alterna o MUX sequencialmente. O timestamp é lido antes do readout; em regime, a conversão do primeiro par já começou ao final da chamada anterior.

### Trabalho necessário

1. substituir “conversões simultâneas” por “aquisição multicanal sequencial”;
2. explicar que um frame é um agrupamento lógico;
3. descrever que não existe timestamp individual por canal;
4. medir a defasagem real com GPIO e osciloscópio/analisador lógico;
5. declarar se análises entre canais compensam ou ignoram essa defasagem.

### Entregáveis

- diagrama temporal medido;
- texto e figuras corrigidos;
- tabela de offset temporal por canal.

### Critério de aceite

Nenhuma seção sugere simultaneidade física, e a defasagem é quantificada ou declarada como limitação.

## 5. Separar corretamente todas as taxas

**Prioridade:** P0 conceitual.

### Situação observada

DRATE, frequência do modulador, throughput de cycling, taxa de frames e quantidade de valores são grandezas diferentes.

### Definições que precisam constar

| Grandeza | Estado atual |
|---|---:|
| Clock nominal do ADS1256 | 7,68 MHz |
| Modulador | aproximadamente `fCLKIN/4 = 1,92 MHz` |
| DRATE | saída nominal de 30 kSPS, código `0xF0` |
| Cycling TI a SCLK 1,92 MHz | 4.374 leituras/s |
| Estimativa a SCLK 1,5 MHz | 4.181,94 leituras/s |
| Medição do sistema | aproximadamente 1.000 frames/s |
| Valores por frame | 4 |
| Taxa por par | aproximadamente 1.000 amostras/s |
| Valores transmitidos | aproximadamente 4.000/s |

### Trabalho necessário

Padronizar símbolos, unidades e termos em toda a monografia, nas figuras e no display. Evitar afirmar que o ADC está “configurado em 1 kSPS” ou que entrega 30 kSPS úteis por canal.

### Critério de aceite

Todas as taxas são nomeadas e nenhuma comparação usa grandezas incompatíveis.

---

# Parte II — Tempo, transporte e reprodutibilidade

## 6. Documentar e corrigir o rollover do timestamp

**Prioridade:** P0 operacional.

### Situação observada

O DWT é estendido internamente, mas a função e o CSV retornam `uint32_t` em microssegundos. O campo volta a zero após `2^32 µs`, aproximadamente 71 min 34,967 s. O receptor espera monotonicidade e rejeita os frames posteriores.

### Trabalho necessário

Opção preferencial:

1. transmitir timestamp `uint64_t`;
2. ajustar `snprintf`, parser, testes, modelos e HDF5;
3. criar teste acelerado ou injetado de rollover;
4. validar sessão maior que duas horas.

Alternativa: implementar unwrapping explícito e persistente no receptor, documentando reinícios da MCU.

### Entregáveis

- especificação de protocolo atualizada;
- testes de fronteira;
- captura longa sem rejeição;
- regra de migração para arquivos antigos.

### Critério de aceite

Uma sessão atravessa o antigo limite de 71,6 minutos sem regressão, descarte ou ambiguidade temporal.

## 7. Separar perdas de sequência de lacunas temporais

**Prioridade:** P0 metodológico.

### Situação observada

As sessões antigas mantiveram IDs consecutivos, mas apresentaram pausas nos timestamps. Posições esperadas da grade foram chamadas de frames perdidos sem prova de que tais frames tenham sido numerados e transmitidos.

### Trabalho necessário

Manter métricas independentes para:

- salto de `sequence_id`;
- duplicata;
- reordenação;
- regressão de timestamp;
- lacuna temporal;
- quantidade equivalente de períodos ausentes;
- taxa regular;
- taxa global.

### Entregáveis

- nomenclatura corrigida no texto;
- algoritmo versionado de detecção;
- tabelas recalculadas;
- explicação das possíveis causas sem atribuição não demonstrada.

### Critério de aceite

“Perda de frame” é usada somente quando existe evidência de salto de sequência ou perda comprovada no caminho de transporte.

## 8. Preservar dados e scripts experimentais

**Prioridade:** P0 de reprodutibilidade.

### Situação observada

Dados brutos e scripts que produziram várias figuras e métricas não estão versionados nos repositórios auditados.

### Trabalho necessário

1. localizar HDF5/CSV originais;
2. preservar arquivos em armazenamento versionado ou repositório de dados apropriado;
3. versionar scripts de conversão, segmentação, FFT/PSD, ajuste, SNR, templates e picos;
4. registrar versões de Python e dependências;
5. criar manifesto por sessão com hashes;
6. separar claramente dado bruto, intermediário e resultado;
7. tornar a geração das figuras automatizada.

### Entregáveis

- diretório ou depósito de dados com README;
- hashes SHA-256;
- lockfile;
- comando único para reproduzir tabelas e figuras.

### Critério de aceite

Um ambiente limpo consegue recriar numericamente todas as figuras e tabelas a partir dos dados brutos.

---

# Parte III — Instrumentação e rigor metrológico

## 9. Resolver a identidade do osciloscópio

**Prioridade:** P0 documental/metrológica.

### Situação observada

Materiais citam Minipa MVB-DSO com largura de banda provisória; resultados citam BK Precision 2530.

### Trabalho necessário

Conferir equipamento, etiqueta, capturas de tela, modelo completo, número de série, ponta utilizada, fator da ponta, acoplamento, impedância de entrada, largura de banda e situação de calibração.

### Entregáveis

- identificação inequívoca no capítulo de materiais;
- fotografia da etiqueta;
- configuração relevante por ensaio.

### Critério de aceite

Existe um único instrumento identificado de forma consistente ou uma tabela que explique o uso de instrumentos distintos.

## 10. Medir VREF e clocks com referência independente

**Prioridade:** P1 metrológica.

### Situação observada

As tensões usam VREF nominal de 2,5 V. As taxas usam o DWT da STM32, enquanto DRDY depende do clock próprio do ADS1256.

### Trabalho necessário

1. medir VREFP−VREFN com multímetro adequado;
2. medir HSE/GPIO derivado do DWT;
3. medir CLKIN e DRDY do ADS1256;
4. usar a mesma referência calibrada quando possível;
5. repetir em diferentes temperaturas e tempos de aquecimento;
6. propagar a incerteza para tensão e frequência.

### Entregáveis

- planilha ou script de incerteza;
- certificados/especificações dos instrumentos;
- tabela de valores nominais e medidos.

### Critério de aceite

Erros absolutos são reportados contra referência independente, com incerteza e rastreabilidade declaradas.

## 11. Declarar claramente as referências de amplitude

**Prioridade:** P1 metodológica.

### Situação observada

Resultados de poucos por cento usam a configuração nominal do gerador, enquanto a comparação com 2,24 Vpp do osciloscópio produz diferenças próximas de 8–9%.

### Trabalho necessário

1. criar colunas separadas para gerador nominal e osciloscópio medido;
2. declarar Vpp, pico, RMS e offset sem ambiguidade;
3. explicar qual referência fundamenta cada conclusão;
4. não misturar erro contra gerador com erro contra osciloscópio.

### Critério de aceite

Cada percentual possui numerador, denominador, unidade e instrumento de referência identificáveis.

## 12. Conferir a inconsistência Vpp/RMS do osciloscópio

**Prioridade:** P1.

### Situação observada

Uma senoide ideal de 2,24 Vpp teria aproximadamente 0,792 V RMS, mas o texto registra 0,70654 V RMS.

### Trabalho necessário

Conferir capturas originais, forma da onda, offset, acoplamento, largura de banda, estatística automática, janela de medição e possível erro de transcrição.

### Entregáveis

- valor corrigido ou explicação física da diferença;
- imagem original preservada;
- cálculo reproduzível.

### Critério de aceite

Vpp e RMS são matematicamente compatíveis com a forma de onda ou a divergência é explicada e quantificada.

## 13. Separar desvio assinado de erro absoluto

**Prioridade:** P1 editorial/metodológica.

### Definições recomendadas

\[
\delta_{\%}=100\frac{x_{\mathrm{medido}}-x_{\mathrm{ref}}}{x_{\mathrm{ref}}},
\qquad
\varepsilon_{\%}=|\delta_{\%}|.
\]

### Trabalho necessário

Padronizar texto, equações, cabeçalhos e conclusões. Valores negativos são desvios assinados; erros absolutos não possuem sinal.

### Critério de aceite

Todas as tabelas usam símbolos e nomes coerentes com as equações.

## 14. Resolver a divergência de frequência do multitom

**Prioridade:** P1 editorial.

### Situação observada

O TeX apresenta 50,39 Hz em uma legenda e 53,39 Hz no texto.

### Trabalho necessário

Consultar dado bruto, script e figura; determinar o valor correto e verificar se ambos são apenas erros de digitação frente à base esperada de aproximadamente 50 Hz.

### Critério de aceite

Um único valor, gerado pelo script reproduzível, aparece em texto, tabela e legenda.

## 15. Reformular o resultado de 221,45 Hz do sinc

**Prioridade:** P1 conceitual.

### Situação observada

O valor é uma interpolação do cruzamento de −3 dB do envelope de linhas de um estímulo sinc periódico, separadas por aproximadamente 50 Hz. Não é uma varredura calibrada da resposta da cadeia.

### Trabalho necessário

Renomear a métrica, explicar a resolução física do estímulo e, se a intenção for medir banda da cadeia, executar varredura senoidal calibrada com mais pontos.

### Critério de aceite

O texto não chama 221,45 Hz de frequência de corte medida do sistema sem um ensaio específico que a sustente.

## 16. Documentar incertezas de medição

**Prioridade:** P1 metrológica.

### Trabalho necessário

Construir orçamento de incerteza incluindo, quando aplicável:

- tolerância e ruído de VREF;
- exatidão do gerador;
- exatidão, resolução e calibração do osciloscópio;
- clock da STM32 e do ADS1256;
- quantização;
- variabilidade entre repetições;
- ajuste numérico e interpolação;
- ponta, cabos, impedância e carregamento.

### Entregáveis

- tabela de incerteza padrão e expandida;
- método de combinação;
- barras de erro ou intervalos nas figuras relevantes.

### Critério de aceite

As conclusões de exatidão são compatíveis com a incerteza combinada e não apresentam casas decimais sem sustentação.

---

# Parte IV — Correspondência entre texto e implementação

## 17. Atualizar os nomes reais do firmware

**Prioridade:** P1 documental.

### Situação observada

O texto cita `microsecond_clock` e `MicrosecondClock_Now`, enquanto o firmware usa `microsecond_delay` e `MicrosecondDelay_GetTimestampMicroseconds()`.

### Trabalho necessário

Revisar nomes de módulos, funções, variáveis, arquivos e figuras diretamente contra o commit fixado do firmware. Preferir links permanentes para o commit.

### Critério de aceite

Todos os identificadores citados existem exatamente na versão declarada.

## 18. Registrar e resolver divergências do projeto CubeMX

**Prioridade:** P0 de reprodução.

### Situação observada

- `spi.c` usa divisor 32, 1,5 MHz;
- `.ioc` registra divisor 2 e 24 Mbit/s;
- `.ioc` contém `PCC.Vdd=1.7`;
- o makefile Debug contém caminho absoluto para o linker script;
- as versões geradoras são CubeMX 6.17.0/DB.6.0.170 e STM32Cube FW_F4 1.28.3.

### Trabalho necessário

1. corrigir o `.ioc` para a configuração real;
2. informar VDD medido ao Power Consumption Calculator;
3. regenerar em branch dedicada;
4. auditar todos os diffs de código gerado;
5. tornar a build portátil;
6. registrar versão do CubeIDE, CubeMX, pacote F4 e GCC.

### Critério de aceite

Um clone em outro caminho recompila sem editar caminhos absolutos, e regenerar pelo CubeMX não altera SPI2 para 24 MHz.

## 19. Corrigir a incompatibilidade inicial de canais da GUI

**Prioridade:** P0 operacional.

### Situação observada

O firmware envia quatro valores, mas uma configuração limpa da aplicação começa com três tipos de sinal. O parser exige exatamente a quantidade configurada e rejeita todos os frames.

### Trabalho necessário

1. tornar quatro canais o preset padrão do equipamento;
2. mapear ECG 1, ECG 2, PPG e canal auxiliar;
3. testar primeira execução sem configuração manual;
4. validar mensagem de erro para quantidade incompatível;
5. registrar o significado físico do quarto canal.

### Critério de aceite

Uma instalação limpa recebe e grava imediatamente o protocolo atual de quatro canais.

## 20. Distinguir interface online de análise offline

**Prioridade:** P1 metodológica.

### Situação observada

A GUI atual calcula espectro de amplitude com Hann. PSD, dBc, SFDR, templates, SNR, picos e BPM apresentados no TCC vieram de scripts offline não presentes no módulo de interface.

### Trabalho necessário

Separar em tabelas:

- recurso disponível ao vivo;
- recurso disponível na reabertura de sessão;
- análise offline usada somente na pesquisa;
- algoritmo ainda não implementado.

### Critério de aceite

Nenhuma funcionalidade é atribuída à interface sem existir no commit declarado.

## 21. Descrever os filtros efetivamente implementados

**Prioridade:** P1.

### Situação observada

Os filtros usam `sosfiltfilt`/`filtfilt`, são de fase zero e não causais. A ordem efetiva de magnitude é duplicada e o corte Butterworth fornecido produz aproximadamente −6 dB após ida e volta. Cortes podem ser limitados por Nyquist e janelas curtas podem retornar sem determinada filtragem.

### Trabalho necessário

Documentar para cada opção:

- tipo, ordem de projeto e ordem efetiva;
- frequência nominal e efetiva;
- taxa utilizada;
- condições de bypass;
- artefatos de borda;
- reprocessamento de toda a janela;
- impossibilidade de interpretá-lo como filtro streaming causal.

### Critério de aceite

Curvas teóricas e medidas correspondem ao código e às taxas reais usadas em cada ensaio.

## 22. Registrar limitações do armazenamento e recuperação

**Prioridade:** P1 operacional.

### Situação observada

O SHA-256 protege datasets, não metadados; recuperação usa comprimentos mínimos e pode promover sessão falha; um arquivo corrompido pode interromper a varredura; shutdown não espera formalmente a QThread serial antes de finalizar o HDF5.

### Trabalho necessário

1. incluir metadados críticos no hash canônico;
2. definir estados `partial`, `failed`, `recovered` e `completed` sem perda semântica;
3. isolar erros por arquivo na recuperação;
4. aguardar thread serial e lote residual;
5. testar falta de energia e corrupção;
6. preservar taxa efetiva ao decimar/reabrir dados.

### Critério de aceite

Testes automatizados demonstram recuperação previsível, integridade completa e ausência de perda silenciosa no encerramento.

## 23. Documentar definitivamente a implantação na Raspberry Pi

**Prioridade:** P1 de reprodução.

### Situação observada

O histórico contém Raspberry Pi OS Lite com `linuxfb`, tentativas X11/Openbox e scripts atuais voltados a XCB, caminhos e usuários diferentes. A resolução final dos últimos problemas USB não foi registrada.

### Trabalho necessário

Escolher e documentar uma arquitetura única:

- imagem exata do sistema;
- Desktop/XCB ou Lite/linuxfb/EGLFS;
- usuário, hostname e diretórios;
- ambiente virtual e dependências;
- permissões serial;
- autostart e política de reinício;
- espera/reconexão de `/dev/ttyACM*`;
- logs, atualização e operação offline;
- desligamento seguro.

### Entregáveis

- script idempotente de instalação;
- serviço ou unidade de autostart;
- teste em cartão limpo;
- imagem/checksum ou lista exata de pacotes.

### Critério de aceite

Uma Raspberry Pi reinstalada do zero inicia a interface e recebe a STM32 sem intervenção manual não documentada.

---

# Parte V — Segurança, protocolo humano e sustentação das conclusões

## 24. Incluir segurança elétrica, ética e proteção de dados

**Prioridade:** P0 antes de novas coletas humanas.

### Situação observada

Não há demonstração completa de isolamento, corrente de fuga, proteção do voluntário, aprovação ética, consentimento ou política de dados pessoais.

### Trabalho necessário

1. mapear caminhos entre voluntário, sensores, STM32, USB, Raspberry, HDMI, carregadores e instrumentos aterrados;
2. definir alimentação isolada e condições proibidas;
3. limitar correntes e documentar proteções;
4. registrar avaliação do comitê de ética ou justificativa institucional aplicável;
5. obter consentimento e anonimizar dados;
6. definir retenção, acesso e descarte segundo LGPD;
7. declarar que o equipamento não é dispositivo médico certificado.

### Critério de aceite

Nenhuma aquisição humana ocorre sem protocolo aprovado, consentimento, análise elétrica e configuração segura documentada.

## 25. Documentar o protocolo fisiológico

**Prioridade:** P1 científico.

### Trabalho necessário

Registrar:

- características relevantes e anonimização do voluntário;
- postura, repouso, duração e condições ambientais;
- posição e preparação dos eletrodos;
- derivações de ECG;
- RLD, LO+ e LO−;
- posição e pressão do sensor PPG;
- ganho e banda dos módulos;
- critérios de inclusão/exclusão de trechos;
- filtros e parâmetros;
- detecção, associação e rejeição de picos;
- definição de template, SNR, correlação e BPM.

### Critério de aceite

Outro pesquisador consegue repetir a coleta e a análise sem decisões implícitas.

## 26. Evitar apresentação como validação clínica

**Prioridade:** P0 de conclusão.

### Situação observada

Os resultados demonstram aquisição funcional de sinais condicionados. Não demonstram desempenho diagnóstico, conformidade normativa ou equivalência a equipamento médico. O canal chamado “Oximetria” não calcula SpO₂.

### Trabalho necessário

1. limitar objetivos e conclusões a protótipo acadêmico;
2. remover implicações diagnósticas;
3. distinguir PPG de oximetria;
4. declarar ausência de calibração clínica e certificação;
5. indicar quais estudos seriam necessários para validação clínica futura.

### Critério de aceite

Resumo, objetivos, resultados e conclusão usam o mesmo nível de evidência e não extrapolam os ensaios executados.

## 27. Quantificar portabilidade e baixo custo

**Prioridade:** P2, mas necessária se essas forem contribuições centrais.

### Trabalho necessário

Medir e registrar:

- lista de materiais e fornecedor;
- preço, moeda, data e impostos;
- dimensões e massa;
- consumo em repouso e aquisição;
- capacidade nominal e medida da bateria;
- autonomia;
- tempo de inicialização;
- armazenamento por hora;
- necessidade de periféricos externos.

### Critério de aceite

Afirmações de portabilidade, baixo custo e autonomia são sustentadas por números e comparadas com critérios explícitos.

## 28. Executar a matriz de validações ainda ausentes

**Prioridade:** P1; depende dos pontos 3, 8, 10, 16 e 24.

### Ensaios mínimos

1. ruído com entradas curto-circuitadas e terminação documentada;
2. ENOB e bits livres de ruído calculados com método explícito;
3. offset, ganho, linearidade e saturação;
4. resposta em frequência por varredura calibrada;
5. caracterização do filtro anti-alias;
6. diafonia com estímulo em um canal por vez;
7. settling depois da troca de MUX;
8. defasagem temporal real de cada canal;
9. DRDY preso alto e preso baixo;
10. desconexão/reconexão USB;
11. linha CSV máxima e pressão de tráfego;
12. saturação da fila de gravação;
13. queda de energia e recuperação HDF5;
14. sessão superior a 71 minutos depois da correção do timestamp;
15. ensaio de várias horas na Raspberry Pi;
16. consumo, temperatura e estabilidade ao longo do tempo.

### Entregáveis

- plano de testes versionado;
- instrumentos e incertezas;
- dados brutos e scripts;
- relatório com critérios de aprovação definidos antes do ensaio;
- registro das falhas, não apenas dos casos aprovados.

### Critério de aceite

Cada ensaio possui entrada, procedimento, resultado bruto, cálculo reproduzível, limite de aceitação e conclusão proporcional à evidência.

---

# Parte VI — Controle da execução

## Matriz resumida

| Item | Tema | Prioridade | Dependências principais |
|---:|---|---|---|
| 1 | ano e metadados | P0 | decisão institucional |
| 2 | placeholders | P0 | inspeção e medições |
| 3 | esquemático analógico | P0 | hardware físico |
| 4 | aquisição sequencial | P0 | medição temporal para fechamento |
| 5 | vocabulário de taxas | P0 | nenhuma |
| 6 | timestamp uint64 | P0 | firmware + software |
| 7 | perdas versus lacunas | P0 | scripts e dados |
| 8 | dados e scripts | P0 | localizar arquivos originais |
| 9 | osciloscópio | P0 | fotografias/arquivos originais |
| 10 | VREF e clocks | P1 | instrumentos calibrados |
| 11 | referência de amplitude | P1 | item 9 |
| 12 | Vpp/RMS | P1 | item 9 |
| 13 | erro e desvio | P1 | nenhuma |
| 14 | multitom | P1 | item 8 |
| 15 | sinc | P1 | item 8 |
| 16 | incerteza | P1 | itens 9 e 10 |
| 17 | nomes do firmware | P1 | commit fixado |
| 18 | CubeMX/build | P0 | branch de correção |
| 19 | quatro canais | P0 | software |
| 20 | online/offline | P1 | item 8 |
| 21 | filtros | P1 | testes do software |
| 22 | HDF5/recuperação | P1 | testes de falha |
| 23 | Raspberry Pi | P1 | equipamento e imagem limpa |
| 24 | segurança/ética | P0 | avaliação institucional |
| 25 | protocolo fisiológico | P1 | item 24 |
| 26 | limites clínicos | P0 | revisão textual |
| 27 | custo/portabilidade | P2 | BOM e medições |
| 28 | matriz experimental | P1 | 3, 8, 10, 16 e 24 |

## Modelo de registro por item

Ao iniciar qualquer ponto, criar uma issue ou registro com:

~~~yaml
item:
responsavel:
status: planejado | em_andamento | bloqueado | concluido
data_inicio:
data_conclusao:
commits:
dados_brutos:
scripts:
instrumentos:
decisoes:
evidencias:
criterio_de_aceite_verificado_por:
observacoes:
~~~

## Prompt curto para retomar o trabalho em outro chat

> Estamos continuando o TCC de uma plataforma de aquisição com STM32F411, ADS1256, quatro pares diferenciais sequenciais, USB CDC e aplicação Python/Raspberry Pi. Use o arquivo `PLANO_28_MELHORIAS_TCC.md` como backlog vinculante e `DOCUMENTACAO_TECNICA_CRONOLOGICA.md` como evidência. Antes de modificar qualquer coisa, identifique o número do item, confirme os commits auditados, apresente os arquivos afetados, preserve dados brutos e defina um critério objetivo de conclusão. Não trate hipótese como fato nem declare o item concluído sem evidência reproduzível.

---

**Estado inicial deste backlog:** 28 itens abertos em 14 de julho de 2026. Alterações futuras devem atualizar o status sem apagar a descrição original do problema.
