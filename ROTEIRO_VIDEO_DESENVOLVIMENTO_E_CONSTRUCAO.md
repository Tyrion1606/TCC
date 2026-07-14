# Roteiro técnico para o vídeo de desenvolvimento e construção do sistema

## STM32F411, ADS1256, ST7735, USB CDC, Raspberry Pi e aplicação Python

**Formato:** documentário técnico com reprodução do núcleo digital e ensaio de bancada condicionado a uma fixture documentada

**Duração-alvo da edição principal:** 92 a 95 minutos

**Idioma:** português brasileiro

**Público:** estudantes e profissionais de eletrônica, sistemas embarcados, instrumentação e engenharia biomédica

**Data técnica de corte:** 14 de julho de 2026

---

## 1. Objetivo editorial

O vídeo deve contar como o projeto foi desenvolvido e, ao mesmo tempo, permitir que o espectador reproduza o núcleo digital e computacional do estado atual. A história não deve ser uma enumeração de commits. Cada problema precisa introduzir uma decisão de engenharia que reaparece na construção final.

A promessa feita ao espectador é:

> Ao final, você entenderá como construir e validar um sistema acadêmico que adquire quatro pares diferenciais sequenciais com um ADS1256, agrupa aproximadamente mil frames por segundo em uma STM32F411, envia os dados por USB e os visualiza e armazena em uma aplicação Python executável em computador ou Raspberry Pi.

O vídeo deve deixar explícito que o sistema:

- é um protótipo acadêmico, não um equipamento médico;
- não possui validação clínica ou conformidade normativa;
- não mede quatro canais simultaneamente: um único conversor percorre quatro pares;
- não possui, no estado documentado, um esquemático analógico *as-built* completo;
- deve ser reproduzido inicialmente com sinais de bancada, sem conexão a pessoas;
- atinge aproximadamente 1.000 **frames/s**, 1.000 amostras/s por par e 4.000 valores de ADC/s;
- possui limitações vigentes que serão apresentadas, e não escondidas, no encerramento.

## 2. Fontes de verdade usadas pelo roteiro

Gravar a tela sempre nos commits fixados abaixo. Não usar a ponta futura de `main` sem antes revalidar o roteiro.

| Subsistema | Commit do vídeo |
|---|---|
| firmware | `7fc7d6d724f3d762ea08447b26180b6c7ec7d27a` |
| aplicação Python | `d34b56bec961cbea028f5cc8573e845f4e215c63` |
| documentação consolidada | `39dd7a43d70600fc8437f387510b6e023595f4a4` |

Documentos de apoio:

- [DOCUMENTACAO_TECNICA_CRONOLOGICA.md](DOCUMENTACAO_TECNICA_CRONOLOGICA.md): trajetória, decisões, problemas e resultados;
- [DOCUMENTACAO_ESTADO_ATUAL.md](DOCUMENTACAO_ESTADO_ATUAL.md): montagem e comportamento vigentes;
- [PLANO_28_MELHORIAS_TCC.md](PLANO_28_MELHORIAS_TCC.md): limitações e próximos trabalhos.

## 3. Resultado que precisa estar funcionando antes da gravação

Não começar as cenas de bancada antes de confirmar, fora de câmera:

- firmware e aplicação nos commits fixados;
- montagem digital conferida ponto a ponto;
- alimentação e VREF medidas na unidade que será filmada;
- binário linkado em `0x08004000`;
- SPI2 efetivo em modo 1 e 1,5 MHz;
- display inicializando e mostrando os quatro pares;
- porta `/dev/ttyACM*` aparecendo;
- saída `FRAME,sequence_id,timestamp_us,d1,d2,d3,d4` estável;
- captura de 100 segundos concluída;
- aplicação configurada manualmente com quatro canais;
- gravação HDF5 iniciando e terminando sem arquivo parcial;
- todos os cabos, gerador e instrumentos identificados;
- nenhum voluntário conectado ao circuito.

O objetivo dessa pré-validação é proteger a continuidade da gravação. As cenas de montagem podem ser refeitas para a câmera. Todo resultado apresentado como **nova medição** precisa vir da unidade realmente filmada; capturas anteriores podem aparecer apenas com origem, commit e selo documental explícitos.

# Parte I — Plano de produção

## 4. Estrutura narrativa em três atos

### Ato 1 — Por que este sistema existe

Apresentar o problema, a arquitetura e as decisões que definiram o projeto. O conflito central é transformar um ADC de canal único multiplexado em uma aquisição multicanal útil, sem confundir taxa nominal do conversor com taxa entregue ao usuário.

### Ato 2 — Construção e funcionamento interno

Montar o hardware digital, explicar alimentação e entrada analógica, compilar e gravar o firmware, abrir o pipeline do ADS1256, explicar timestamp e protocolo e obter os primeiros frames.

### Ato 3 — Provar, usar e delimitar

Executar o validador, configurar a aplicação, gravar HDF5, mostrar a Raspberry Pi, apresentar ensaios existentes e encerrar com as limitações que ainda precisam ser resolvidas.

## 5. Mapa de capítulos e duração

Os tempos são metas de edição, não marcações rígidas de fala.

| Tempo | Capítulo | Resultado narrativo |
|---:|---|---|
| 00:00–01:20 | abertura fria | mostrar o sistema pronto e a prova de desempenho |
| 01:20–04:20 | escopo e segurança | dizer exatamente o que será construído e o que não será alegado |
| 04:20–08:20 | arquitetura | explicar o caminho completo do sinal |
| 08:20–15:30 | trajetória do desenvolvimento | mostrar as decisões e os problemas que formaram a solução |
| 15:30–20:00 | materiais e preparação | identificar módulos, ferramentas e versões |
| 20:00–30:30 | montagem | reproduzir pinagem digital e inspeção elétrica |
| 30:30–39:30 | base do firmware | memória, clocks, SPI e inicialização do ADS1256 |
| 39:30–48:30 | aquisição e otimização | explicar MUX, pipeline, taxas e ganho de desempenho |
| 48:30–54:00 | tempo e protocolo | explicar DWT, CSV e USB CDC |
| 54:00–61:00 | compilação, gravação e primeiro boot | produzir e executar o binário correto |
| 61:00–67:00 | validação de 100 segundos | demonstrar cadência e continuidade |
| 67:00–78:00 | aplicação Python | instalar, configurar quatro canais e explicar processamento |
| 78:00–82:00 | HDF5 | gravar, finalizar e definir a evidência de integridade |
| 82:00–85:00 | Raspberry Pi e rollover | demonstrar execução manual e limite de sessão |
| 85:00–90:00 | resultados | mostrar o que os ensaios realmente estabelecem |
| 90:00–95:00 | limites e encerramento | concluir sem exagerar as capacidades |

## 6. Linguagem visual

Usar quatro tipos de plano de forma consistente:

| Identificador | Plano | Uso |
|---|---|---|
| A | apresentador | contexto, decisões, advertências e transições |
| B | câmera superior de bancada | montagem, continuidade, alimentação e gravação |
| C | macro lateral | pinos, LEDs, display, conectores e instrumentos |
| D | captura de tela | código, terminal, aplicação, HDF5 e gráficos |

Convenção de cores para gráficos e sobreposições:

- azul: `d1`, AIN0−AIN1, ECG 1;
- laranja: `d2`, AIN2−AIN3, ECG 2;
- verde: `d3`, AIN4−AIN5, PPG;
- roxo: `d4`, AIN6−AIN7, auxiliar;
- vermelho: alimentação, perigo ou condição inválida;
- cinza: caminho ainda não documentado ou informação não medida.

Toda vez que aparecer uma medição, incluir no quadro:

1. grandeza;
2. unidade;
3. ponto medido;
4. instrumento;
5. valor;
6. se é nominal ou medido.

## 7. Material audiovisual necessário

### 7.1 Gravações novas

- plano geral do sistema funcionando;
- close da Black Pill, ADS1256, ST7735 e Raspberry Pi;
- montagem fio a fio com a alimentação desligada;
- teste de continuidade e ausência de curto;
- medição real de 5 V, 3,3 V, AVDD, DVDD e VREF;
- entrada de sinal de bancada e common-mode empregado;
- entrada no WeAct HID Bootloader;
- compilação e inspeção do ELF/BIN;
- primeiro boot e mensagens seriais;
- captura integral do validador de 100 segundos;
- configuração dos quatro canais na interface;
- criação, encerramento e reabertura de uma sessão HDF5;
- execução manual na Raspberry Pi;
- planos de apoio do gerador, osciloscópio e cabeamento.

### 7.2 Figuras existentes que podem ser usadas

Usar as figuras como material documental; conferir resolução, legenda e correspondência com a unidade filmada antes da edição.

| Arquivo | Uso sugerido |
|---|---|
| `figuras/arquitetura_sistema.png` | arquitetura geral |
| `figuras/montagem_ads1256_stm32_tft.png` | montagem do núcleo |
| `figuras/montagem_raspberry_interface.jpg` | equipamento com Raspberry Pi |
| `figuras/blocos_programa.png` | software |
| `figuras/print_aquisicao.png` | interface |
| `figuras/figura_tempo_comparativo_100Hz_450Hz.png` | ensaio senoidal |
| `figuras/figura_espectro_linear_100Hz_450Hz.png` | espectro senoidal |
| `figuras/figura_tempo_comparativo_5Hz_50Hz.png` | ondas quadradas |
| `figuras/figura_multitom_tempo.png` e `figuras/figura_multitom_espectro.png` | multitom |
| `figuras/figura_sinc_tempo.png` e `figuras/figura_sinc_espectro.png` | sinc periódica |
| `figuras/figura_multicanal_ecg1_ecg2_ppg.png` | sessão fisiológica já documentada |

### 7.3 Animações que precisam ser produzidas

1. cadeia completa do sinal;
2. mapa de Flash com bootloader e aplicação;
3. árvore de clocks;
4. tabela animada de pinagem;
5. cycling `01 → 23 → 45 → 67`;
6. pipeline `DRDY → MUX seguinte → SYNC → WAKEUP → RDATA atual`;
7. diferença entre DRATE, valor, frame e amostra por par;
8. extensão do contador DWT e wrap público do timestamp;
9. arquitetura das threads da aplicação;
10. estrutura dos datasets HDF5.

## 8. Regras de edição e rigor

