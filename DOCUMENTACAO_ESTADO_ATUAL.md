# Documentação técnica do estado atual do sistema

## STM32F411, ADS1256, ST7735, USB CDC, Raspberry Pi e aplicação Python

**Data de corte:** 14 de julho de 2026

**Escopo:** somente a implementação e a montagem vigentes nos commits fixados abaixo

**Finalidade:** operação, reprodução, manutenção e consulta técnica do sistema atual

---

## 1. Controle de configuração

Esta documentação descreve exatamente os seguintes estados:

| Subsistema | Repositório | Commit imutável |
|---|---|---|
| Firmware STM32 | [Tyrion1606/blackpill_ads1256-display](https://github.com/Tyrion1606/blackpill_ads1256-display) | [`7fc7d6d724f3d762ea08447b26180b6c7ec7d27a`](https://github.com/Tyrion1606/blackpill_ads1256-display/tree/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a) |
| Aplicação PC/Raspberry | [AlexAndrei3663/processamento_biomedico](https://github.com/AlexAndrei3663/processamento_biomedico) | [`d34b56bec961cbea028f5cc8573e845f4e215c63`](https://github.com/AlexAndrei3663/processamento_biomedico/tree/d34b56bec961cbea028f5cc8573e845f4e215c63) |
| Fonte acadêmica e dossiê auditados | [Tyrion1606/TCC](https://github.com/Tyrion1606/TCC) | `c59615999cd2828c131dbfcb90de34a11dcbb0ca` |

Artefatos do firmware atual:

| Artefato | SHA-256 |
|---|---|
| `Debug/blackpill_ads1256+display.bin` | `f7334208b5126c9154046320ddf6dbfae54d35ca2d6065788b25f7c6ca834a0f` |
| `Debug/blackpill_ads1256+display.elf` | `395d8c6310eb8aa2a59c90f1acd6f0b60156129f2986c85481aef5c2d4bcd90b` |
| `captura_serial.csv` | `7ff5345e2a67fa8f2ce1af0cae6318e1f1b634bc392aead25e21e0351a5647b9` |
| `grava_serial_csv.py` | `f631fed79bbb39fb4db2e1e4ea7dcd837d6aeeb4f7b46655e8973802e48b73d4` |

Quando uma configuração do `.ioc`, um comentário ou uma tela divergir do código executável, esta documentação usa como verdade operacional os fontes compilados do commit fixado e registra a divergência na seção de limitações atuais.

## 2. Visão geral

O sistema recebe sinais analógicos já condicionados, converte quatro pares diferenciais por meio de um ADS1256, agrupa as quatro leituras em um frame e envia texto CSV por USB CDC. Um display ST7735 mostra o estado de inicialização. Um computador ou Raspberry Pi executa a aplicação Python para visualizar, processar e armazenar os frames.

~~~mermaid
flowchart LR
    ECG1[Frontend ECG 1] --> P01[AIN0 menos AIN1]
    ECG2[Frontend ECG 2] --> P23[AIN2 menos AIN3]
    PPG[Frontend PPG] --> P45[AIN4 menos AIN5]
    AUX[Canal auxiliar] --> P67[AIN6 menos AIN7]
    P01 --> ADC[ADS1256]
    P23 --> ADC
    P45 --> ADC
    P67 --> ADC
    ADC -->|SPI2 modo 1, 1,5 MHz| MCU[STM32F411CEU6, 96 MHz]
    MCU -->|SPI3 modo 0, 24 MHz| TFT[ST7735 128 por 160]
    MCU -->|USB Full Speed CDC| HOST[PC ou Raspberry Pi]
    HOST --> READER[SerialReader e parser]
    READER --> LIVE[Buffers e visualização]
    READER --> H5[Gravação HDF5]
    LIVE --> DSP[Conversão, filtros e FFT]
~~~

> Os quatro valores de um frame são sequenciais. O ADS1256 não realiza quatro conversões fisicamente simultâneas.

## 3. Vocabulário operacional

| Termo | Significado atual |
|---|---|
| DRATE | taxa nominal de saída do filtro digital do ADS1256, configurada em 30 kSPS |
| leitura útil | um resultado de um par diferencial depois da troca do MUX |
| frame | sequência, timestamp e quatro leituras diferenciais |
| taxa de frame | aproximadamente 1.000 frames/s |
| taxa por par | aproximadamente 1.000 amostras/s para cada par |
| valores transmitidos | aproximadamente 4.000 resultados de ADC/s |
| timestamp | marcador em microssegundos lido antes do readout do frame |
| sequência | contador `uint32_t` incrementado uma vez por iteração |

Com quatro pares:

\[
f_{\mathrm{valores}} = 4f_{\mathrm{frame}},
\qquad
f_{\mathrm{canal}} = f_{\mathrm{frame}}.
\]

O código `0xF0` do DRATE seleciona 30 kSPS para a saída do filtro digital. Com `fCLKIN = 7,68 MHz`, o modulador opera aproximadamente em `fCLKIN/4 = 1,92 MHz`. Nenhuma dessas duas grandezas é a taxa útil de cada par depois do cycling do MUX.

# Parte I — Montagem e hardware

## 4. Componentes funcionais

| Componente | Função |
|---|---|
| WeAct Black Pill STM32F411CEU6 | controle, temporização, SPI e USB CDC |
| módulo ADS1256 | ADC delta-sigma de 24 bits e MUX analógico |
| ST7735S de 1,8 polegada | diagnóstico local de inicialização |
| dois módulos AD8232 | condicionamento dos canais denominados ECG 1 e ECG 2 |
| Pulse Sensor Amped | frontend do canal denominado PPG |
| canal auxiliar | entrada AIN6−AIN7; função física final ainda precisa ser confirmada |
| Raspberry Pi 3 Model B+ ou computador | interface, processamento e armazenamento |
| tela HDMI/touch de 7 polegadas | interface principal quando usada com a Raspberry Pi |

Fotografias existentes da montagem:

![Núcleo STM32, ADS1256 e TFT](figuras/montagem_ads1256_stm32_tft.png)

![Raspberry Pi e interface](figuras/montagem_raspberry_interface.jpg)

## 5. Pinagem digital vigente

### 5.1 ADS1256 para STM32

| Sinal | STM32 | Direção vista da STM32 | Configuração |
|---|---:|---|---|
| CS | PB12 | saída | GPIO, ativo baixo |
| DRDY | PA8 | entrada | pull-up, ativo baixo |
| PDWN | PA9 | saída | mantido alto em operação |
| SCLK | PB13 | saída | SPI2 AF5 |
| DOUT | PB14 | entrada | SPI2 MISO AF5 |
| DIN | PB15 | saída | SPI2 MOSI AF5 |

Fontes: [`main.h:60–73`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/main.h#L60-L73), [`gpio.c:72–90`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/gpio.c#L72-L90) e [`spi.c:109–118`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/spi.c#L109-L118).

### 5.2 ST7735 para STM32

| Sinal do display | STM32 | Configuração |
|---|---:|---|
| SCK | PB3 | SPI3 AF6 |
| SDA/MOSI | PB5 | SPI3 AF6 |
| CS | PB4 | GPIO |
| DC/A0 | PB6 | GPIO |
| RESET | PB7 | GPIO |
| MISO | não usado | SPI somente de escrita |

Fontes: [`main.h:68–73`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/main.h#L68-L73), [`spi.c:133–142`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/spi.c#L133-L142) e [`display_st7735.h:8–24`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/display_st7735.h#L8-L24).

### 5.3 Outros sinais

| Função | Pino |
|---|---:|
| LED onboard, ativo baixo | PC13 |
| USB D− | PA11 |
| USB D+ | PA12 |
| cristal HSE de 25 MHz | PH0/PH1 |
| KEY do bootloader WeAct | PA0 |

USB: [`usbd_conf.c:78–95`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/USB_DEVICE/Target/usbd_conf.c#L78-L95). LED: [`application_config.h:17–23`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/application_config.h#L17-L23).

## 6. Mapeamento analógico lógico

O firmware fixa quatro pares:

| Campo do frame | Código MUX | Par diferencial | Uso atual nos arquivos de ensaio |
|---|---:|---|---|
| `d1` | `0x01` | AIN0−AIN1 | ECG 1 |
| `d2` | `0x23` | AIN2−AIN3 | ECG 2 |
| `d3` | `0x45` | AIN4−AIN5 | PPG |
| `d4` | `0x67` | AIN6−AIN7 | auxiliar; também denominado temperatura em uma sessão |

Trecho pontual do firmware:

~~~c
#define ADC_ADS1256_CHANNEL_AIN0_AGAINST_AIN1 0x01U
#define ADC_ADS1256_CHANNEL_AIN2_AGAINST_AIN3 0x23U
#define ADC_ADS1256_CHANNEL_AIN4_AGAINST_AIN5 0x45U
#define ADC_ADS1256_CHANNEL_AIN6_AGAINST_AIN7 0x67U
~~~

Fonte: [`Core/Inc/adc_ads1256.h:112–121`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/adc_ads1256.h#L112-L121). A tabela efetivamente percorrida está em [`adc_ads1256.c:26–31`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L26-L31).

O repositório não determina qual referência física está ligada a cada terminal negativo, nem registra integralmente filtros, proteção, atenuação e common-mode da montagem. Portanto, esses detalhes não devem ser inferidos apenas do código MUX.

## 7. Faixa e conversão elétrica

Definindo:

- `VREF`: VREFP−VREFN;
- `G`: ganho do PGA;
- `c`: código assinado de 24 bits;

a magnitude de cada extremo diferencial ideal é:

\[
V_{\mathrm{FS}}=\frac{2V_{\mathrm{REF}}}{G}.
\]

O span total é `4VREF/G`. Para VREF nominal de 2,5 V e ganho 1:

| Código | Tensão diferencial ideal |
|---:|---:|
| −8.388.608 | −5 V |
| 0 | 0 V |
| +8.388.607 | aproximadamente +5 V |

\[
V(c)=
\begin{cases}
c\dfrac{2V_{\mathrm{REF}}/G}{8.388.607}, & c\ge0,\\[6pt]
c\dfrac{2V_{\mathrm{REF}}/G}{8.388.608}, & c<0.
\end{cases}
\]

A faixa diferencial não permite colocar arbitrariamente −5 V em um pino físico. AINP e AINN precisam permanecer dentro dos limites absolutos e de common-mode definidos por AVDD e AGND.

O buffer interno do ADS1256 permanece desabilitado, pois STATUS.BUFEN não é escrito. A entrada continua apresentando impedância dinâmica finita; a impedância de saída do frontend e o settling depois da troca do MUX devem ser considerados.

## 8. Alimentação documentada

O conjunto atualmente descrito usa:

- Black Pill alimentada por USB-C em 5 V;
- lógica STM32 e módulos AD8232 em 3,3 V;
- Pulse Sensor Amped descrito em 5 V;
- terras dos módulos interligados;
- Raspberry Pi alimentada separadamente, inclusive por bateria em parte das montagens;
- HDMI e USB para tela/touch quando aplicáveis.

Antes de reproduzir a montagem, medir e registrar:

1. 5 V e 3,3 V sob carga;
2. AVDD−AGND e DVDD−DGND no módulo ADS1256;
3. AGND−DGND;
4. VREFP−VREFN;
5. common-mode e extremos de AINP/AINN de cada canal;
6. caminho de terra até USB, HDMI, carregadores e instrumentos.

O ADS1256 não possui pino chamado AVSS. Eventual alimentação analógica negativa criada pelo módulo deve ser identificada conforme o esquema específico da placa.

# Parte II — Firmware atual

## 9. Mapa de memória e boot

O firmware é construído para coexistir com o WeAct HID Bootloader nos primeiros 16 KiB da Flash:

~~~text
0x08000000 ┌──────────────────────────────────────┐
           │ área reservada ao bootloader, 16 KiB│
0x08004000 ├──────────────────────────────────────┤
           │ aplicação, até 496 KiB              │
0x08080000 └──────────────────────────────────────┘

0x20000000 ┌──────────────────────────────────────┐
           │ SRAM, 128 KiB                       │
0x20020000 └──────────────────────────────────────┘
~~~

O linker define RAM e Flash em [`STM32F411CEUX_FLASH.ld:47–48`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/STM32F411CEUX_FLASH.ld#L47-L48). A constante da aplicação está em [`application_config.h:7–14`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/application_config.h#L7-L14), e o VTOR é atribuído com barreiras em [`main.c:194–203`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L194-L203).

O ELF atual possui:

| Item | Valor |
|---|---:|
| `.isr_vector` | `0x08004000` |
| início de `.text` | `0x080041A0` |
| stack pointer inicial | `0x20020000`, topo válido para pilha descendente |
| vetor de reset armazenado | `0x080058DD`, bit Thumb ativo |
| `Reset_Handler` alinhado | `0x080058DC` |
| text | 38.916 bytes |
| data | 332 bytes |
| bss | 9.240 bytes |
| BIN | 39.256 bytes |

## 10. Árvore de clocks

Configuração RCC: [`main.c:152–190`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L152-L190).

~~~text
HSE = 25 MHz
PLLM = 25       → entrada do VCO = 1 MHz
PLLN = 192      → saída do VCO = 192 MHz
PLLP = 2        → SYSCLK = 96 MHz
PLLQ = 4        → USB = 48 MHz

AHB  /1         → HCLK/Core = 96 MHz
APB1 /2         → PCLK1 = 48 MHz
APB2 /1         → PCLK2 = 96 MHz
~~~

O DWT e os atrasos em microssegundos usam `SystemCoreClock = 96 MHz`. DRDY é governado pelo clock próprio do ADS1256, não pelo HSE da STM32.

## 11. Barramentos SPI

| Barramento | Destino | Modo | Clock | Fonte |
|---|---|---:|---:|---|
| SPI2 | ADS1256 | CPOL 0, CPHA segunda borda, modo 1 | 48 MHz/32 = 1,5 MHz | [`spi.c:41–52`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/spi.c#L41-L52) |
| SPI3 | ST7735 | CPOL 0, CPHA primeira borda, modo 0 | 48 MHz/2 = 24 MHz | [`spi.c:73–84`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/spi.c#L73-L84) |

Ambos usam 8 bits, MSB primeiro, NSS por software e operações HAL em polling.

## 12. Configuração do ADS1256

| Item | Valor atual | Referência |
|---|---:|---|
| DRATE | `0xF0`, 30 kSPS nominais | [`adc_ads1256.h:44–60`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/adc_ads1256.h#L44-L60) |
| PGA | código `0x00`, ganho 1 | [`adc_ads1256.h:92–100`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/adc_ads1256.h#L92-L100) |
| STATUS | não escrito | buffer permanece no default desabilitado |
| ADCON | `0x00` | CLKOUT off, sensor detect off, PGA 1 |
| MUX inicial | `0x01` | AIN0−AIN1 |
| modo de dados | RDATA sob comando | RDATAC não é usado |
| calibração | SELFCAL na inicialização | espera DRDY com timeout |

Temporizações locais em [`adc_ads1256.c:9–11`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L9-L11):

| Intervalo | Valor |
|---|---:|
| depois de comando | 4 µs |
| depois de WREG | 2 µs |
| RDATA até clocks de dados | 7 µs |

### 12.1 Inicialização

A implementação completa está em [`adc_ads1256.c:159–244`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L159-L244). Ordem operacional:

1. liberar CS e manter PDWN alto;
2. esperar 50 ms;
3. enviar RESET;
4. esperar 5 ms e DRDY baixo, com timeout de 1 s;
5. enviar SDATAC;
6. escrever MUX `0x01`;
7. escrever ADCON com ganho 1;
8. escrever DRATE `0xF0`;
9. executar SELFCAL;
10. esperar DRDY baixo, com timeout de 1 s;
11. reler MUX e comparar com `0x01`;
12. desenhar o estado no display.

Somente MUX é relido. STATUS, ADCON e DRATE não possuem readback no estado atual.

### 12.2 Conversão de 24 bits

Os três bytes são concatenados e o bit 23 é estendido para `int32_t`. Implementação: [`adc_ads1256.c:333–350`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L333-L350).

Faixa digital:

~~~text
−8.388.608 ... 0 ... +8.388.607
~~~

## 13. Pipeline de multiplexação

O pipeline vigente está em [`adc_ads1256.c:393–436`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L393-L436).

Para cada resultado:

~~~text
aguardar DRDY da conversão atual
programar MUX do próximo par
enviar SYNC
enviar WAKEUP
enviar RDATA e ler a conversão concluída
armazenar no índice do par atual
~~~

Diagrama de um frame em regime:

~~~text
DRDY d1 ↓  → MUX d2 → SYNC → WAKEUP → RDATA d1
DRDY d2 ↓  → MUX d3 → SYNC → WAKEUP → RDATA d2
DRDY d3 ↓  → MUX d4 → SYNC → WAKEUP → RDATA d3
DRDY d4 ↓  → MUX d1 → SYNC → WAKEUP → RDATA d4
                                           frame completo
~~~

Ao final, a conversão de `d1` do frame seguinte já está iniciada. A função mantém `isPipelineInitialized` e `readyChannelIndex` como estado estático.

A espera normal de DRDY em [`adc_ads1256.c:150–157`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L150-L157) não possui timeout e verifica nível baixo, não uma transição alto→baixo.

## 14. Taxas do firmware

O header contém:

- 4.374 leituras/s para a condição tabelada de cycling;
- estimativa de 4.181,94 leituras/s para SPI em 1,5 MHz;
- quatro pares por frame.

Fontes: [`adc_ads1256.h:54–60`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/adc_ads1256.h#L54-L60) e cálculo de display em [`adc_ads1256.c:254–274`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L254-L274).

O sistema completo mede aproximadamente:

~~~text
1.000 frames/s
4 valores/frame
≈ 1.000 amostras/s por par
≈ 4.000 valores/s
~~~

## 15. Timestamp DWT

Implementação: [`microsecond_delay.c:6–44`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/microsecond_delay.c#L6-L44).

1. `DWT->CYCCNT` é habilitado e zerado;
2. esperas curtas comparam a diferença modular de ciclos;
3. quando o contador atual fica menor que o anterior, uma palavra alta de 64 bits é incrementada;
4. ciclos estendidos são divididos por `SystemCoreClock/1.000.000`;
5. o retorno público é convertido para `uint32_t`.

Limites:

| Contador | Wrap |
|---|---:|
| CYCCNT cru a 96 MHz | 44,7392427 s |
| timestamp transmitido `uint32_t` em µs | 4.294,967296 s = 71 min 34,967 s |

O timestamp é obtido em [`main.c:113–116`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L113-L116), imediatamente antes da chamada de readout. Ele não representa o instante exato de nenhuma das quatro conversões.

## 16. Frame e protocolo USB

Formato exato:

~~~text
FRAME,<sequence_id>,<timestamp_us>,<d1>,<d2>,<d3>,<d4>\r\n
~~~

Trecho pontual:

~~~c
"FRAME,%lu,%lu,%ld,%ld,%ld,%ld\r\n"
~~~

Fonte: [`main.c:112–139`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L112-L139).

Propriedades:

- `sequence_id`: `uint32_t`, começa em zero a cada reset;
- `timestamp_us`: `uint32_t` no firmware atual;
- `d1..d4`: inteiros assinados depois da extensão de 24 bits;
- buffer local: 128 bytes;
- terminador: CRLF;
- uma linha é submetida por frame;
- linhas de inicialização normalmente começam com `#`.

A linha dinâmica `MUX do ADS1256 lido: ...`, em [`adc_ads1256.c:208–217`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L208-L217), não começa com `#`.

## 17. USB CDC

O USB é Full Speed com PHY interno. A inicialização ocorre antes de uma espera fixa de 2 s para enumeração: [`main.c:81–95`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L81-L95).

| Item | Estado atual |
|---|---|
| classe | CDC ACM |
| tamanho máximo de pacote FS | 64 bytes |
| buffer RX da interface | 2.048 bytes |
| buffer TX da interface | 2.048 bytes |
| DMA | desabilitado |
| VBUS sensing | desabilitado |
| confirmação por frame | inexistente |

O wrapper em [`usb_cdc_serial.c:6–27`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/usb_cdc_serial.c#L6-L27) repete enquanto recebe `USBD_BUSY` e encerra após aproximadamente 1 s. Não retorna status ao chamador.

`115200` é o line coding configurado pelo host; o transporte físico continua sendo USB Full Speed.

## 18. Display e indicação local

O ST7735 usa 128×160 pixels, RGB565 e fonte 5×7. Inicialização: [`display_st7735.c:107–152`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/display_st7735.c#L107-L152).

A tela de status é montada uma vez durante a inicialização do ADS1256 em [`adc_ads1256.c:246–320`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L246-L320). Ela mostra:

- ADS1256 inicializado;
- pares 01, 23, 45 e 67;
- DRATE e ganho;
- estimativas de leituras e frames;
- indicação `Validado: ~1Ksps`;
- legenda resumida do CSV.

O display não é redesenhado no laço contínuo e não plota formas de onda.

## 19. LED e tratamento de erro

PC13 é alternado depois da submissão de cada linha USB. Por ser ativo baixo, o significado visual depende do estado anterior e da frequência de toggle.

`Error_Handler` está em [`application_error.c:5–22`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/application_error.c#L5-L22). Ele desabilita interrupções e chama uma rotina baseada em `HAL_Delay(80)`. Como o SysTick deixa de avançar, o comportamento efetivo provável é LED aceso continuamente no primeiro estado, não piscando.

## 20. Captura de referência do estado atual

O arquivo `captura_serial.csv` contém cabeçalho mais 100.005 frames.

| Métrica | Resultado |
|---|---:|
| tamanho | 7.861.649 bytes |
| sequência observada | 15–100.019 |
| gaps no intervalo observado | 0 |
| duplicatas/reordenações | 0/0 |
| duração pelo PC | 99,998427 s |
| taxa pelo PC | 1.000,055731 frames/s |
| duração pelo MCU | 100,001732 s |
| taxa pelo MCU | 1.000,022680 frames/s |
| valores equivalentes | 4.000,090718/s |
| intervalo mínimo | 997 µs |
| mediana | 1.000 µs |
| média | 999,977321 µs |
| máximo | 1.481 µs |

Os IDs 0–14 não fazem parte do arquivo. A captura comprova continuidade apenas entre 15 e 100.019.

O período de 20,341099 s a 120,342831 s atravessa dois wraps do CYCCNT cru e comprova que a extensão interna funcionou nesses eventos. Não alcança o wrap público de 71,6 minutos.

O validador está em [`grava_serial_csv.py`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/grava_serial_csv.py). Configuração e fórmula: [`linhas 9–38`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/grava_serial_csv.py#L9-L38); parser: [`linhas 191–234`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/grava_serial_csv.py#L191-L234).

### 20.1 Resultados funcionais registrados no TCC atual

Além da captura serial versionada, o texto atual registra os seguintes ensaios:

| Estímulo/sessão | Frequência medida | Amplitude ou resultado principal |
|---|---:|---:|
| senoide nominal de 100 Hz | 99,99635 Hz | 2,0588 Vpp observados |
| senoide nominal de 450 Hz | 449,98355 Hz | 2,0375 Vpp observados |
| quadrada nominal de 5 Hz | 4,99995 Hz | 5,1022 V entre patamares |
| quadrada nominal de 50 Hz | 49,99964 Hz | 5,0337 V entre patamares |
| multitom de base 50 Hz | 49,9981 Hz | 5,0847 Vpp |
| sinc periódica de 50 Hz | 49,9982 Hz | 5,0688 Vpp |
| fisiológica | 29.750 frames em 29,7495 s | 999,983 frames/s, 47 eventos por sinal |

Fontes no TCC: [senoides, linhas 1634–1638](https://github.com/Tyrion1606/TCC/blob/c59615999cd2828c131dbfcb90de34a11dcbb0ca/fcte_template.tex#L1634-L1638), [quadradas, linhas 1865–1867](https://github.com/Tyrion1606/TCC/blob/c59615999cd2828c131dbfcb90de34a11dcbb0ca/fcte_template.tex#L1865-L1867), [multitom, linhas 2125–2127](https://github.com/Tyrion1606/TCC/blob/c59615999cd2828c131dbfcb90de34a11dcbb0ca/fcte_template.tex#L2125-L2127), [sinc, linhas 2258–2260](https://github.com/Tyrion1606/TCC/blob/c59615999cd2828c131dbfcb90de34a11dcbb0ca/fcte_template.tex#L2258-L2260) e [sessão fisiológica, linha 2698](https://github.com/Tyrion1606/TCC/blob/c59615999cd2828c131dbfcb90de34a11dcbb0ca/fcte_template.tex#L2698).

As tensões foram calculadas com VREF nominal de 2,5 V e ganho 1. Os dados brutos e scripts offline desses ensaios não estão presentes no workspace auditado; portanto, os valores representam resultados documentados, mas não podem ser recalculados integralmente apenas com os repositórios atuais.

# Parte III — Aplicação Python atual

## 21. Identificação

| Item | Estado atual |
|---|---|
| versão | `0.1.0` |
| protocolo declarado | `frame_csv_single_sequence_v1` |
| Python declarado | 3.10 ou posterior |
| interface | PyQt5 e PyQtGraph |
| serial | PySerial |
| processamento | NumPy e SciPy |
| armazenamento | HDF5 por h5py |
| lockfile | inexistente |
| versões das dependências | não fixadas em `requirements.txt` |

Versão e protocolo: [`serial_monitor/__init__.py:3–5`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/__init__.py#L3-L5). Dependências: [`requirements.txt:1–7`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/requirements.txt#L1-L7).

## 22. Arquitetura de execução

~~~text
USB CDC / linha textual
        │
        ▼
SerialReader, QThread
  ├─ readline com timeout de 100 ms
  ├─ UTF-8, errors=ignore
  ├─ descarta vazio e linhas iniciadas por #
  ├─ FrameCsvParser
  └─ frames_received em lotes
        │ sinal Qt
        ▼
MainController, thread da GUI
  ├─ CommunicationMonitor
  ├─ LiveAcquisitionService
  │    └─ um RingBuffer por canal
  └─ RecordingService.enqueue_frame
        │ queue.Queue limitada
        ▼
thread SessionWriter
  └─ Hdf5SessionWriter incremental
~~~

O controlador conecta o sinal em lote em [`bootstrap.py:131–134`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/app/bootstrap.py#L131-L134) e percorre os frames em [`bootstrap.py:777–845`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/app/bootstrap.py#L777-L845).

## 23. Contrato do parser

Formato aceito:

~~~text
FRAME,<sequence_id>,<timestamp_us>,<v0>,...,<vN>
~~~

Implementação: [`protocol.py:14–103`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/serial/protocol.py#L14-L103).

Regras:

- linha vazia ou cujo primeiro caractere útil seja `#` é descartada pelo leitor;
- o parser exige exatamente `3 + quantidade_de_canais` campos;
- `FRAME` não diferencia maiúsculas de minúsculas;
- `sequence_id` deve caber em uint32;
- `timestamp_us` deve caber em uint64;
- valores são convertidos para `float`;
- NaN e infinito são rejeitados;
- a associação aos canais é posicional;
- não há CRC;
- não há validação de que os valores sejam inteiros de 24 bits.

O parser aceita uint64 para o timestamp, mas o firmware atual envia apenas uint32.

## 24. Leitura serial e batching

Implementação: [`serial_reader.py:19–208`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/serial/serial_reader.py#L19-L208).

| Parâmetro | Valor |
|---|---:|
| timeout de `readline()` | 0,1 s |
| lote | 20 frames |
| latência nominal para lote incompleto | 20 ms |
| agregação de erros | 1 s |
| carência para detectar protocolo incompatível | 2 s |
| limite sem nenhum frame válido | 100 linhas inválidas |

Cada frame válido:

1. é acrescentado ao lote;
2. dispara também o sinal legado `frame_received`;
3. é entregue ao controlador somente pelo sinal conectado `frames_received`.

O sinal unitário não está conectado, portanto não duplica o processamento atual. Um lote sai ao chegar a 20 frames ou quando a condição de 20 ms é verificada. Como `readline()` pode bloquear 100 ms, 20 ms não é um limite rígido para fluxo esparso. O lote residual é emitido no bloco `finally`.

## 25. Monitor de comunicação

O monitor está em [`communication_monitor.py:12–221`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/communication_monitor.py#L12-L221).

A distância de sequência é modular:

\[
d=(s_{\mathrm{atual}}-s_{\mathrm{anterior}})\bmod 2^{32}.
\]

| Condição | Classificação | Aceitação |
|---|---|---|
| primeiro frame | FIRST | sim |
| `d = 1` | IN_ORDER | sim |
| `1 < d < 2^31` | GAP | sim, contabiliza `d−1` |
| `d = 0` | DUPLICATE | não |
| `d ≥ 2^31` | OUT_OF_ORDER | não |

O timestamp precisa ser estritamente crescente. Uma regressão rejeita o frame. Ao abrir uma nova conexão, sequência e timestamp seguintes tornam-se nova baseline sem apagar diagnósticos acumulados.

### 25.1 Comportamento no wrap atual do firmware

Quando o timestamp de 32 bits volta a zero depois de 71,6 minutos:

1. o monitor considera o primeiro valor baixo regressivo;
2. preserva o timestamp alto anterior;
3. rejeita também todos os valores baixos seguintes;
4. buffers e HDF5 deixam de receber frames até uma nova baseline de conexão.

## 26. Distribuição e buffers ao vivo

`LiveAcquisitionService` cria um buffer por canal, valida quantidade e presença de valores e insere apenas frames aceitos: [`live_acquisition_service.py:31–124`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/live_acquisition_service.py#L31-L124).

Cada `RingBuffer` armazena:

| Campo | dtype |
|---|---|
| valor | float64 |
| timestamp | uint64 |
| sequência | uint32 |

Implementação: [`ring_buffer.py:8–105`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/ring_buffer.py#L8-L105).

O eixo é:

\[
x_{\mathrm{s}} =
\frac{t_{\mu s}-t_{\mathrm{origem},\mu s}}{10^6}.
\]

A origem permanece fixa desde a última limpeza. Quando o buffer circular sobrescreve dados antigos, o gráfico continua avançando e não retorna a zero.

## 27. Configuração inicial da interface

Configuração de fábrica, sem preset salvo:

| Item | Valor |
|---|---:|
| baudrate virtual | 115200 |
| taxa base | 1.000 Hz |
| janela | 1.000 amostras |
| canais | ECG, PPG, Oximetria |
| VREF | 2,5 V |
| PGA | 1 |
| modo de conversão | raw |

Fonte: [`config_page.py:37–60`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/ui/pages/config_page.py#L37-L60) e [`config_page.py:126–158`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/ui/pages/config_page.py#L126-L158).

O firmware envia quatro valores. Para operar com o hardware atual, configurar explicitamente:

| Índice | Tipo/nome recomendado | Par |
|---:|---|---|
| 0 | ECG 1 | AIN0−AIN1 |
| 1 | ECG 2 | AIN2−AIN3 |
| 2 | PPG | AIN4−AIN5 |
| 3 | Outro ou Auxiliar | AIN6−AIN7 |

Sem quatro canais, o parser espera seis campos totais em vez de sete e rejeita todas as linhas do firmware.

A taxa base da GUI não configura o ADS1256. Ela é metadado da sessão e parâmetro de filtros/FFT.

## 28. Argumentos de execução

Definições e validações: [`runtime_settings.py:9–123`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/app/runtime_settings.py#L9-L123).

| Argumento | Padrão | Faixa permitida |
|---|---:|---:|
| `--fullscreen` | falso | booleano |
| `--update-interval-ms` | 100 | 50–2.000 |
| `--max-plot-points` | 5.000 | 100–100.000 |
| `--data-dir` | `data` | caminho |
| `--recording-queue-capacity` | 8.192 | 128–1.000.000 |
| `--recording-batch-size` | 256 | 1–capacidade |
| `--recording-flush-interval-ms` | 1.000 | 50–60.000 |
| `--minimum-free-disk-mb` | 256 | 0–1.048.576 |
| `--operational-update-interval-ms` | 1.000 | 250–60.000 |

O script Raspberry altera atualização para 150 ms e máximo gráfico para 3.000 pontos.

## 29. Gravação contínua

`RecordingService`: [`recording_service.py:25–403`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/recording_service.py#L25-L403).

Fluxo:

1. verificar pelo menos 256 MiB livres;
2. criar `queue.Queue` limitada a 8.192 frames;
3. criar arquivo `<session_id>.partial.h5`;
4. receber frames sem bloquear por `put_nowait()`;
5. escrever em thread dedicada;
6. acumular até 256 frames;
7. fazer flush por lote, por 1 s ou durante encerramento;
8. drenar a fila ao finalizar;
9. renomear atomicamente para `.h5` em sucesso.

Fila cheia marca a sessão como falha, interrompe a serial e preserva o parcial; não existe descarte silencioso intencional.

## 30. Estrutura HDF5

Implementação: [`hdf5_session_writer.py:22–339`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/hdf5_session_writer.py#L22-L339).

Versão de formato 8, esquema de metadados 2:

~~~text
/
└── frames
    ├── sequence_id   uint32  [N]
    ├── timestamp_us  uint64  [N]
    └── raw_values    float64 [N, canais]
~~~

Datasets em [`hdf5_session_writer.py:161–191`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/hdf5_session_writer.py#L161-L191):

- extensíveis;
- chunks iguais ao lote de escrita;
- gzip nível 1;
- shuffle ativado;
- contagens recebidas preservadas como float64.

Metadados incluem software, protocolo, porta, taxa nominal, canais, VREF, PGA, perfis de conversão, filtros ativos no início, estado e diagnósticos.

O HDF5 preserva o valor bruto recebido. Conversão, filtro e FFT são derivados e não substituem `raw_values`.

### 30.1 Hash

O layout `sha256-dataset-digests-v1` cria SHA-256 independente para sequência, timestamp e raw, depois combina os três digests com seus nomes. Implementação: [`hdf5_integrity.py:32–104`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/hdf5_integrity.py#L32-L104).

O hash cobre os três datasets, mas não os atributos e metadados.

### 30.2 Recuperação

Na inicialização, arquivos `.partial.h5` são finalizados automaticamente. A rotina:

1. calcula o menor comprimento entre os três datasets;
2. trunca os demais para esse comprimento;
3. recalcula o hash;
4. marca `completed`, `verified` e `unexpected_shutdown`;
5. renomeia para `.h5`.

Fonte: [`session_repository.py:222–304`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/session_repository.py#L222-L304).

### 30.3 Exportação CSV

A exportação usa blocos de 4.096 frames e arquivo temporário. Cabeçalho:

~~~text
sample_index,sequence_id,timestamp_us,ch0_<tipo>_raw_<unidade>,...
~~~

`sample_index` é criado durante a exportação e não substitui `sequence_id`.

## 31. Conversão de contagens

`ConversionService` implementa identidade, linear, polinomial, lookup table e ADS1256 diferencial: [`conversion_service.py:92–145`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/conversion_service.py#L92-L145).

Para ADS1256:

~~~python
full_scale = 2.0 * reference_voltage_v / gain
positivo = count * full_scale / 8_388_607.0
negativo = count * full_scale / 8_388_608.0
~~~

Fonte pontual: [`conversion_service.py:128–143`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/conversion_service.py#L128-L143).

O padrão de canal é raw. Selecionar tensão cria uma representação derivada; não altera o conteúdo bruto do HDF5.

## 32. Filtros digitais

Pipeline: [`filter_pipeline.py:24–257`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/filter_pipeline.py#L24-L257).

Ordem determinística:

~~~text
baseline → remoção DC → passa-altas → notch 60 Hz
→ passa-faixa → passa-baixas → média móvel → envelope
~~~

| Filtro | Implementação atual |
|---|---|
| baseline | Butterworth HP ordem 2, 0,5 Hz |
| remoção DC | subtração da média da janela |
| passa-altas geral | Butterworth ordem 4, 0,5 Hz |
| passa-altas EMG | Butterworth ordem 4, 20 Hz |
| notch | 60 Hz, Q 30; exige pelo menos 24 pontos e `fs > 130 Hz` |
| passa-faixa ECG/outro | 0,5–40 Hz |
| passa-faixa EMG | 20–150 Hz |
| passa-faixa EEG | 0,5–45 Hz |
| passa-faixa PPG | 0,5–12 Hz |
| passa-faixa respiração | 0,05–2 Hz |
| passa-baixas PPG | 12 Hz |
| passa-baixas respiração | 2 Hz |
| passa-baixas temperatura | 1 Hz |
| passa-baixas oximetria | 3 Hz |
| passa-baixas demais | 40 Hz |
| média móvel | aproximadamente 50 ms, comprimento ímpar |
| envelope | módulo seguido de média móvel |

Regras importantes:

- cortes altos são limitados a 90% de Nyquist;
- menos de 12 pontos retorna o sinal sem filtro SOS;
- falha de `sosfiltfilt` retorna o vetor original;
- filtros IIR usam ida e volta, são de fase zero e não causais;
- passa-altas/baixas de ordem 4 têm magnitude composta equivalente à ordem 8;
- passa-faixa de ordem 4 gera ordem 8 por passagem e aproximadamente 16 na magnitude composta;
- no Wn Butterworth, o resultado ida e volta fica aproximadamente em −6,02 dB;
- a janela inteira é filtrada novamente a cada atualização;
- todos os filtros começam desativados.

## 33. Espectro

Implementação: [`spectrum.py:19–123`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/spectrum.py#L19-L123).

Passos:

1. remover valores não finitos;
2. subtrair a média;
3. aplicar Hann;
4. corrigir ganho coerente;
5. calcular `rfft`;
6. produzir magnitude unilateral;
7. usar `Δf = fs/N`;
8. localizar o maior bin diferente de DC;
9. opcionalmente converter para dBFS com piso −160 dBFS.

Essa saída é espectro de amplitude, não PSD. O pico é o centro de um bin, sem interpolação. A taxa usada é a taxa nominal da sessão, não uma estimativa dos timestamps.

Para N ímpar, o último bin positivo não é Nyquist e deveria ser duplicado; o código atual multiplica somente `magnitudes[1:-1]` e subestima esse último bin por fator 2.

## 34. Interface e diagnóstico operacional

A interface possui páginas de menu, configuração, visualização ao vivo e sessões. A visualização:

- desenha somente o canal selecionado;
- suporta domínio temporal ou espectral;
- permite raw ou convertido/processado;
- possui pan, zoom e modo seguir;
- limita os pontos de desenho;
- não altera a gravação bruta ao limpar o gráfico;
- mostra CPU, RAM, temperatura e disco;
- exibe CRC como não disponível.

Somente o canal visível é convertido, filtrado e submetido à FFT em cada atualização: [`bootstrap.py:729–775`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/app/bootstrap.py#L729-L775).

O tipo lógico “Oximetria” não implementa cálculo de SpO₂. Seu uso é apenas um preset de sinal e unidade.

## 35. Scripts atuais para Raspberry Pi

### 35.1 Instalação

[`scripts/install_raspberry.sh:1–19`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/scripts/install_raspberry.sh#L1-L19):

- cria `.venv`;
- ativa o ambiente durante a instalação;
- atualiza pip;
- instala `requirements.txt`;
- instrui o operador sobre o grupo `dialout`.

### 35.2 Execução

[`scripts/run_raspberry.sh:1–11`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/scripts/run_raspberry.sh#L1-L11):

~~~text
QT_QPA_PLATFORM=xcb
fullscreen
update = 150 ms
max plot = 3000
fila = 8192
lote HDF5 = 256
flush = 1000 ms
~~~

O script chama `python3 main.py` sem ativar `.venv`. O desktop aponta para `/home/pi/processamento_biomedico/...`: [`serial-monitor.desktop:1–7`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/scripts/serial-monitor.desktop#L1-L7). Os scripts estão versionados sem bit executável e não existe unit `systemd` no repositório.

# Parte IV — Operação e reprodução do estado atual

## 36. Obter as versões exatas

~~~bash
git clone https://github.com/Tyrion1606/blackpill_ads1256-display.git
cd blackpill_ads1256-display
git checkout 7fc7d6d724f3d762ea08447b26180b6c7ec7d27a
git status --short
~~~

~~~bash
git clone https://github.com/AlexAndrei3663/processamento_biomedico.git
cd processamento_biomedico
git checkout d34b56bec961cbea028f5cc8573e845f4e215c63
git status --short
~~~

Os dois últimos comandos devem não produzir saída.

## 37. Verificação da montagem antes de energizar

1. desligar todas as fontes;
2. conferir PB12/PB13/PB14/PB15/PA8/PA9 do ADS1256;
3. conferir PB3/PB5/PB4/PB6/PB7 do display;
4. verificar DIN e DOUT;
5. verificar ausência de curto entre rails e GND;
6. medir continuidade dos terras;
7. confirmar tensões aceitas por cada módulo;
8. identificar fisicamente AINP e AINN de cada par;
9. não ligar voluntário, osciloscópio aterrado e carregadores sem análise de isolamento;
10. manter SPI curto e separado dos sinais analógicos.

## 38. Compilar o firmware

O ambiente auditado encontrou GCC em:

~~~text
/opt/st/stm32cubeide_2.1.1/plugins/
com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.linux64_1.0.100.202602081740/
tools/bin
~~~

No caminho original:

~~~bash
export PATH="/opt/st/stm32cubeide_2.1.1/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.14.3.rel1.linux64_1.0.100.202602081740/tools/bin:$PATH"
make -C Debug all -j4
~~~

O makefile Debug versionado referencia o linker script por caminho absoluto `/home/davi/repos/blackpill_ads1256+display/...`. Em outro caminho, importar/regenerar a configuração de build pelo STM32CubeIDE ou corrigir as referências de `-T`, preservando:

- Flash em `0x08004000`, 496 KiB;
- VTOR em `0x08004000`;
- SPI2 divisor 32;
- SPI3 divisor 2;
- PA8 DRDY e PA9 PDWN.

O `.ioc` atual ainda registra SPI2 divisor 2 e 24 Mbit/s, embora `spi.c` compilado use divisor 32. Não regenerar sem corrigir e revisar esse arquivo.

Verificações:

~~~bash
arm-none-eabi-size Debug/blackpill_ads1256+display.elf
arm-none-eabi-objdump -h Debug/blackpill_ads1256+display.elf
od -An -tx4 -N8 Debug/blackpill_ads1256+display.bin
sha256sum Debug/blackpill_ads1256+display.bin
~~~

## 39. Gravar e iniciar

Com WeAct HID Bootloader presente:

1. compilar a aplicação para `0x08004000`;
2. entrar no HID com KEY durante reset;
3. confirmar VID:PID `0483:572a`;
4. executar:

~~~bash
sudo ./WeAct_HID_Flash-CLI \
  /caminho/Debug/blackpill_ads1256+display.bin
~~~

5. resetar sem manter KEY;
6. observar a tela ST7735;
7. confirmar criação de `/dev/ttyACM*`.

Saída inicial esperada:

~~~text
# Inicializando ADS1256...
MUX do ADS1256 lido: 0x01
# ADS1256 OK. Iniciando leitura.
# Formato CSV: FRAME,seq,t_us,d1,d2,d3,d4
FRAME,0,...,...,...,...,...
~~~

## 40. Executar o validador de firmware

No repositório do firmware:

1. ajustar `PORTA_SERIAL` se necessário;
2. manter quatro canais e 100 s;
3. fechar outros consumidores da ACM;
4. executar:

~~~bash
python3 grava_serial_csv.py
~~~

5. conferir:

- quantidade próxima de 100.000 frames;
- sequência contínua no intervalo recebido;
- taxa próxima de 1.000 frames/s;
- quatro valores em todas as linhas;
- timestamps crescentes;
- nenhum texto não comentado durante o fluxo.

## 41. Instalar e iniciar a aplicação

~~~bash
cd processamento_biomedico
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
sudo usermod -a -G dialout "$USER"
~~~

É necessário sair e entrar novamente na sessão após alterar `dialout`.

Execução Desktop/XCB coerente com os parâmetros atuais:

~~~bash
QT_QPA_PLATFORM=xcb .venv/bin/python main.py \
  --fullscreen \
  --update-interval-ms 150 \
  --max-plot-points 3000 \
  --recording-queue-capacity 8192 \
  --recording-batch-size 256 \
  --recording-flush-interval-ms 1000
~~~

## 42. Configurar a sessão do hardware atual

1. selecionar a porta ACM correta;
2. selecionar 115200 como line coding;
3. configurar taxa base de 1.000 Hz;
4. configurar quatro canais na ordem ECG 1, ECG 2, PPG e Outro;
5. informar VREF real medida, ou registrar explicitamente o uso nominal de 2,5 V;
6. informar PGA 1;
7. manter raw na primeira aquisição;
8. iniciar sem filtros para validar o caminho bruto;
9. conectar a serial;
10. confirmar sequência crescente e quatro curvas;
11. iniciar a gravação;
12. finalizar e verificar o HDF5.

## 43. Verificar a sessão gravada

Uma sessão concluída deve apresentar:

- extensão `.h5`, não `.partial.h5`;
- três datasets com o mesmo número de frames;
- `raw_values` com quatro colunas;
- sequência e timestamp crescentes;
- hash `verified` quando recalculado;
- metadados de VREF, PGA, taxa e canais coerentes;
- exportação CSV com todas as linhas.

Enquanto o timestamp não mudar, limitar sessões contínuas a menos de 71 minutos ou reconectar antes do rollover.

# Parte V — Limitações vigentes

## 44. Hardware e aquisição

1. O circuito analógico as-built não está integralmente registrado.
2. VREF real e rails não estão preservados por ensaio.
3. Os quatro pares são sequenciais, sem timestamp por canal.
4. Defasagem, settling e diafonia não foram medidos formalmente.
5. DRDY normal não tem timeout e não exige transição alto→baixo.
6. Estado estático do pipeline não é reiniciado por uma reinicialização do driver em runtime.
7. STATUS, ADCON e DRATE não possuem readback.
8. Não existe caracterização atual de ENOB com entradas terminadas.
9. Anti-alias analógico de aproximadamente 500 Hz por canal não está documentado.

## 45. Firmware e transporte

1. Timestamp público dá wrap em 71 min 34,967 s.
2. O `.ioc` diverge do SPI2 compilado.
3. O makefile Debug não é portátil por caminho absoluto.
4. A linha de diagnóstico do MUX não começa com `#`.
5. O wrapper USB não propaga falha ou timeout ao `main`.
6. Não existe fila explícita de frames no firmware.
7. Não há CRC ou confirmação do host.
8. `Error_Handler` não pisca conforme o nome sugere.
9. A tela ainda usa nomenclatura resumida e não mostra `t_us` integralmente.

## 46. Aplicação e armazenamento

1. A configuração limpa contém três canais e é incompatível com o frame de quatro valores.
2. O contrato textual da aplicação diz que o timestamp pertence à primeira conversão, mas o firmware o lê antes do readout e a conversão de `d1` foi iniciada anteriormente.
3. O monitor não faz unwrapping do timestamp uint32.
4. Não há CRC.
5. O shutdown solicita parada da QThread serial, mas não espera seu término antes de finalizar a gravação.
6. O hash não cobre metadados.
7. Recuperação automática marca o parcial como `completed/verified` a partir dos comprimentos consistentes.
8. Mudanças de filtro durante uma gravação não são historizadas.
9. Uma sessão reaberta com decimação continua usando a taxa nominal original nos filtros e na FFT.
10. A FFT de janela ímpar subestima o último bin positivo.
11. “Oximetria” não calcula SpO₂ e usa unidade raw `%` apesar do firmware transmitir contagens.
12. Dependências não têm versões fixas.
13. Scripts Raspberry não formam uma implantação autônoma completa.

## 47. Segurança e uso pretendido

O sistema é protótipo acadêmico. O estado atual não demonstra:

- isolamento médico;
- limites de corrente de fuga;
- proteção contra desfibrilação;
- conformidade normativa;
- calibração metrológica rastreável;
- validação clínica ou diagnóstica;
- medição de SpO₂.

Não conectar uma pessoa enquanto USB, HDMI, carregadores ou instrumentos aterrados formarem caminhos não analisados. Alimentação por bateria, isoladamente, não prova isolamento de todo o sistema.

# Parte VI — Índice de código

## 48. Firmware

| Tema | Fonte permanente |
|---|---|
| endereço da aplicação | [`application_config.h:7–14`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/application_config.h#L7-L14) |
| linker | [`STM32F411CEUX_FLASH.ld:47–61`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/STM32F411CEUX_FLASH.ld#L47-L61) |
| boot, loop e CSV | [`main.c:56–139`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L56-L139) |
| clock e VTOR | [`main.c:152–203`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/main.c#L152-L203) |
| pinagem | [`main.h:60–73`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/main.h#L60-L73) |
| SPI2/SPI3 | [`spi.c:34–142`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/spi.c#L34-L142) |
| constantes ADS1256 | [`adc_ads1256.h:20–136`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Inc/adc_ads1256.h#L20-L136) |
| inicialização ADS1256 | [`adc_ads1256.c:159–244`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L159-L244) |
| pipeline | [`adc_ads1256.c:393–436`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/adc_ads1256.c#L393-L436) |
| timestamp | [`microsecond_delay.c:6–44`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/microsecond_delay.c#L6-L44) |
| USB wrapper | [`usb_cdc_serial.c:6–27`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/usb_cdc_serial.c#L6-L27) |
| interface CDC | [`usbd_cdc_if.c:271–293`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/USB_DEVICE/App/usbd_cdc_if.c#L271-L293) |
| display | [`display_st7735.c:107–152`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/display_st7735.c#L107-L152) |
| erro | [`application_error.c:5–22`](https://github.com/Tyrion1606/blackpill_ads1256-display/blob/7fc7d6d724f3d762ea08447b26180b6c7ec7d27a/Core/Src/application_error.c#L5-L22) |

## 49. Aplicação

| Tema | Fonte permanente |
|---|---|
| versão/protocolo | [`__init__.py:3–5`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/__init__.py#L3-L5) |
| parser | [`protocol.py:14–121`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/serial/protocol.py#L14-L121) |
| leitor serial | [`serial_reader.py:19–208`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/serial/serial_reader.py#L19-L208) |
| monitor | [`communication_monitor.py:12–221`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/communication_monitor.py#L12-L221) |
| aquisição ao vivo | [`live_acquisition_service.py:31–124`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/live_acquisition_service.py#L31-L124) |
| ring buffer | [`ring_buffer.py:8–105`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/ring_buffer.py#L8-L105) |
| gravação | [`recording_service.py:25–403`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/recording_service.py#L25-L403) |
| HDF5 | [`hdf5_session_writer.py:22–339`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/hdf5_session_writer.py#L22-L339) |
| hash | [`hdf5_integrity.py:10–104`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/hdf5_integrity.py#L10-L104) |
| recuperação/exportação | [`session_repository.py:130–410`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/infrastructure/storage/session_repository.py#L130-L410) |
| conversão | [`conversion_service.py:23–161`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/application/conversion_service.py#L23-L161) |
| filtros | [`filter_pipeline.py:24–269`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/filter_pipeline.py#L24-L269) |
| FFT | [`spectrum.py:19–123`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/processing/spectrum.py#L19-L123) |
| configuração da GUI | [`config_page.py:37–158`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/ui/pages/config_page.py#L37-L158) |
| argumentos | [`runtime_settings.py:9–123`](https://github.com/AlexAndrei3663/processamento_biomedico/blob/d34b56bec961cbea028f5cc8573e845f4e215c63/serial_monitor/app/runtime_settings.py#L9-L123) |

## 50. Checklist rápido do estado atual

- [ ] firmware exatamente em `7fc7d6d`;
- [ ] aplicação exatamente em `d34b56b`;
- [ ] BIN linkado em `0x08004000`;
- [ ] VTOR em `0x08004000`;
- [ ] SPI2 efetivo em 1,5 MHz;
- [ ] PA8 é DRDY e PA9 é PDWN;
- [ ] pares 01, 23, 45 e 67 conferidos;
- [ ] VREF e rails medidos;
- [ ] quatro canais configurados na GUI;
- [ ] taxa base configurada em 1.000 Hz;
- [ ] primeira sessão em raw e sem filtros;
- [ ] sequência e timestamp crescentes;
- [ ] HDF5 com quatro colunas e hash verificado;
- [ ] sessão limitada antes do rollover de 71,6 min;
- [ ] nenhuma pessoa conectada sem análise formal de segurança.

---

**Fim da documentação do estado atual.** Para trajetória, decisões e versões anteriores, consultar o dossiê cronológico separado; nenhuma informação histórica é necessária para operar a configuração descrita neste arquivo.
