# SEL0433_projeto_1
Implementaçõ de um controlador de motor rotativo usando o microcontrolador 8051

## Checkpoint 1 - Leitura de Botões, Acionamento de LEDs e Display de 7 Segmentos

##  Mapeamento de Hardware
O desenvolvimento e a validação do firmware foram conduzidos através do simulador computacional **EdSim51**, respeitando a seguinte distribuição de pinos:

* **Entradas (Switches 0 a 7):** Mapeados integralmente na **Porta 2 (P2.0 a P2.7)**. 
  * *Comportamento físico:* Quando uma chave está aberta (desativada), o pull-up interno garante nível lógico ALTO (`1`). Quando pressionada, o pino é aterrado, resultando em nível lógico BAIXO (`0`).
* **Saídas (Display de 7 Segmentos):** Conectado à **Porta 1 (P1.0 a P1.7)**.
  * *Tipo:* Ânodo Comum.
  * *Lógica de Acionamento:* Invertida. Para acender um segmento, deve-se aplicar nível lógico BAIXO (`0`) no pino correspondente. Para apagar, nível lógico ALTO (`1`).
  * *Mapeamento de Bits:* `P1.0` (a), `P1.1` (b), `P1.2` (c), `P1.3` (d), `P1.4` (e), `P1.5` (f), `P1.6` (g), `P1.7` (Ponto Decimal - DP).

---

##  Arquitetura do Código e Fluxo de Execução

O firmware foi estruturado em blocos lógicos funcionais com rotinas claras de leitura, comparação condicional, decodificação e escrita periférica:

1. Inicialização (`MAIN`): Aponta o registrador de 16 bits `DPTR` para o endereço base da tabela indexada `TABELA_7SEG` armazenada na memória de programa (`Code Memory`).
2. Varredura Ativa (`LEITURA_BOTOES`): 
   * Escreve `0FFH` em `P2` para configurar os pinos adequadamente como entrada e ativar os resistores de pull-up internos.
   * Lê o byte completo de `P2` e armazena no Acumulador (`A`).
   * Realiza um teste coletivo utilizando a instrução `CJNE A, #0FFH, VERIFICA_BOTOES`. Se o valor for exatamente `0FFH`, significa que nenhuma chave está pressionada. O programa então escreve `11111111B` em `P1`, limpando o display imediatamente, e reinicia o ciclo de varredura.
3. Decodificação de Prioridade (`VERIFICA_BOTOES`): Caso algum bit seja `0`, testa individualmente do pino `P2.0` ao `P2.7` utilizando `JNB` (Jump if Net Bit is Zero). O primeiro botão detectado desvia o fluxo para sua respectiva rotina de carga (`MOSTRA_X`).
4. Indexação e Busca (`ATUALIZA_DISPLAY`): A rotina carrega o índice puramente numérico (0 a 7) no Acumulador e executa a instrução `MOVC A, @A+DPTR`. O barramento interno calcula o endereço absoluto (`A + DPTR`), recupera o byte de mapeamento de segmentos e o transfere para `P1`, atualizando a tela antes de retornar ao loop.

---

##  Instruções Principais

* `MOV DPTR, #TABELA_7SEG`: Carrega o endereço de memória de 16 bits onde a tabela está localizada. Essencial para que o microcontrolador saiba onde buscar os bytes de configuração do display.
* `MOV P2, #0FFH`: Passo indispensável na arquitetura do 8051. Garante que travas internas não fiquem presas no último estado lógico lido, permitindo uma amostragem em tempo real livre de flutuações (*glitches*).
* `CJNE A, #0FFH, TARGET`: (Compare and Jump if Not Equal) Compara o estado geral da porta de entrada com a constante de repouso (`0FFH`). É a instrução responsável pela otimização do reset automático do display quando o operador solta a chave.
* `JNB P2.X, TARGET`: (Jump if Bit is Not Set) Avalia cada pino bit a bit de forma sequencial. Como a lógica do botão acionado é nível zero, o desvio só ocorre para a chave fisicamente ativa.
* `MOVC A, @A+DPTR`: Instrução de leitura de memória de programa. Transforma o valor do Acumulador (que guardava o número do botão, de 0 a 7) no padrão de segmentos real através de uma operação de deslocamento indexado.

---
## Resultado 

No vídeo abaixo temos a simulação do código no EdSim 

https://github.com/user-attachments/assets/b4afa836-4fe8-4c19-9ce1-fe495d6dfc56