- Chamar cada cena de código de “fonte do commit fixado” e mostrar o hash curto no canto.
- Não acelerar terminal a ponto de esconder warnings ou resultados.
- Diferenciar reconstituição histórica de execução atual com uma cartela na tela.
- Não usar “tempo real” sem explicar o significado; preferir “aquisição contínua com atualização visual periódica”.
- Não chamar o display ST7735 de osciloscópio: ele mostra apenas diagnóstico de inicialização.
- Não chamar o campo “Oximetria” de medição de SpO₂.
- Não apresentar valores típicos de ENOB do datasheet como medição do protótipo.
- Não dizer que 30 kSPS chegam a cada canal.
- Não dizer que os quatro canais são simultâneos.
- Não apresentar alimentação por bateria como prova de isolamento médico.
- Se uma medição nova divergir da documentação, interromper a edição e investigar; não substituir o dado silenciosamente.

# Parte II — Roteiro detalhado

## 9. Abertura fria — 00:00 a 01:20

### Cena 9.1 — O resultado antes da explicação

**Duração:** 00:00–00:25

**Imagem:** montagem pronta em plano macro; corte para o ST7735; terminal recebendo frames; alternância pelos quatro canais configurados na interface; arquivo HDF5 aparecendo na lista de sessões. A GUI atual desenha somente o canal selecionado.

**Fala:**

> Esta placa está lendo quatro pares diferenciais, agrupando cerca de mil frames por segundo e enviando tudo por USB para uma aplicação Python. O mesmo programa mostra os sinais, processa a janela visível e preserva os dados brutos em HDF5.

**Texto na tela:**

~~~text
4 pares diferenciais sequenciais
≈ 1.000 frames/s
≈ 1.000 amostras/s por par
≈ 4.000 valores/s
~~~

**Edição:** sincronizar cada número com um corte: placa, terminal, GUI e arquivo.

### Cena 9.2 — A prova curta

**Duração:** 00:25–00:48

**Imagem:** gráfico dos intervalos ou terminal do validador; destaque para os números da captura versionada.

**Fala:**

> Na captura de referência, foram 100.005 frames em aproximadamente cem segundos, sem lacunas entre os identificadores observados e com intervalo mediano de mil microssegundos. Chegar a esse resultado exigiu resolver boot e SPI, reorganizar a multiplexação e melhorar a marcação temporal. O transporte funcionou nessa captura, mas ainda possui limitações que veremos adiante.

**Overlay:** `100.005 frames | seq. 15–100.019 | mediana 1.000 µs`.

### Cena 9.3 — A pergunta do vídeo

**Duração:** 00:48–01:20

**Imagem:** apresentador; componentes separados sobre a bancada.

**Fala:**

> Neste vídeo eu vou reconstruir essa trajetória, montar o núcleo digital a partir dos módulos e integrá-lo ao computador e à Raspberry Pi. A gravação parte de uma Black Pill com o bootloader HID já instalado; a alimentação e a fixture analógica só serão montadas quando estiverem documentadas para a unidade filmada. O objetivo não é esconder as decisões difíceis, porque são justamente elas que explicam por que o projeto funciona — e quais limites ele ainda tem.

**Cartela de título:** “Construindo um sistema de aquisição multicanal sequencial com STM32, ADS1256 e Raspberry Pi”.

## 10. Escopo e segurança — 01:20 a 04:20

### Cena 10.1 — O que está sendo construído

**Imagem:** apresentador ao lado de um diagrama simples.

**Fala:**

> Este é um protótipo acadêmico de aquisição e processamento. O núcleo recebe sinais analógicos já condicionados, faz a conversão, transmite contagens digitais e permite visualizar e armazenar sessões. Ele não é um monitor clínico, não possui certificação e não deve orientar diagnóstico.

**Overlay permanente por cinco segundos:** “Protótipo acadêmico — não destinado a diagnóstico”.

### Cena 10.2 — Segurança elétrica

**Imagem:** cabos USB, HDMI, fonte de bancada e osciloscópio; desenhar os possíveis caminhos de terra em vermelho.

**Fala:**

> Há um motivo para a primeira demonstração usar um gerador de bancada e não uma pessoa. USB, HDMI, carregadores e instrumentos aterrados podem formar caminhos de corrente que não foram caracterizados. A montagem atual não demonstra isolamento médico, corrente de fuga ou proteção contra desfibrilação. Alimentar uma parte por bateria, sozinho, não resolve toda a cadeia.

**Ação:** com tudo desligado, retirar fisicamente cabos de eletrodos e desconectar AD8232, Pulse Sensor e qualquer frontend que compartilhe os AINs usados no ensaio. Não conectar o gerador até existir um esquema da fixture com AINP, AINN, retorno, offset, common-mode, impedância e caminho de terra identificados.

### Cena 10.3 — O limite da reprodução analógica

**Imagem:** MUX lógico `01, 23, 45, 67`; trecho do módulo analógico em cinza.

**Fala:**

> A pinagem dos sinais digitais, o firmware e o software são reconstruíveis pelos repositórios. A alimentação exata depende do módulo filmado, e o circuito analógico montado ainda não tem documentação suficiente de filtros, proteção, common-mode e referência de cada entrada negativa. Por isso, o vídeo só ensina uma fixture de bancada depois que seu esquema e suas medições forem produzidos. Uma ligação fisiológica só pode entrar em um tutorial depois de fechar o esquemático, a análise de segurança e o protocolo ético.

## 11. Arquitetura — 04:20 a 08:20

### Cena 11.1 — Caminho do sinal

**Imagem:** animação da cadeia.

~~~text
frontends analógicos
        ↓
AIN0−AIN1 | AIN2−AIN3 | AIN4−AIN5 | AIN6−AIN7
        ↓
ADS1256, um ADC + MUX
        ↓ SPI2
STM32F411
  ├─ SPI3 → ST7735
  └─ USB CDC → PC ou Raspberry Pi
                     ├─ visualização
                     ├─ filtros/FFT
                     └─ HDF5 bruto
~~~

**Fala:**

> Os frontends entregam quatro pares diferenciais ao ADS1256. O conversor possui um único caminho de conversão e alterna o multiplexador. A STM32 controla essa sequência por SPI2, usa outro SPI para o display e transmite cada frame por USB CDC. No host, a aplicação separa leitura serial, visualização e gravação para que desenhar menos pontos não signifique perder dados.

### Cena 11.2 — A palavra mais importante: sequencial

**Imagem:** quatro amostras surgindo em instantes ligeiramente diferentes e depois entrando em uma mesma caixa “frame”.

**Fala:**

> Um frame contém quatro valores, mas eles não nasceram no mesmo instante. Primeiro vem o par 01, depois 23, 45 e 67. O frame é um agrupamento lógico. Essa distinção importa para qualquer análise de fase ou correlação entre canais.

### Cena 11.3 — Quatro taxas diferentes

**Imagem:** tabela animada.

| Grandeza | Valor ou ordem atual |
|---|---:|
| clock do modulador, com CLKIN de 7,68 MHz | aproximadamente 1,92 MHz |
| DRATE do filtro digital | 30 kSPS |
| valores efetivamente transmitidos | aproximadamente 4.000/s |
| frames | aproximadamente 1.000/s |
| amostras de cada par | aproximadamente 1.000/s |

**Fala:**

> Trinta mil amostras por segundo é o código de DRATE do filtro digital, não a taxa útil de cada entrada. Depois do settling do filtro, das trocas de MUX, dos comandos SPI e do agrupamento de quatro resultados, o sistema entrega aproximadamente mil amostras por segundo para cada par.

## 12. Trajetória do desenvolvimento — 08:20 a 15:30

Esta parte deve ser dinâmica. Usar uma linha do tempo com datas, fotos de bancada e pequenos recortes de terminal. Não executar firmware antigo na unidade final.

### Cena 12.1 — 4 e 5 de maio: ambiente, DFU e o primeiro LED

**Imagem:** cartela “4–5 de maio de 2026”; PlatformIO; Black Pill; LED PC13.

**Fala:**

> O projeto começou pela pergunta mais básica: como programar a Black Pill no Linux? A primeira base usou C, HAL e PlatformIO, com gravação pelo DFU interno. O primeiro teste foi o LED ativo em nível baixo no PC13. Ele validou compilação, gravação e execução, mas também trouxe o primeiro acidente útil da história.

### Cena 12.2 — O bootloader que foi sobrescrito

**Imagem:** animação da Flash. Uma gravação ocupa `0x08000000`; o bootloader desaparece; depois o mapa correto é reconstruído.

**Fala:**

> Ao gravar a aplicação no começo da Flash, o bootloader HID da WeAct foi sobrescrito. A recuperação ensinou que não basta copiar um binário para outro endereço. Linker, tabela de vetores e endereço de gravação precisam concordar.

~~~text
0x08000000 ┌────────────────────────────┐
           │ WeAct HID, 16 KiB         │
0x08004000 ├────────────────────────────┤
           │ aplicação, 496 KiB        │
0x08080000 └────────────────────────────┘
~~~

**Fala complementar:**

> Na versão final, a seção de vetores começa em `0x08004000`, o VTOR aponta para o mesmo endereço e o vetor de reset também cai dentro da área da aplicação.

### Cena 12.3 — 6 a 8 de maio: CubeMX, barramentos e divisão de responsabilidades

**Imagem:** CubeMX; ADS1256 em SPI2; ST7735 em SPI3; Raspberry Pi ao lado.

**Fala:**

> A base migrou para STM32CubeMX e CubeIDE. O ADS1256 ficou no SPI2 e o display no SPI3. Nesse período também ficou claro que a STM32F411 não era a plataforma para gerar uma interface HDMI completa. A arquitetura foi dividida: microcontrolador para aquisição e transporte, display pequeno para diagnóstico e Raspberry Pi para interface, processamento e armazenamento.

### Cena 12.4 — 11 a 13 de maio: pinos e o SPI rápido demais

**Imagem:** `PA8 = DRDY`, `PA9 = PDWN`; oscilograma ou animação de clock; cálculo.

**Fala:**

> DRDY e PDWN chegaram à pinagem atual em PA8 e PA9. Depois surgiu um sintoma clássico: MUX lendo zero e DRDY travado. O código gerado havia colocado o SPI2 com divisor 2. Com PCLK1 de 48 MHz, isso são 24 MHz — muito acima do permitido pelo ADS1256 com clock de 7,68 MHz.

**Equação na tela:**

\[
f_{\mathrm{SCLK,max}}=\frac{7{,}68\ \mathrm{MHz}}{4}=1{,}92\ \mathrm{MHz}
\]

\[
f_{\mathrm{SPI2}}=\frac{48\ \mathrm{MHz}}{32}=1{,}5\ \mathrm{MHz}
\]

**Fala:**

