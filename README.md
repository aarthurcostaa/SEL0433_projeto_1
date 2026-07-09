# SEL0433_projeto_1
Implementaçõ de um controlador de motor rotativo usando o microcontrolador 8051

## Checkpoint 1 - Leitura de Botões, Acionamento de LEDs e Display de 7 Segmentos

##  Mapeamento de Hardware
O desenvolvimento e a validação do firmware foram conduzidos através do simulador computacional **EdSim51**, respeitando a seguinte distribuição de pinos:

* Entradas (Switches 0 a 7): Mapeados integralmente na Porta 2 (P2.0 a P2.7). 
  * *Comportamento físico:* Quando uma chave está aberta (desativada), o pull-up interno garante nível lógico ALTO ( 1 ). Quando pressionada, o pino é aterrado, resultando em nível lógico BAIXO ( 0 ).
* Saídas (Display de 7 Segmentos): Conectado à Porta 1 (P1.0 a P1.7).
  * *Tipo:* Ânodo Comum.
  * *Lógica de Acionamento:* Invertida. Para acender um segmento, deve-se aplicar nível lógico BAIXO ( 0 ) no pino correspondente. Para apagar, nível lógico ALTO ( 1 ).
  * *Mapeamento de Bits:*  P1.0  (a),  P1.1  (b),  P1.2  (c),  P1.3  (d),  P1.4  (e),  P1.5  (f),  P1.6  (g),  P1.7  (Ponto Decimal - DP).

---

##  Arquitetura do Código e Fluxo de Execução

O firmware foi estruturado em blocos lógicos funcionais com rotinas claras de leitura, comparação condicional, decodificação e escrita periférica:

1. Inicialização ( MAIN ): Aponta o registrador de 16 bits  DPTR  para o endereço base da tabela indexada  TABELA_7SEG  armazenada na memória de programa ( Code Memory ).
2. Varredura Ativa ( LEITURA_BOTOES ): 
   * Escreve  0FFH  em  P2  para configurar os pinos adequadamente como entrada e ativar os resistores de pull-up internos.
   * Lê o byte completo de  P2  e armazena no Acumulador ( A ).
   * Realiza um teste coletivo utilizando a instrução  CJNE A, #0FFH, VERIFICA_BOTOES . Se o valor for exatamente  0FFH , significa que nenhuma chave está pressionada. O programa então escreve  11111111B  em  P1 , limpando o display imediatamente, e reinicia o ciclo de varredura.
3. Decodificação de Prioridade ( VERIFICA_BOTOES ): Caso algum bit seja  0 , testa individualmente do pino  P2.0  ao  P2.7  utilizando  JNB  (Jump if Net Bit is Zero). O primeiro botão detectado desvia o fluxo para sua respectiva rotina de carga ( MOSTRA_X ).
4. Indexação e Busca ( ATUALIZA_DISPLAY ): A rotina carrega o índice puramente numérico (0 a 7) no Acumulador e executa a instrução  MOVC A, @A+DPTR . O barramento interno calcula o endereço absoluto ( A + DPTR ), recupera o byte de mapeamento de segmentos e o transfere para  P1 , atualizando a tela antes de retornar ao loop.

---

##  Instruções Principais

*  MOV DPTR, #TABELA_7SEG : Carrega o endereço de memória de 16 bits onde a tabela está localizada. Essencial para que o microcontrolador saiba onde buscar os bytes de configuração do display.
*  MOV P2, #0FFH : Passo indispensável na arquitetura do 8051. Garante que travas internas não fiquem presas no último estado lógico lido, permitindo uma amostragem em tempo real livre de flutuações (*glitches*).
*  CJNE A, #0FFH, TARGET : (Compare and Jump if Not Equal) Compara o estado geral da porta de entrada com a constante de repouso ( 0FFH ). É a instrução responsável pela otimização do reset automático do display quando o operador solta a chave.
*  JNB P2.X, TARGET : (Jump if Bit is Not Set) Avalia cada pino bit a bit de forma sequencial. Como a lógica do botão acionado é nível zero, o desvio só ocorre para a chave fisicamente ativa.
*  MOVC A, @A+DPTR : Instrução de leitura de memória de programa. Transforma o valor do Acumulador (que guardava o número do botão, de 0 a 7) no padrão de segmentos real através de uma operação de deslocamento indexado.

---
## Resultado 

No vídeo abaixo temos a simulação do código no EdSim 

https://github.com/user-attachments/assets/b4afa836-4fe8-4c19-9ce1-fe495d6dfc56

---

## Checkpoint 2 - Controle de direção do motor
## Mapeamento de Hardware