> O divisor 32 corrigiu a comunicação. Esse problema continua relevante porque o fonte compilado está certo, mas o arquivo `.ioc` ainda registra o divisor antigo. Regenerar sem revisar pode reintroduzir a falha.

### Cena 12.5 — Maio e junho: aplicação e Raspberry Pi

**Imagem:** histórico visual da GUI; arquitetura de threads; Raspberry Pi.

**Fala:**

> Em paralelo nasceu a aplicação Python. Desde o começo, a janela visual foi separada da gravação integral. Em junho, a Raspberry Pi passou a ser tratada como equipamento dedicado. A execução por framebuffer foi confirmada em uma instalação Lite, enquanto a sessão gráfica automática ainda ficou sem uma receita final completamente reproduzível.

### Cena 12.6 — 2 de julho: o gargalo real

**Imagem:** contador subindo de cerca de 750 para cerca de 1.000 frames/s.

**Fala:**

> Com quatro pares ativos, a primeira captura mostrou algo entre 734 e 764 frames por segundo. O display não era o gargalo. O problema principal era a ordem dos comandos do ADC: cada canal era iniciado e só depois aguardado. A virada veio ao transformar a leitura em pipeline. Nós veremos esse mecanismo no código final daqui a pouco.

### Cena 12.7 — 8 de julho: microssegundos

**Imagem:** timestamps em milissegundos virando microssegundos; DWT contando ciclos.

**Fala:**

> Por fim, o timestamp saiu do SysTick em milissegundos e passou para o contador de ciclos DWT. Isso permitiu observar intervalos próximos de mil microssegundos e validar a cadência com muito mais resolução. Também criou um limite público de 71 minutos que precisa ser tratado pelo receptor.

**Transição:** componentes antigos somem da mesa; permanece somente a montagem atual.

## 13. Materiais e preparação — 15:30 a 20:00

### Cena 13.1 — Núcleo do sistema

**Imagem:** câmera superior; cada item entra no quadro quando é citado.

**Fala:**

> Para o núcleo atual, eu uso uma WeAct Black Pill com STM32F411CEU6, um módulo ADS1256, um ST7735S de 1,8 polegada, cabos curtos e um computador ou Raspberry Pi. A montagem documentada também inclui dois AD8232, um Pulse Sensor Amped e um quarto canal auxiliar, mas a reprodução segura deste vídeo começa por uma fonte de bancada conhecida.

**Lista na tela:**

- Black Pill STM32F411CEU6;
- ADS1256 com clock de 7,68 MHz;
- ST7735S 128 × 160;
- protoboard ou placa de interconexão;
- fios curtos;
- cabo USB de dados;
- multímetro;
- fonte e gerador de funções adequados;
- analisador lógico ou osciloscópio, recomendado;
- computador Linux; Raspberry Pi opcional nesta etapa.

### Cena 13.2 — Identificar módulos, não apenas nomes comerciais

**Imagem:** macro da frente e do verso de cada módulo.

**Fala:**

> Módulos com o mesmo nome podem ter reguladores, level shifters e referências diferentes. Antes de copiar qualquer tensão de alimentação, identifique a placa exata, consulte o esquema disponível e meça VREF, AVDD e DVDD. O ADS1256 não possui um pino chamado AVSS; qualquer rail negativo da placa precisa ser identificado pelo circuito real do módulo.

### Cena 13.3 — Fixar as versões

**Imagem:** captura de terminal limpa.

**Fala:**

> Para que o que aparece na tela corresponda ao vídeo, vou fixar exatamente os commits auditados.

~~~bash
cd /caminho/dos/repositorios
git clone https://github.com/Tyrion1606/blackpill_ads1256-display.git
git -C blackpill_ads1256-display checkout 7fc7d6d724f3d762ea08447b26180b6c7ec7d27a
git -C blackpill_ads1256-display status --short
~~~

~~~bash
cd /caminho/dos/repositorios
git clone https://github.com/AlexAndrei3663/processamento_biomedico.git
git -C processamento_biomedico checkout d34b56bec961cbea028f5cc8573e845f4e215c63
git -C processamento_biomedico status --short
~~~

**Ação:** mostrar que os dois `git status --short` não produzem saída.

## 14. Montagem digital — 20:00 a 30:30

### Cena 14.1 — Regra zero: montar desligado

**Imagem:** desconectar USB e fontes em plano contínuo.

**Fala:**

> Toda a pinagem será feita sem alimentação. Primeiro eu monto sinais e terra; depois verifico continuidade e curtos; só então energizo e meço os rails.

### Cena 14.2 — Sinais digitais do ADS1256 para a STM32

**Imagem:** visão superior perfeitamente orientada; inserir um fio por vez e destacar origem e destino na tela.

**Cartela obrigatória:** “Tabela de sinais — alimentação não incluída”.

| Ordem de filmagem | ADS1256 | STM32 | Observação narrada |
|---:|---|---|---|
| 1 | CS | PB12 | GPIO ativo baixo |
| 2 | SCLK | PB13 | SPI2 SCK |
| 3 | DOUT | PB14 | ADC para MISO da STM32 |
| 4 | DIN | PB15 | MOSI da STM32 para ADC |
| 5 | DRDY | PA8 | entrada com pull-up, ativo baixo |
| 6 | PDWN | PA9 | saída, mantida alta em operação |

**Fala:**

> CS vai ao PB12, clock ao PB13, DOUT ao PB14 e DIN ao PB15. DOUT é a saída do ADC; DIN é a entrada dele. DRDY vai ao PA8 e PDWN ao PA9. Esses dois últimos não devem ser invertidos.

**Insert de código:** `Core/Inc/main.h`, linhas 60–73, e `Core/Src/gpio.c`, linhas 72–90.

### Cena 14.3 — Sinais digitais do ST7735 para a STM32

**Imagem:** inserir os cinco fios de sinal.

**Cartela obrigatória:** “Tabela de sinais — VCC, GND e backlight dependem do módulo filmado”.

| ST7735 | STM32 | Função |
|---|---|---|
| SCK | PB3 | SPI3 SCK |
| SDA/MOSI | PB5 | SPI3 MOSI |
| CS | PB4 | seleção manual |
| DC/A0 | PB6 | dados ou comando |
| RESET | PB7 | reset do display |

**Fala:**

> O display usa outro periférico. Clock no PB3, dados no PB5, CS no PB4, DC no PB6 e reset no PB7. O MISO não é usado. PB3 e PB4 conflitam com JTAG completo, então o projeto mantém apenas Serial Wire para depuração.

### Cena 14.4 — Alimentação específica da unidade filmada

**Imagem:** frente e verso dos módulos; silk-screen; esquema ou diagrama produzido para a unidade; fonte com limitação de corrente ainda desligada.

**Fala:**

> As tabelas anteriores contêm somente sinais. Elas não autorizam energizar os módulos. Antes de filmar a primeira ligação, é obrigatório identificar o PCB exato e produzir uma tabela separada com cada pino de alimentação do ADS1256 e do ST7735, incluindo entrada do módulo, AVDD, DVDD, AGND, DGND, VCC, GND, backlight, reguladores, level shifters, origem de cada rail e união dos domínios de terra.

**Regra de produção:** preencher e filmar a tabela abaixo com os nomes reais do módulo. Não publicar valores genéricos nem prosseguir se algum campo permanecer desconhecido.

| Módulo/pino real | Origem | Tensão nominal | Tensão medida sem carga | Tensão medida em operação | Limite de corrente | Evidência |
|---|---|---:|---:|---:|---:|---|
| entrada de alimentação do ADS1256 | a medir | a confirmar | a medir | a medir | a definir | esquema + multímetro |
| AVDD−AGND | interna/externa, a confirmar | a confirmar | a medir | a medir | n/a | pontos do PCB |
| DVDD−DGND | interna/externa, a confirmar | a confirmar | a medir | a medir | n/a | pontos do PCB |
| VREFP−VREFN | referência, a identificar | nominal a confirmar | a medir | a medir | n/a | pontos do PCB |
| VCC do ST7735 | a confirmar | a confirmar | a medir | a medir | a definir | esquema + multímetro |
| backlight do ST7735 | a confirmar | a confirmar | a medir | a medir | a definir | esquema + multímetro |

**Fala:**

> Se essa tabela não puder ser fechada, a construção filmada deve começar com um núcleo previamente montado e validado. Nesse caso, o vídeo pode explicar os sinais, mas não pode ensinar a ligação de potência nem dizer que montou o sistema do zero.

### Cena 14.5 — Mapeamento analógico lógico

**Imagem:** bornes AIN0 a AIN7; cores por par.

**Fala:**

> No firmware, os pares são fixos. `d1` é AIN0 menos AIN1; `d2`, AIN2 menos AIN3; `d3`, AIN4 menos AIN5; e `d4`, AIN6 menos AIN7.

~~~text
d1 → MUX 0x01 → AIN0 − AIN1
d2 → MUX 0x23 → AIN2 − AIN3
d3 → MUX 0x45 → AIN4 − AIN5
d4 → MUX 0x67 → AIN6 − AIN7
~~~

**Fala de advertência:**

> Isto descreve a seleção do MUX, não define sozinho onde ligar eletrodos, referência, filtros ou proteção. Um AIN só pode receber a fixture de bancada depois que qualquer frontend ligado ao mesmo nó for desconectado com o sistema desligado e que retorno, impedância, amplitude, offset, carga, common-mode e terras da fixture estiverem documentados.

### Cena 14.6 — Faixa diferencial

**Imagem:** fórmula e escala assinada de 24 bits.

**Fala:**

> O código é assinado, de menos 8.388.608 a mais 8.388.607. Para uma referência `VREF` e ganho `G`, cada extremo diferencial ideal tem magnitude `2 VREF dividido por G`, e o span completo é `4 VREF dividido por G`.

\[
V_{\mathrm{FS}}=\frac{2V_{\mathrm{REF}}}{G}
\qquad
V_{\mathrm{span}}=\frac{4V_{\mathrm{REF}}}{G}
\]

**Fala:**

> Com VREF nominal de 2,5 volts e ganho um, isso corresponde idealmente a aproximadamente menos cinco a mais cinco volts diferenciais. Isso não autoriza aplicar menos cinco volts físicos a um pino referido ao terra. Cada entrada ainda precisa respeitar os limites absolutos e de common-mode.

### Cena 14.7 — Inspeção antes de energizar

**Imagem:** multímetro em continuidade e resistência.

**Checklist narrado e mostrado:**

1. DIN e DOUT não estão trocados;
2. PA8 e PA9 estão corretos;
3. não existe curto entre 5 V, 3,3 V e GND;
4. todos os terras previstos têm continuidade;
5. os fios de SPI são curtos e afastados das entradas analógicas;
6. a tensão aceita por cada módulo foi confirmada;
7. a tabela específica de alimentação foi integralmente preenchida;
8. a fonte está limitada em corrente antes da primeira energização;
9. nenhum frontend e gerador dirigem o mesmo nó;
10. a diferença de potencial entre os terras foi medida antes de uni-los;
11. gerador e instrumento compartilham referência apenas pelo caminho planejado.

### Cena 14.8 — Primeira energização e medições

**Imagem:** energizar com fonte limitada em corrente; medir ponto por ponto; mostrar leituras grandes na edição.

**Fala:**

> Agora eu energizo sem nenhum sinal fisiológico e meço, nesta unidade, 5 volts, 3,3 volts, AVDD, DVDD, diferença entre AGND e DGND e VREFP menos VREFN. Os valores que aparecem na tela são medições desta montagem, não números presumidos pelo código.

**Regra de produção:** inserir os valores reais somente depois de medir. Se a corrente atingir o limite ou algum rail estiver fora do esperado, desligar imediatamente e não continuar a cena.

## 15. Base do firmware — 30:30 a 39:30

### Cena 15.1 — O mapa de memória não é detalhe

**Imagem:** captura de `STM32F411CEUX_FLASH.ld`, seguida da animação do mapa de Flash.

**Fala:**

> O bootloader ocupa os primeiros 16 kibibytes. Por isso, o linker define a aplicação a partir de `0x08004000`, com 496 kibibytes disponíveis. O firmware também reposiciona a tabela de vetores para esse endereço antes de entrar no funcionamento normal.

**Trechos a mostrar:**

- `STM32F411CEUX_FLASH.ld`, linhas 47–48;
- `Core/Inc/application_config.h`, linhas 7–14;
- `Core/Src/main.c`, linhas 194–203.

**Overlay de prova:**

~~~text
.isr_vector = 0x08004000
Reset_Handler alinhado = 0x080058DC
palavra no vetor = 0x080058DD, bit Thumb = 1
BIN = 39.256 bytes
~~~

### Cena 15.2 — Árvore de clocks

**Imagem:** animação partindo do cristal de 25 MHz.

~~~text
HSE 25 MHz
  ↓ PLLM /25
1 MHz
  ↓ PLLN ×192
192 MHz
  ├─ PLLP /2 → SYSCLK/HCLK 96 MHz
  └─ PLLQ /4 → USB 48 MHz

APB1 /2 → PCLK1 48 MHz
APB2 /1 → PCLK2 96 MHz
~~~

**Fala:**

> A Black Pill usa HSE de 25 megahertz. O PLL leva o núcleo a 96 megahertz e gera os 48 megahertz exigidos pelo USB. PCLK1 fica em 48 megahertz e alimenta os dois cálculos de SPI que veremos agora.

**Fonte na tela:** `Core/Src/main.c`, linhas 152–190.

### Cena 15.3 — Dois dispositivos, dois modos SPI

**Imagem:** tela dividida entre ADS1256 e ST7735.

| Periférico | Barramento | Modo | Divisor | SCLK |
|---|---|---:|---:|---:|
| ADS1256 | SPI2 | 1 | 32 | 1,5 MHz |
| ST7735 | SPI3 | 0 | 2 | 24 MHz |

**Fala:**

> O ADS1256 usa CPOL zero e captura na segunda borda, modo 1, com divisor 32. O display usa modo 0 e divisor 2. Os dois barramentos operam em polling, oito bits e MSB primeiro, com seleção manual.

**Trechos a mostrar:** `Core/Src/spi.c`, linhas 41–52 e 73–84.

**Cartela de atenção:**

> O `spi.c` compilado usa divisor 32. O `.ioc` deste commit ainda registra divisor 2 para SPI2. Não regenerar o projeto antes de conciliar essa divergência.

### Cena 15.4 — Configuração do ADS1256

**Imagem:** tabela de registradores; destacar uma linha por vez.

| Parâmetro | Valor vigente |
|---|---:|
| DRATE | `0xF0`, 30 kSPS nominais |
| PGA | 1 |
| ADCON | `0x00` |
| buffer interno | desabilitado pelo estado padrão |
| MUX inicial | `0x01` |
| leitura | `RDATA` sob comando |
| calibração | `SELFCAL` |

**Fala:**

> O ADC começa em AIN0 menos AIN1, com ganho um e DRATE `0xF0`. O firmware não usa leitura contínua RDATAC; ele envia RDATA para cada resultado. O buffer interno permanece desligado porque o registrador STATUS não é escrito.

### Cena 15.5 — Sequência de inicialização

**Imagem:** fluxograma vertical; o display ao lado reage ao final.

**Fala:**

> A inicialização libera CS, mantém PDWN alto, espera cinquenta milissegundos, envia RESET, aguarda DRDY com timeout, sai do modo contínuo, escreve MUX, ganho e DRATE, executa autocalibração, aguarda novamente e relê o MUX. Somente depois o display recebe a tela de status.

**Fluxo na tela:**

~~~text
CS alto + PDWN alto
       ↓ 50 ms
RESET → aguardar DRDY
       ↓
SDATAC
       ↓
MUX 0x01 → ADCON 0x00 → DRATE 0xF0
       ↓
SELFCAL → aguardar DRDY
       ↓
readback MUX = 0x01
~~~

**Fonte:** `Core/Src/adc_ads1256.c`, linhas 159–244.

### Cena 15.6 — Conversão assinada de 24 bits

**Imagem:** três bytes chegando pelo SPI e o bit 23 sendo estendido até 32 bits.

**Fala:**

> Cada resultado chega em três bytes. O firmware concatena os 24 bits e estende o sinal para um inteiro de 32 bits. Isso preserva corretamente toda a faixa negativa e positiva antes da formatação textual.

**Fonte:** `Core/Src/adc_ads1256.c`, linhas 333–350.

## 16. Aquisição, pipeline e taxa — 39:30 a 48:30

### Cena 16.1 — A forma lenta

**Imagem:** reconstrução gráfica, identificada como “estado anterior — não executar”.

~~~text
para cada canal:
    escrever MUX
    SYNC
    WAKEUP
    esperar DRDY
    RDATA
~~~

**Fala:**

> Na primeira versão com quatro pares, cada canal era selecionado, iniciado e só então aguardado. Uma captura mostrou aproximadamente 764 frames por segundo no computador e 734 pelos timestamps da MCU. A sequência continuava ordenada, mas a meta de cerca de mil frames por segundo não era atingida.

**Selo visual:** `HISTÓRICO — usado apenas para explicar a decisão`.

### Cena 16.2 — Diagnóstico do gargalo

**Imagem:** ícones de atraso, SPI, `snprintf`, USB e display; riscar o display como causa naquele estado.

**Fala:**

> A investigação separou os custos: atrasos fixos, comandos SPI, formatação com `snprintf`, escrita USB bloqueante e a ordem da multiplexação. O display já estava fora do laço principal; portanto, ele não explicava essa perda. A maior oportunidade era deixar o ADC converter o próximo canal enquanto o firmware lia o resultado atual.

### Cena 16.3 — O pipeline vigente

**Imagem:** animação ocupando toda a tela. Manter a cor do dado atual e do próximo MUX distintas.

~~~text
DRDY d1 ↓ → MUX d2 → SYNC → WAKEUP → RDATA d1
DRDY d2 ↓ → MUX d3 → SYNC → WAKEUP → RDATA d2
DRDY d3 ↓ → MUX d4 → SYNC → WAKEUP → RDATA d3
DRDY d4 ↓ → MUX d1 → SYNC → WAKEUP → RDATA d4
                                            frame completo
~~~

**Fala:**

> Em regime, primeiro aguardamos o resultado atual. Em seguida já programamos e iniciamos o próximo par. Só então lemos os três bytes que estavam prontos. Quando `d4` termina, a conversão de `d1` do frame seguinte já começou.

**Insert de código:** `Core/Src/adc_ads1256.c`, linhas 393–436. Mostrar somente o laço e as chamadas essenciais.

### Cena 16.4 — Estado persistente do pipeline

**Imagem:** duas pequenas variáveis representadas como memória entre chamadas.

**Fala:**

> A função mantém duas informações estáticas: se o pipeline já foi iniciado e qual canal está pronto. Isso reduz o trabalho entre frames, mas significa que uma reinicialização do driver em tempo de execução não possui hoje uma rotina própria para zerar esse estado.

### Cena 16.5 — A evolução medida

**Imagem:** barras crescendo; sempre identificar captura e tipo de timestamp.

| Estado | Taxa aproximada pelo timestamp da MCU |
|---|---:|
| antes do pipeline | 734 frames/s |
| primeiro pipeline | 981 frames/s |
| captura seguinte | 1.000,1 frames/s |
| captura final em microssegundos | 1.000,023 frames/s |

**Fala:**

> O ganho principal não veio de violar o limite de clock. Veio de reorganizar o trabalho. O primeiro pipeline chegou a cerca de 981 frames por segundo e as capturas seguintes atingiram aproximadamente mil.

### Cena 16.6 — O custo do SPI como ordem de grandeza

**Imagem:** nove bytes se acumulando.

| Operação por leitura | Bytes |
|---|---:|
| WREG MUX | 3 |
| SYNC | 1 |
| WAKEUP | 1 |
| RDATA | 1 |
| dados | 3 |
| total simplificado | 9 |

**Fala:**

> Uma aproximação conta nove bytes, ou 72 bits, por resultado. A diferença entre operar em 1,5 e 1,92 megahertz custa cerca de 10,5 microssegundos por leitura. Essa conta ajuda a entender a ordem de grandeza, mas não inclui toda a HAL, GPIO, formatação e USB; portanto, não deve ser apresentada com precisão experimental.

\[
\Delta t_{\mathrm{SPI}}=
72\left(\frac{1}{1{,}5\ \mathrm{MHz}}-
\frac{1}{1{,}92\ \mathrm{MHz}}\right)
=10{,}5\ \mu s
\]

### Cena 16.7 — Repetir a escada das taxas

**Imagem:** os números vão descendo do ADC ao usuário.

**Fala:**

> O resultado final precisa ser nomeado corretamente: DRATE de 30 kSPS, aproximadamente quatro mil valores lidos por segundo, quatro valores por frame, aproximadamente mil frames por segundo e, portanto, aproximadamente mil amostras por segundo em cada par.