* Entradas (Chave de controle): Mapeado no pino P2.0 (chave SW0).
* Comportamento físico: Quando a chave está aberta (desativada), o pull-up interno garante nível lógico ALTO (1). Quando pressionada, o pino é aterrado, resultando em nível lógico BAIXO (0).
* Saídas (Motor DC): Conectado à Porta 3, utilizando os pinos P3.0 e P3.1.
* Lógica de Acionamento: O motor DC no simulador responde a sinais complementares para determinar a direção. Para girar em um sentido, P3.0 recebe 1 e P3.1 recebe 0. Para inverter a rotação, P3.0 recebe 0 e P3.1 recebe 1.
* Memória de Estado: A flag F0, pertencente ao registrador especial de status (PSW), atua como uma variável booleana interna para gravar o sentido de rotação atual do motor.

--- 

## Arquitetura do Código e Fluxo de Execução

* Inicialização (INICIO): Prepara o microcontrolador definindo a flag F0 como 0 (estado base), aciona o motor enviando nível ALTO para P3.0 e nível BAIXO para P3.1, e escreve 1 em P2.0 para configurá-lo corretamente como pino de entrada.
* Laço Principal (LOOP_PRINCIPAL): Mantém o programa rodando em um ciclo infinito, dedicando-se a chamar a sub-rotina de verificação de hardware e aguardar o retorno contínuo.
* Monitoramento de Estado (VERIFICA_CHAVE):
* Move a leitura física instantânea do pino P2.0 para a flag Carry (C).
* Utiliza a instrução JB para ramificar a lógica dependendo do estado pré-gravado em F0 (0 ou 1).
* Compara a leitura atual da chave (armazenada em C) com o estado salvo. Se a chave indicar uma alteração pelo operador, invoca a sub-rotina de mudança de direção. Caso contrário, retorna ao fluxo principal sem modificar o motor.
* Inversão de Atuação (MUDA_DIRECAO): Quando acionada pela condição de mudança, inverte simultaneamente o valor salvo em F0 e os estados lógicos aplicados aos pinos de controle P3.0 e P3.1, revertendo fisicamente o sentido da rotação.

## Instruções Principais

* CALL e RET: (Call Subroutine / Return) Estruturam o código em blocos independentes e modulares. CALL desvia a execução salvando o endereço de retorno na pilha de memória (stack), e RET resgata esse endereço para voltar ao ponto exato em que a rotina foi chamada.
* MOV C, P2.0: Transfere o estado instantâneo do pino de entrada para a flag Carry, permitindo que operações lógicas de desvio condicional sejam feitas sobre essa leitura.
* JB F0, TARGET: (Jump if Bit is Set) Desvia o fluxo de execução se o bit especificado (F0) for igual a 1. É a instrução essencial para dividir a árvore de decisão lógica baseada no estado anterior do motor.
* JC e JNC: (Jump if Carry is Set / Not Set) Avaliam a flag Carry (que contém a leitura do botão) para concluir o teste de comparação de mudança de estado.
* CPL BIT: (Complement Bit) Inverte de forma direta o estado lógico de um bit (de 0 para 1, ou de 1 para 0). Otimiza drasticamente o código ao evitar múltiplas instruções lógicas na hora de trocar o sentido dos pinos P3.0 e P3.1 e atualizar a flag F0.

## Resultado

No vídeo abaixo temos a simulação do código no EdSim

https://github.com/user-attachments/assets/1afccf6c-280c-4573-822f-aa99954aebbe

## Checkpoint 3 - Contagem de voltas com o timer

## Mapeamento de Hardware

* Entradas (Sensor de pulsos): O sensor de rotação do motor está fisicamente mapeado no pino P3.5, que atua como a entrada de clock externo para o Timer 1 do 8051.
* Entradas (Chave de controle): Mapeado no pino P2.0 (chave SW0) para inversão de sentido.
* Saídas (Display de 7 Segmentos): Conectado à Porta 1 (P1.0 a P1.7), operando com lógica invertida de Ânodo Comum.
* Saídas (Motor DC): Conectado à Porta 3, utilizando os pinos P3.0 e P3.1 para controle direcional.

---

## Arquitetura do Código e Fluxo de Execução