### Cena 16.8 — Limites temporais do cycling

**Imagem:** os quatro pontos dentro de um frame sem valores numéricos de offset.

**Fala:**

> Ainda não há uma medição formal da defasagem entre os pares. Não devemos transformar a média do período do frame em offset exato por canal. Para fechar essa questão, será necessário marcar eventos com GPIO e medir cada DRDY e cada troca de MUX em instrumento externo.

## 17. Timestamp, frame e USB — 48:30 a 54:00

### Cena 17.1 — Contando ciclos em vez de milissegundos

**Imagem:** `DWT->CYCCNT` aumentando a 96 milhões de ciclos por segundo.

**Fala:**

> Para enxergar variações menores que um milissegundo, o firmware usa o contador de ciclos DWT. A 96 megahertz existem 96 ciclos por microssegundo. A função detecta quando o contador cru volta a zero, estende os ciclos internamente para 64 bits e depois divide pela frequência do núcleo.

**Fonte:** `Core/Src/microsecond_delay.c`, linhas 6–44.

### Cena 17.2 — Dois wraps diferentes

**Imagem:** duas linhas do tempo.

\[
T_{\mathrm{CYCCNT}}=
\frac{2^{32}}{96.000.000}
=44{,}7392427\ \mathrm{s}
\]

\[
T_{\mathrm{timestamp}}=
2^{32}\ \mu s
=71\ \mathrm{min}\ 34{,}967\ \mathrm{s}
\]

**Fala:**

> O contador cru dá wrap a cada 44,739 segundos, e a extensão interna já atravessou esse evento em teste. Entretanto, o valor público ainda é convertido para `uint32_t` em microssegundos. Ele volta a zero depois de 71 minutos e 34,967 segundos.

### Cena 17.3 — O instante representado

**Imagem:** timestamp aparece antes da caixa `read frame`; as quatro conversões aparecem deslocadas.

**Fala:**

> O timestamp é lido imediatamente antes da chamada que completa o frame. Ele não é o instante exato de `d1`, nem de `d2`, `d3` ou `d4`. É um marcador do ciclo de software que agrupa os quatro resultados.

**Fonte:** `Core/Src/main.c`, linhas 113–116.

### Cena 17.4 — Gramática do frame

**Imagem:** uma linha real; colorir cada campo.

~~~text
FRAME,<sequence_id>,<timestamp_us>,<d1>,<d2>,<d3>,<d4>\r\n
~~~

**Fala:**

> Cada linha começa com a palavra FRAME, traz um contador de sequência de 32 bits, o timestamp em microssegundos e quatro inteiros assinados. A sequência sobe uma vez por frame e volta a zero a cada reset.

**Fonte:** `Core/Src/main.c`, linhas 112–139.

### Cena 17.5 — USB CDC

**Imagem:** pacote textual entrando em blocos USB; configuração 115200 aparece como etiqueta de software, não como clock físico.

**Fala:**

> O dispositivo enumera como CDC ACM em USB Full Speed. O valor 115200 selecionado no host é line coding virtual; não é uma UART física limitando o cabo USB. O wrapper atual tenta novamente enquanto a pilha retorna `USBD_BUSY` e abandona depois de aproximadamente um segundo, sem devolver o status ao laço principal.

**Fala de limite:**

> `CDC_Transmit_FS` recebe um ponteiro para o buffer local `csvLineText`, e não existe confirmação por frame, CRC ou fila explícita no firmware. A captura de cem segundos não mostrou corrupção, mas não formaliza a vida útil desse buffer nem garante integridade ponta a ponta para todas as condições.

**Fonte:** `Core/Src/usb_cdc_serial.c`, linhas 6–27.

**Frase de transição:**

> Agora que sabemos o que o binário deve fazer, vamos provar que ele foi construído para o endereço certo e colocá-lo na placa.

## 18. Compilação, gravação e primeiro boot — 54:00 a 61:00

### Cena 18.1 — Compilar a versão fixada

**Imagem:** captura direta do terminal, fonte grande, sem notificações.

**Fala:**

> Antes do build, existe uma limitação que precisa aparecer: o `Debug/makefile` contém o caminho absoluto do computador original nas linhas de dependência e na opção `-T`. No computador auditado, o checkout já está em `/home/davi/repos/blackpill_ads1256+display`. Em outro caminho, é preciso importar o projeto no CubeIDE ou substituir somente essas referências pelo caminho absoluto do linker do novo checkout, mostrar o diff e conferir que origem e tamanho da Flash não mudaram.

**Regra de filmagem:** resolver e demonstrar o caminho antes de executar `make`. Não apresentar o comando abaixo como universal enquanto o makefile versionado continuar absoluto.

**Fala:**

> Depois de conciliar o caminho, entro explicitamente no repositório, acrescento a toolchain auditada ao PATH e chamo o alvo `all`.

~~~bash
cd /caminho/dos/repositorios/blackpill_ads1256-display
export PATH="/opt/st/stm32cubeide_2.1.1/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.linux64_1.0.100.202602081740/tools/bin:$PATH"
make -C Debug all -j4
~~~

### Cena 18.2 — Inspecionar, não apenas confiar no “build succeeded”

**Imagem:** executar um comando por vez e destacar a linha relevante.

~~~bash
arm-none-eabi-size Debug/blackpill_ads1256+display.elf
arm-none-eabi-objdump -h Debug/blackpill_ads1256+display.elf
od -An -tx4 -N8 Debug/blackpill_ads1256+display.bin
sha256sum Debug/blackpill_ads1256+display.bin
~~~

**Critérios mostrados na tela:**

- `.isr_vector` em `0x08004000`;
- primeira palavra `0x20020000`;
- palavra do vetor de reset `0x080058DD`, com bit Thumb igual a 1;
- símbolo `Reset_Handler` alinhado em `0x080058DC`;
- BIN com 39.256 bytes;
- SHA-256 `f7334208b5126c9154046320ddf6dbfae54d35ca2d6065788b25f7c6ca834a0f`.

**Fala:**

> Este é o hash do artefato auditado, não um valor universal exigido de qualquer recompilação. Se a tomada produzir outro hash, preserve os dois arquivos, identifique fonte, toolchain e configuração usados e repita as verificações antes de gravar a placa.

### Cena 18.3 — Entrar no HID Bootloader

**Imagem:** macro do botão KEY e reset; terminal com `lsusb`.

**Fala:**

> Com o bootloader WeAct já instalado, mantenho KEY pressionado durante o reset e confirmo o dispositivo `0483:572a`. Esse é o HID da Flash, diferente do DFU interno `0483:df11`.

**Limite de reprodutibilidade:** a origem exata, a versão e o SHA-256 do `WeAct_HID_Flash-CLI` e do HEX usado historicamente para restaurar o bootloader não foram preservados nos registros auditados. Antes da publicação, arquivar o commit ou binário da CLI e do bootloader, calcular hashes e colocar esses dados na descrição. Até isso ocorrer, tratar ambos como pré-requisitos externos, não como parte reproduzida pelo vídeo.

### Cena 18.4 — Gravar o aplicativo

**Imagem:** terminal e placa no mesmo quadro, se possível.

~~~bash
sudo ./WeAct_HID_Flash-CLI \
  /caminho/Debug/blackpill_ads1256+display.bin
~~~

**Fala:**

> O arquivo já foi linkado para `0x08004000`. Depois da gravação, eu libero KEY e reinicio normalmente.

**Nota editorial:** não ensinar a restauração do bootloader nem distribuir a CLI enquanto esses artefatos não estiverem fixados por origem, versão e hash. Se o HID estiver ausente, pausar a produção, selecionar e arquivar oficialmente os artefatos antes de filmar.

### Cena 18.5 — Primeiro boot

**Imagem:** boot do ST7735 em plano contínuo; em seguida `ls /dev/ttyACM*` e o terminal serial.

**Saída esperada:**

~~~text
# Inicializando ADS1256...
MUX do ADS1256 lido: 0x01
# ADS1256 OK. Iniciando leitura.
# Formato CSV: FRAME,seq,t_us,d1,d2,d3,d4
FRAME,0,...,...,...,...,...
~~~

**Fala:**

> A tela reporta o MUX lido, a configuração e estimativas codificadas no firmware; ela não mede a taxa. A cadência será confirmada separadamente pela captura de cem segundos. O display é desenhado uma vez na inicialização e não exibe formas de onda. No terminal, as linhas fixas começam com cerquilha e podem ser ignoradas pelo leitor. A linha dinâmica do MUX ainda não começa com cerquilha e pode ser contada como inválida se for capturada.

### Cena 18.6 — Diagnóstico rápido se não iniciar

**Imagem:** matriz com sintoma e primeira inspeção.

| Sintoma | Verificar primeiro |
|---|---|
| sem HID | KEY/reset, cabo de dados, `lsusb`, presença do bootloader |
| aplicativo não inicia | linker, VTOR, vetor de reset, endereço do BIN |
| MUX `0x00` ou `0xFF` | SPI2 modo 1, 1,5 MHz, CS, DIN/DOUT e alimentação |
| timeout de inicialização | DRDY em PA8, PDWN em PA9, clock do ADS |
| sem `/dev/ttyACM*` | clock USB de 48 MHz, cabo, enumeração e logs do kernel |
| display apagado | SPI3, CS/DC/RESET, alimentação e orientação do módulo |

## 19. Validação de 100 segundos — 61:00 a 67:00

### Cena 19.1 — Preparar a porta

**Imagem:** fechar a GUI; mostrar que somente o validador consumirá a ACM.

**Fala:**

> Uma porta serial só pode ter um consumidor nesta demonstração. Eu fecho a interface, identifico a ACM correta, ajusto `PORTA_SERIAL` no script e mantenho quatro canais e cem segundos.

### Cena 19.2 — Executar e registrar o validador integralmente

~~~bash
cd /caminho/dos/repositorios/blackpill_ads1256-display
python3 grava_serial_csv.py
~~~

**Imagem:** não cortar os momentos de início e fim; acelerar apenas o trecho central, mantendo um relógio visível e indicando a aceleração.

**Fala durante o início:**

> O script separa logs, valida o número de campos, sequência e timestamp e grava a captura com timestamps do computador e da MCU. A captura de referência atravessou exatamente dois wraps do contador DWT cru, mas não o wrap público de 71 minutos. Na nova tomada, registrar quantos eventos foram realmente atravessados em vez de inferir apenas pela duração.

### Cena 19.3 — Ler o resultado com precisão

**Imagem:** cartão de evidência `MEDIDO EM CAPTURA VERSIONADA — firmware 7fc7d6d`.

| Métrica | Captura de referência |
|---|---:|
| frames | 100.005 |
| sequência observada | 15–100.019 |
| gaps entre esses IDs | 0 |
| taxa pelo PC | 1.000,055731 frames/s |
| taxa pela MCU | 1.000,022680 frames/s |
| `dt` mínimo | 997 µs |
| `dt` mediano | 1.000 µs |
| `dt` máximo | 1.481 µs |

**Fala:**

> O arquivo começa no ID 15, portanto a afirmação correta é: zero saltos entre os IDs observados de 15 a 100.019. Isso não prova que nenhuma linha anterior existiu ou que o sistema jamais possa perder dados. A captura prova a cadência, a ordenação e a continuidade desse intervalo de cem segundos.

### Cena 19.4 — O que esse ensaio não prova

**Imagem:** dividir em “provado” e “não provado”.

**Fala:**

> Este ensaio não mede ENOB, exatidão de tensão, diafonia, settling, resposta em frequência, segurança ou operação após 71 minutos. Uma taxa correta é condição necessária, não validação completa do instrumento.

**Transição:** fechar o terminal e abrir o repositório Python.

## 20. Aplicação Python, HDF5 e Raspberry Pi — 67:00 a 85:00

| Tempo interno | Cena |
|---:|---|
| 67:00–70:00 | procedimento de instalação |
| 70:00–71:30 | abertura da interface |
| 71:30–74:00 | configuração dos quatro canais |
| 74:00–76:00 | arquitetura de threads e buffers |
| 76:00–78:00 | conversão, filtros e espectro |
| 78:00–82:00 | gravação e evidência HDF5 |
| 82:00–84:30 | execução manual na Raspberry Pi |
| 84:30–85:00 | regra do rollover |

### Cena 20.1 — Procedimento atual de instalação

**Imagem:** terminal no commit fixado da aplicação.

~~~bash
cd /caminho/dos/repositorios/processamento_biomedico
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
sudo usermod -a -G dialout "$USER"
~~~

**Fala:**

> O programa exige Python 3.10 ou posterior e usa PyQt5, PyQtGraph, PySerial, NumPy, SciPy e h5py. Depois de adicionar o usuário ao grupo `dialout`, é necessário encerrar e abrir novamente a sessão. As versões das dependências ainda não estão fixadas por lockfile; portanto, isto é o procedimento atual, não uma garantia de ambiente idêntico no futuro.

**Evidência a publicar:** versão do sistema operacional, arquitetura, `python --version` e saída de `.venv/bin/python -m pip freeze` da máquina filmada.

### Cena 20.2 — Abrir a interface

~~~bash
QT_QPA_PLATFORM=xcb .venv/bin/python main.py \
  --fullscreen \
  --update-interval-ms 150 \
  --max-plot-points 3000 \
  --recording-queue-capacity 8192 \
  --recording-batch-size 256 \
  --recording-flush-interval-ms 1000
~~~

**Fala:**

> Este comando usa a sessão gráfica XCB, atualização visual a cada 150 milissegundos, no máximo três mil pontos desenhados, fila de 8.192 frames e lotes de gravação de 256.

### Cena 20.3 — Configuração obrigatória de quatro canais

**Imagem:** gravação de cada clique, sem cortes que escondam a ordem.

1. porta ACM correta;
2. line coding 115200;
3. taxa base 1.000 Hz;
4. canal 0: ECG 1;
5. canal 1: ECG 2;
6. canal 2: PPG;
7. canal 3: Outro ou Auxiliar;
8. VREF medida ou explicitamente nominal;
9. PGA 1;
10. modo raw;
11. filtros desligados.

**Fala:**

> A configuração limpa contém apenas três canais. O firmware envia quatro valores; sem adicionar o quarto, o parser espera seis campos totais, recebe sete e rejeita todas as linhas. A taxa de mil hertz nesta tela não reconfigura o ADC. Ela é metadado e parâmetro para filtros e FFT.

### Cena 20.4 — Como os frames atravessam o programa

**Imagem:** animação das threads.

~~~text
USB CDC
   ↓
SerialReader em QThread
   ├─ readline, timeout 100 ms
   ├─ parser
   └─ lotes de até 20 frames
          ↓
MainController, thread da GUI
   ├─ monitor de sequência/timestamp
   ├─ ring buffers ao vivo
   └─ fila de gravação
          ↓
SessionWriter
   └─ HDF5 incremental
~~~

**Fala:**

> O leitor serial fica fora da thread da interface, ignora linhas vazias ou iniciadas por cerquilha e entrega lotes. O controlador verifica sequência e tempo, atualiza um ring buffer por canal e enfileira o mesmo frame para a thread de armazenamento. Limitar pontos no gráfico não descarta os dados brutos.

### Cena 20.5 — Visualização, conversão e filtros

**Imagem:** o mesmo trecho alternando entre raw, tensão, filtro e espectro.

**Fala:**

> A primeira aquisição deve permanecer raw e sem filtros. Depois podemos criar representações derivadas. A conversão ADS1256 usa VREF e PGA informados, com denominadores distintos para os extremos positivo e negativo. O conteúdo bruto do HDF5 não é substituído.

~~~python
full_scale = 2.0 * reference_voltage_v / gain
~~~

**Fala:**

> Os filtros IIR atuais usam ida e volta, por isso têm fase zero e são não causais. A janela visível é reprocessada a cada atualização. O espectro usa Hann e mostra amplitude unilateral, não densidade espectral de potência. O pico é o centro de um bin calculado com a taxa nominal da sessão.

**Fontes a mostrar:**

- `conversion_service.py`, linhas 128–143;
- `filter_pipeline.py`, linhas 24–257;
- `spectrum.py`, linhas 19–123.

### Cena 20.6 — Gravar HDF5

**Imagem:** iniciar gravação; mostrar `.partial.h5`; aguardar; finalizar; mostrar `.h5`.

**Fala:**

> A gravação cria primeiro um arquivo parcial. Uma fila limitada recebe os frames sem bloquear a GUI, e uma thread escreve lotes. Em encerramento normal, a thread de gravação drena o que já chegou à fila e o arquivo é renomeado atomicamente para `.h5`. A aplicação solicita a parada da QThread serial, mas não aguarda formalmente seu término antes de finalizar a gravação; essa corrida de shutdown permanece como limitação.

**Animação da estrutura:**

~~~text
/
└── frames
    ├── sequence_id   uint32  [N]
    ├── timestamp_us  uint64  [N]
    └── raw_values    float64 [N, 4]
~~~

**Fala:**

> Os datasets são extensíveis, usam chunks, shuffle e gzip nível um. O `uint64` do dataset de timestamp amplia o contêiner, mas não faz unwrapping nem recupera os bits que o firmware não transmitiu. O hash vigente protege os três datasets, não todos os metadados. Uma sessão estruturalmente consistente deve ter três comprimentos iguais, quatro colunas raw, sequência e timestamp crescentes e hash recalculado com sucesso.

**Gate de evidência:** o roteiro atual não contém um comando oficial que mostre simultaneamente dimensões e recálculo do hash. Antes da filmagem, adicionar ao repositório um verificador HDF5 somente leitura, versionado e testado, ou identificar e gravar a sequência exata da GUI que recalcula e exibe `verified`. Sem uma dessas evidências, mostrar apenas o que a aplicação realmente exibe e não alegar em vídeo que todas as dimensões e o hash foram comprovados visualmente.

### Cena 20.7 — Operar na Raspberry Pi

**Imagem:** Raspberry Pi 3 B+, tela HDMI/touch e captura direta da GUI.

**Fala:**

> Na Raspberry Pi, o caminho atual que será demonstrado é a execução manual em uma sessão gráfica. O script versionado usa XCB, tela cheia, atualização de 150 milissegundos e três mil pontos. Como ele não ativa o ambiente virtual e o repositório não contém um serviço systemd final, eu não vou apresentar esta versão como implantação autônoma ou completamente reproduzível.

**Ação:** executar o mesmo comando com `.venv/bin/python`, conectar a ACM, abrir uma sessão curta e localizar o arquivo gravado.

**Nota histórica opcional, até 20 segundos:**

> Em uma instalação Lite, a execução direta por `linuxfb` em `/dev/fb0` também foi confirmada durante o desenvolvimento. Como o procedimento final posterior não ficou integralmente registrado, o vídeo principal usa apenas o caminho que está sendo demonstrado agora.

### Cena 20.8 — Regra operacional do rollover

**Imagem:** contador de sessão se aproximando de 70 minutos; sinal de parada antes de 71:34.

**Fala:**

> O monitor exige timestamps estritamente crescentes e ainda não faz unwrapping do `uint32_t` enviado pela STM32. Quando o timestamp volta a zero, os frames seguintes são rejeitados até uma nova conexão. Nesta versão, limite sessões contínuas a menos de 71 minutos e reconecte antes do rollover.

## 21. Resultados e interpretação — 85:00 a 90:00

| Tempo interno | Cena |
|---:|---|
| 85:00–85:45 | hierarquia de evidências |
| 85:45–87:00 | ensaios documentados |
| 87:00–89:00 | nova fixture e ensaio de bancada |
| 89:00–90:00 | tratamento do material fisiológico |

### Cena 21.1 — Uma hierarquia de evidências

**Imagem:** quatro selos.

| Selo | Significado no vídeo |
|---|---|
| MEDIDO NESTA GRAVAÇÃO | obtido na unidade filmada, com arquivo da tomada preservado |
| MEDIDO EM CAPTURA VERSIONADA | resultado anterior com arquivo, commit e data identificados |
| IMPLEMENTADO | confirmado diretamente no código do commit |
| NOMINAL/ESTIMADO | derivado de configuração, datasheet ou modelo |
| NÃO CARACTERIZADO | falta medição ou documentação suficiente |

**Fala:**

> Para não misturar código, cálculo e medição, cada resultado recebe uma etiqueta. A captura serial de referência foi medida em uma captura versionada; a tomada nova recebe outro selo e outro arquivo. DRATE e ganho são implementados. VREF de 2,5 volts é nominal quando não foi medida naquela sessão. Diafonia e defasagem por canal permanecem não caracterizadas.

### Cena 21.2 — Ensaios funcionais documentados

**Imagem:** figuras do TCC em sequência, com o selo “resultado documentado — dados brutos não presentes no workspace”.

**Fala:**