1. Configuração do Hardware (INICIO): O registrador TMOD é configurado com o byte 01010000B (50H). Isso ativa o Timer 1 e ajusta o bit C/T (Counter/Timer) para nível lógico 1, transformando o periférico em um contador que incrementa a cada pulso de descida gerado pelo sensor no pino P3.5. A contagem é iniciada habilitando o bit TR1.
2. Laço Principal (LOOP_PRINCIPAL): O programa mantém a chamada contínua da sub-rotina de direção do motor (VERIFICA_CHAVE), garantindo que o sistema continue respondendo instantaneamente às ações do operador.
3. Leitura do Processo: Em cada ciclo, o valor atual dos pulsos do motor é capturado a partir da parte baixa do temporizador (registrador TL1).
4. Teste de Limite: Para garantir a visualização correta da interface, o valor lido é comparado com o número 10. Se a contagem atingir esse limite, o registrador TL1 é forçadamente zerado pelo software.
5. Atualização do Display: O valor estabilizado da variável de processo é usado como índice de busca na memória de programa (DPTR e MOVC). O padrão de segmentos correspondente é enviado à porta P1.

---

## Instruções Principais

* MOV TMOD, #01010000B: Configura a arquitetura interna do 8051 para que o Timer 1 atue como contador de eventos. Em vez de contar ciclos de máquina internos, ele passa a monitorar os eventos do motor.
* SETB TR1: Habilita o funcionamento do temporizador, permitindo o registro dos pulsos lidos pelo sensor.
* MOV A, TL1: Captura o valor instantâneo do contador de eventos. O registrador TL1 atua na prática como a nossa variável de processo.
* CJNE A, #10, TARGET: Compara o valor acumulado com a constante 10. É a instrução lógica responsável por criar o limite de contagem, impedindo que o display apague ao tentar ler endereços de memória não mapeados na tabela de 0 a 9.
* MOVC A, @A+DPTR: Utiliza o valor da contagem (agora limitado de 0 a 9) para indexar a tabela na memória de código e retornar o byte correspondente para acender o display.

---
## Resultado 

No vídeo abaixo temos a simulação do código no EdSim

https://github.com/user-attachments/assets/44ac97c5-1d02-4f25-9385-c614125fb9cf

## Entrega Final

## Mapeamento de Hardware

* Entradas (Sensor de pulsos): O sensor de rotação do motor está fisicamente mapeado no pino P3.5 (clock externo).
* Entradas (Chave de controle): Mapeado no pino P2.0 (chave SW0) para inversão de sentido.
* Saídas (Display de 7 Segmentos): Conectado à Porta 1 (P1.0 a P1.7), operando com lógica invertida de Ânodo Comum. O bit P1.7 (Ponto Decimal) agora é utilizado como indicador visual do sentido de rotação.
* Saídas (Motor DC): Conectado à Porta 3, utilizando os pinos P3.0 e P3.1 para controle direcional.

---

## Arquitetura do Código e Fluxo de Execução

1. Configuração de Interrupções (INICIO): O Timer 1 foi reconfigurado para o Modo 2 (Auto-reload de 8 bits) com o valor inicial FFH. Isso garante que a cada pulso recebido do motor, o contador estoure imediatamente e acione o vetor de interrupção do Timer 1 (endereço 001BH). As chaves de interrupção EA e ET1 são ativadas.
2. Rotina de Serviço de Interrupção (ISR): O incremento da variável de processo (R0) e a comparação de limite (CJNE A, #10) ocorrem de forma invisível em segundo plano. O laço principal fica dedicado exclusivamente a ler a chave e atualizar a interface gráfica.
3. Reset Controlado: Uma sub-rotina específica (ROTINA_RESET) foi criada para desligar o timer, zerar a contagem e reiniciar o sistema. Ela é acionada em duas situações: automaticamente quando a contagem atinge 10 eventos, e forçadamente sempre que o operador inverte o sentido do motor.
4. Sinalização Visual Integrada: O estado da variável de direção (F0) é copiado diretamente para o bit 7 do Acumulador antes do envio à porta P1. Isso faz com que o Ponto Decimal do display acenda em um sentido e apague no outro, fornecendo feedback instantâneo.

---

## Instruções Principais

* ORG 001BH: Define o endereço absoluto do vetor de interrupção do Timer 1 na memória de programa. Quando o timer estoura, o hardware desvia a execução automaticamente para este ponto.
* PUSH e POP: Instruções de manipulação da pilha (Stack) utilizadas na ISR para salvar e restaurar o contexto do Acumulador, evitando corromper dados do laço principal.
* RETI: (Return from Interrupt) Finaliza a rotina de interrupção, informando ao hardware que o atendimento foi concluído e retornando ao fluxo original.
* MOV ACC.7, C: Realiza a injeção direta do valor da flag Carry (que recebeu o estado de F0) no bit mais significativo do Acumulador, controlando o LED do Ponto Decimal sem alterar os demais segmentos do número exibido.

---
## Resultado 

No vídeo abaixo temos a simulação do código no EdSim.


https://github.com/user-attachments/assets/a51cd2ae-82aa-4490-9b91-7bb3c801fffc