> O texto atual registra senoides nominais de 100 e 450 hertz, quadradas de 5 e 50 hertz, um multitom e uma sinc periódica. As frequências medidas ficaram próximas dos estímulos nominais, e os espectros recuperaram componentes compatíveis. Entretanto, os dados brutos e scripts offline desses ensaios não estão neste workspace; por isso, estes números são resultados documentados, não reprocessados durante o vídeo.

**Tabela opcional por oito segundos:**

| Ensaio | Frequência documentada |
|---|---:|
| senoide 100 Hz | 99,99635 Hz |
| senoide 450 Hz | 449,98355 Hz |
| quadrada 5 Hz | 4,99995 Hz |
| quadrada 50 Hz | 49,99964 Hz |
| multitom base 50 Hz | 49,9981 Hz |
| sinc periódica 50 Hz | 49,9982 Hz |

### Cena 21.3 — O teste que deve ser regravado para o vídeo

**Imagem:** sistema desligado; frontends desconectados; esquema da fixture; medição entre terras; conexão de um par; alternância pelos canais configurados na GUI. Se forem usados quatro estímulos, mostrar a origem independente e a terminação de cada um.

**Fala:**

> Para produzir uma nova prova de bancada, primeiro eu desligo o sistema e desconecto AD8232, Pulse Sensor e qualquer outro circuito que possa dirigir os mesmos nós. A fixture identifica AINP, AINN, retorno, amplitude, offset, common-mode, impedância de saída, carga, limitação de corrente e o caminho de terra. Posso testar um par por vez, mantendo os demais terminados de forma documentada, ou usar quatro fontes independentes cujo circuito também esteja publicado. Só depois aplico um sinal periódico verificado dentro dos limites elétricos desta unidade.

**Critérios mínimos da tomada nova:**

- identificar instrumento e canal de saída;
- publicar o esquema da fixture e os pontos de injeção;
- registrar AINP, AINN, retorno, amplitude, offset, frequência, impedância, carga e common-mode;
- comprovar que nenhum frontend e gerador dirigem o mesmo nó;
- medir a diferença de potencial entre terras antes da conexão;
- registrar a limitação de corrente empregada;
- medir VREF e rails;
- preservar CSV/HDF5 bruto;
- registrar commit e hash do script;
- mostrar sequência e timestamps;
- repetir em pelo menos um canal e, preferencialmente, nos quatro.

### Cena 21.4 — Dados fisiológicos já existentes

**Imagem:** usar a figura multicanal somente se houver consentimento específico para divulgação pública, base institucional aplicável e verificação de anonimização/LGPD. Sem essa evidência, substituir por um diagrama ou sinal sintético e não exibir o dado humano.

**Fala:**

> O TCC documenta uma figura interpretada como ECG e PPG, mas os artefatos atuais não permitem reprocessar esse resultado. Ele não constitui validação clínica, calibração do potencial original no eletrodo ou medição de SpO₂. Sem autorização específica para divulgação pública, o vídeo deve mencionar apenas que existe um resultado acadêmico no texto, sem mostrar a figura nem qualquer dado do participante.

**Gate ético:** confirmar consentimento para publicação, aprovação ou enquadramento institucional, anonimização, finalidade, retenção, acesso e descarte conforme a LGPD. Na ausência de comprovação, omitir integralmente o material humano.

## 22. Limitações e encerramento — 90:00 a 95:00

| Tempo interno | Cena |
|---:|---|
| 90:00–92:30 | cinco cartões de limitações |
| 92:30–93:15 | síntese do que foi construído |
| 93:15–94:30 | três aprendizados |
| 94:30–95:00 | frase final e créditos |

### Cena 22.1 — Cinco cartões honestos

Cada cartão permanece por tempo suficiente para leitura e segue a estrutura “estado → impacto → regra atual → próximo passo”.

**Cartão 1 — entrada analógica**

~~~text
Estado: esquemático as-built incompleto
Impacto: frontend e segurança não são reproduzíveis integralmente
Regra: ensaio somente com bancada verificada
Próximo passo: esquema, proteção, filtros, rails e common-mode
~~~

**Cartão 2 — aquisição sequencial**

~~~text
Estado: quatro pares em um ADC multiplexado
Impacto: existe defasagem entre canais
Regra: não alegar simultaneidade
Próximo passo: medir offsets, settling e diafonia
~~~

**Cartão 3 — tempo e transporte**

~~~text
Estado: timestamp público uint32 em µs
Impacto: o monitor rejeita frames após o wrap até uma reconexão
Regra: sessões menores e reconexão preventiva
Próximo passo: uint64 ou unwrapping ponta a ponta
~~~

**Cartão 4 — integridade do transporte**

~~~text
Estado: USB observado sem corrupção na captura de 100 s
Impacto: sem CRC, ACK, fila explícita ou status propagado ao main
Regra: monitorar sequência e preservar a captura bruta
Próximo passo: formalizar buffers, fila, erros e integridade ponta a ponta
~~~

**Cartão 5 — uso pretendido**

~~~text
Estado: protótipo acadêmico
Impacto: não há validação clínica ou conformidade médica
Regra: não usar para diagnóstico nem conexão humana insegura
Próximo passo: segurança, ética, metrologia e protocolo
~~~

### Cena 22.2 — O que foi efetivamente construído

**Imagem:** repetir os melhores planos do cold open, agora em ordem causal.

**Fala:**

> O que temos ao final é um núcleo digital reproduzível: quatro pares diferenciais lidos sequencialmente, STM32 a 96 megahertz, ADS1256 controlado a 1,5 megahertz, frames com sequência e microssegundos, transporte USB, aplicação multicanal e gravação HDF5. A captura de referência sustenta aproximadamente mil frames por segundo durante cem segundos.

### Cena 22.3 — Três aprendizados

**Imagem:** apresentador; cada aprendizado recebe um insert correspondente.

**Fala:**

> Três ideias resumem esta trajetória. Primeiro: endereço de memória, vetor de interrupções e bootloader formam um único contrato. Segundo: respeitar e organizar o tempo do ADC vale mais do que simplesmente aumentar clocks. Terceiro: visualizar um sinal e preservar uma medição são tarefas diferentes; por isso, o dado bruto precisa ter um caminho próprio até o armazenamento.

### Cena 22.4 — Frase final

**Fala:**

> Este ainda não é um equipamento médico pronto. É uma plataforma acadêmica integrada, reproduzível no domínio digital e documentada o suficiente para sabermos com precisão o que já funciona, o que foi medido e o que ainda precisa ser demonstrado. Os commits, a pinagem, os comandos e a documentação completa estão na descrição.

**Imagem final:** sistema funcionando; congelar no frame do terminal e mostrar os três repositórios.

# Parte III — Material de apoio à gravação

## 23. Folha rápida de pinagem para imprimir

**Somente sinais digitais. Esta folha não inclui alimentação e não autoriza energização.** Usar junto da tabela específica de potência produzida para os PCBs filmados.

~~~text
ADS1256                              ST7735
CS    → PB12                         SCK   → PB3
DRDY  → PA8                          MOSI  → PB5
PDWN  → PA9                          CS    → PB4
SCLK  → PB13                         DC    → PB6
DOUT  → PB14                         RESET → PB7
DIN   → PB15

USB D− → PA11
USB D+ → PA12
LED    → PC13, ativo baixo
KEY    → PA0
~~~

## 24. Folha rápida de configuração

~~~text
STM32 core       96 MHz
USB              48 MHz, Full Speed CDC
alimentação      usar somente a tabela medida dos módulos filmados
SPI2 / ADS1256   modo 1, 1,5 MHz
SPI3 / ST7735    modo 0, 24 MHz
ADS DRATE        0xF0, 30 kSPS nominal
ADS PGA          1
ADS buffer       desabilitado
MUX              01, 23, 45, 67
frame            FRAME,seq,t_us,d1,d2,d3,d4
taxa observada   ≈1.000 frames/s
GUI              4 canais, 1.000 Hz, raw, filtros off
sessão atual     menor que 71 min 34,967 s
~~~

## 25. Lista de inserts de código

Não mostrar mais de 8 a 12 linhas por insert. Usar `arquivo:linhas @ commit` no rodapé.

| Assunto | Arquivo e intervalo |
|---|---|
| linker | `STM32F411CEUX_FLASH.ld:47–48` |
| VTOR | `Core/Src/main.c:194–203` |
| clocks | `Core/Src/main.c:152–190` |
| SPI2 | `Core/Src/spi.c:41–52` |
| SPI3 | `Core/Src/spi.c:73–84` |
| pares MUX | `Core/Inc/adc_ads1256.h:112–121` |
| inicialização ADC | `Core/Src/adc_ads1256.c:159–244` |
| conversão 24 bits | `Core/Src/adc_ads1256.c:333–350` |
| pipeline | `Core/Src/adc_ads1256.c:393–436` |
| timestamp | `Core/Src/microsecond_delay.c:6–44` |
| frame | `Core/Src/main.c:112–139` |
| USB bloqueante | `Core/Src/usb_cdc_serial.c:6–27` |
| parser | `serial_monitor/infrastructure/serial/protocol.py:14–103` |
| leitor | `serial_monitor/infrastructure/serial/serial_reader.py:19–208` |
| monitor | `serial_monitor/application/communication_monitor.py:12–221` |
| HDF5 | `serial_monitor/infrastructure/storage/hdf5_session_writer.py:22–339` |
| conversão | `serial_monitor/application/conversion_service.py:128–143` |
| filtros | `serial_monitor/processing/filter_pipeline.py:24–257` |
| FFT | `serial_monitor/processing/spectrum.py:19–123` |

## 26. Checklist de pré-produção

### Técnica

- [ ] commits fixados e worktrees limpos;
- [ ] BIN de referência preservado e hash conferido;
- [ ] bootloader HID funcionando;
- [ ] origem, versão e SHA-256 da CLI e do bootloader HID arquivados;
- [ ] dois cabos USB de dados testados;
- [ ] montagem etiquetada e fotografada antes de desmontar para a cena;
- [ ] pinagem impressa;
- [ ] tabela de alimentação específica dos PCBs preenchida e conferida;
- [ ] primeira energização preparada com limitação de corrente;
- [ ] rails e VREF medidos;
- [ ] esquema da fixture de bancada publicado;
- [ ] frontends desconectados dos nós dirigidos pela fixture;
- [ ] gerador configurado dentro dos limites elétricos medidos;
- [ ] AINP, AINN, retorno, offset, impedância, carga e common-mode conhecidos;
- [ ] diferença de potencial entre terras medida antes da conexão;
- [ ] validador testado por 100 s;
- [ ] aplicação testada com quatro canais;
- [ ] Python, sistema, arquitetura e `pip freeze` registrados;
- [ ] diretório de sessões com mais de 256 MiB livres;
- [ ] verificador HDF5 versionado ou sequência exata da GUI documentada;
- [ ] sessão HDF5 reserva inspecionada pelo verificador versionado ou pela sequência de GUI documentada;
- [ ] Raspberry Pi inicializando manualmente;
- [ ] nenhum voluntário previsto na bancada.

### Audiovisual

- [ ] câmera superior alinhada com a placa;
- [ ] câmera de apresentador com foco e exposição travados;
- [ ] lente macro ou capacidade de close nos silk-screens;
- [ ] captura de tela em 1440p ou superior;
- [ ] terminal com fonte mínima equivalente a 24 px no vídeo final;
- [ ] balanço de branco fixo;
- [ ] lapela ou boom testado;
- [ ] gravação de *room tone*;
- [ ] cartões, baterias e armazenamento redundantes;
- [ ] notificações, nomes pessoais e segredos ocultos;
- [ ] claquete ou identificação falada por cena;
- [ ] fotografia da bancada pronta para continuidade.

## 27. Ordem eficiente de gravação

Gravar por tipo de plano, não na ordem final do vídeo.

1. **Unidade funcionando:** cold open, tela, terminal, HDF5 e planos de segurança.
2. **Capturas de tela:** repositórios, código, build, inspeção, validador, GUI e Raspberry.
3. **Bancada desmontada:** componentes e macros.
4. **Montagem superior:** ADS1256, display e inspeção.
5. **Primeira energização encenada com a unidade já pré-validada:** medições, boot e serial.
6. **Ensaios de bancada:** níveis DC, sinal periódico, captura bruta e instrumentos.
7. **A-roll:** abertura, transições, advertências, aprendizados e conclusão.
8. **Pickups:** dedos nos botões, LEDs, cabos, conectores, teclado e planos lentos.

Guardar uma cópia dos arquivos produzidos ao final de cada bloco.

## 28. Checklist durante a tomada

- [ ] mostrar montagem sem energia antes de conectar qualquer cabo;
- [ ] conferir em voz alta PB12–PB15, PA8/PA9 e PB3–PB7;
- [ ] filmar o multímetro no ponto medido;
- [ ] marcar valores nominais como nominais;
- [ ] mostrar commit curto na captura de código;
- [ ] mostrar `.isr_vector` e hash do binário;
- [ ] enquadrar KEY/reset e VID:PID;
- [ ] preservar início e fim do validador de 100 s;
- [ ] dizer “sem saltos entre os IDs observados”;
- [ ] configurar quatro canais antes de conectar;
- [ ] usar raw e filtros desligados na primeira sessão;
- [ ] filmar `.partial.h5` tornando-se `.h5`;
- [ ] mostrar quatro colunas em `raw_values` por evidência versionada; sem verificador, remover essa alegação da tomada;
- [ ] encerrar qualquer sessão antes do rollover;
- [ ] não chamar PPG de SpO₂;
- [ ] não chamar os canais de simultâneos.

## 29. Checklist de edição técnica

- [ ] todos os números têm unidade;
- [ ] todos os valores estão marcados como medidos, implementados, nominais/estimados ou não caracterizados;
- [ ] `30 kSPS` nunca aparece como taxa por canal;
- [ ] `1.000 frames/s`, `1.000 amostras/s por par` e `4.000 valores/s` não são confundidos;
- [ ] os quatro pares são sempre chamados de sequenciais;
- [ ] nenhum offset temporal por canal é apresentado como medido;
- [ ] a faixa diferencial não é confundida com tensão permitida em cada pino;
- [ ] VREF só recebe o selo “medido” quando houver tomada do multímetro;
- [ ] 115200 é descrito como line coding virtual;
- [ ] o ensaio de 100 s não é generalizado para operação indefinida;
- [ ] o rollover de 71 min 34,967 s aparece antes de recomendar gravação;
- [ ] o `.ioc` divergente é mencionado antes de qualquer regeneração;
- [ ] resultados sem dados brutos aparecem como “documentados”;
- [ ] nenhuma fala sugere validação clínica;
- [ ] nenhum dado pessoal aparece em terminal, arquivo ou figura;
- [ ] links e commits da descrição foram testados.

## 30. Texto obrigatório de segurança

Usar na descrição e narrar uma versão curta no início:

> Este projeto é um protótipo acadêmico de instrumentação e não é dispositivo médico. O estado documentado não demonstra isolamento médico, limites de corrente de fuga, proteção contra desfibrilação, conformidade normativa, calibração clínica ou medição de SpO₂. Não conecte uma pessoa enquanto USB, HDMI, carregadores ou instrumentos aterrados formarem caminhos não analisados. Alimentação por bateria, sozinha, não prova isolamento do sistema completo. Estudos humanos exigem análise elétrica, protocolo institucional e ético, consentimento e regras de finalidade, anonimização, retenção, acesso e descarte dos dados conforme a LGPD.

## 31. Afirmações proibidas e substituições corretas

| Evitar | Usar |
|---|---|
| “quatro conversões simultâneas” | “quatro pares adquiridos sequencialmente e agrupados em um frame” |
| “30 kSPS por canal” | “DRATE 30 kSPS; aproximadamente 1 kSPS por par no sistema” |
| “zero perdas” | “zero saltos entre os IDs observados nesta captura” |
| “ADC com 24 bits efetivos” | “palavra de saída de 24 bits; ENOB da montagem ainda não medido” |
| “entrada aceita ±5 V” | “extremo diferencial ideal de ±2VREF/G, respeitando rails e common-mode” |
| “VREF é 2,5 V” | “VREF nominal de 2,5 V” ou o valor realmente medido |
| “timestamp do primeiro canal” | “marcador lido antes do readout do frame” |
| “USB a 115200 baud” | “USB Full Speed CDC com line coding 115200” |
| “a interface mede SpO₂” | “o preset não implementa cálculo de SpO₂” |
| “sistema validado clinicamente” | “protótipo com resultados funcionais documentados nos ensaios descritos” |
| “Raspberry autônoma” | “execução manual demonstrada na Raspberry” |
| “hash do arquivo completo” | “hash dos três datasets de frames” |

## 32. Capítulos para a descrição do YouTube

Recalcular os tempos depois do corte final.

~~~text
00:00 O sistema funcionando
01:20 Escopo e segurança
04:20 Arquitetura e taxas
08:20 História do desenvolvimento
15:30 Componentes e versões
20:00 Montagem do ADS1256 e do display
30:30 Memória, clocks e configuração do firmware
39:30 Pipeline de quatro pares
48:30 Timestamp e protocolo USB
54:00 Compilação e gravação na Black Pill
61:00 Validação de 100 segundos
67:00 Aplicação Python e quatro canais
78:00 Gravação e integridade HDF5
82:00 Raspberry Pi e limite de sessão
85:00 Resultados documentados
90:00 Limitações e próximos passos
~~~

## 33. Título, subtítulo e miniatura

### Título recomendado

> Construindo um sistema de aquisição com STM32, ADS1256 e Raspberry Pi

### Alternativa orientada ao conflito técnico

> Como chegamos a 1.000 frames/s com STM32 e ADS1256 — núcleo digital e validação

### Texto curto para miniatura

~~~text
4 PARES
1.000 FRAMES/s
DO ADC AO HDF5
~~~

Usar “pares” evita sugerir quatro conversores simultâneos antes que o espectador veja a explicação do MUX.

## 34. Modelo de descrição do vídeo

> Neste vídeo construímos e validamos o núcleo digital de um sistema acadêmico de aquisição baseado em STM32F411, ADS1256, ST7735, USB CDC, Raspberry Pi e Python. O ADS1256 percorre quatro pares diferenciais sequencialmente; o sistema observado entrega aproximadamente 1.000 frames/s, equivalentes a aproximadamente 1.000 amostras/s por par e 4.000 valores/s.
>
> Firmware demonstrado: commit `7fc7d6d724f3d762ea08447b26180b6c7ec7d27a`.
>
> Aplicação demonstrada: commit `d34b56bec961cbea028f5cc8573e845f4e215c63`.
>
> Documentação técnica e pinagem: inserir link para o repositório TCC no commit publicado com este roteiro.
>
> Aviso: protótipo acadêmico, não destinado a diagnóstico ou uso médico. Leia integralmente a seção de segurança antes de reproduzir.

Adicionar abaixo:

- links permanentes para os três commits;
- pinagem em texto;
- comandos copiáveis;
- lista de materiais com modelos efetivamente filmados;
- hashes dos artefatos;
- link para dados brutos e scripts do ensaio novo, se publicados;
- errata versionada;
- licença de código, documentação, imagens e música.

## 35. Gate final antes de publicar

O vídeo só está tecnicamente pronto quando todas as respostas forem “sim”:

1. A unidade filmada foi a unidade medida?
2. Os commits mostrados são os commits usados para compilar e executar?
3. O hash do BIN exibido corresponde ao arquivo gravado?
4. Origem, versão e hash da CLI e do bootloader foram publicados?
5. A pinagem de sinais mostrada coincide com o código vigente?
6. A tabela de alimentação corresponde aos PCBs realmente filmados?
7. A primeira energização foi feita com limitação de corrente?
8. A fixture de bancada possui esquema, retorno e terras documentados?
9. Nenhum frontend e gerador dirigiram o mesmo nó?
10. VREF, rails, amplitude, offset, impedância, carga e common-mode foram medidos?
11. A captura de 100 s foi preservada sem cortes ou alterações?
12. Todos os números exibidos podem ser rastreados a código, captura ou cálculo mostrado?
13. Resultados antigos sem dados brutos foram identificados como documentais?
14. A aquisição foi chamada de sequencial em toda a edição?
15. O vídeo evita qualquer instrução de conexão humana insegura?
16. Qualquer material humano possui autorização específica e verificação LGPD, ou foi omitido?
17. O limite de 71 minutos foi informado antes da operação?
18. Existe evidência versionada de quatro colunas e do hash recalculado, ou essas alegações foram removidas do vídeo?
19. Nomes pessoais, credenciais e dados sensíveis foram removidos?
20. Os links da descrição abrem exatamente as versões demonstradas?
21. Um segundo revisor técnico assistiu ao corte completo e conferiu números, unidades e alegações?

---

**Fim do roteiro.** A fala pode ser adaptada ao estilo do apresentador, mas números, limitações, sequência de montagem e critérios de evidência não devem ser simplificados de modo a alterar o significado técnico.
