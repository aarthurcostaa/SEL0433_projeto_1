; Arthur Alves da Costa - 13751207 

ORG 0000H
JMP MAIN

ORG 0030H
MAIN:
    ; Inicializa o ponteiro de dados (DPTR) para a tabela de padrões do display
    MOV DPTR, #TABELA_7SEG  

LEITURA_BOTOES:
    MOV P2, #0FFH           ; Configura todos os pinos de P2 como entrada (pull-ups)
    
    ; Lê o estado de todos os botões simultaneamente
    MOV A, P2               
    
    ; Compara o Acumulador com FFH (todos os botões soltos = nível alto)
    ; Se A não for igual a FFH, salta para VERIFICA_BOTOES
    CJNE A, #0FFH, VERIFICA_BOTOES 
    
    ; Se chegou nesta linha, A é igual a FFH (nenhum botão pressionado).
    ; Apaga todos os segmentos (nível lógico 1 no ânodo comum)
    MOV P1, #11111111B      
    SJMP LEITURA_BOTOES     ; Retorna ao início do loop

VERIFICA_BOTOES:
    ; Testa individualmente qual chave está em nível baixo (0)
    JNB P2.0, MOSTRA_0
    JNB P2.1, MOSTRA_1
    JNB P2.2, MOSTRA_2
    JNB P2.3, MOSTRA_3
    JNB P2.4, MOSTRA_4
    JNB P2.5, MOSTRA_5
    JNB P2.6, MOSTRA_6
    JNB P2.7, MOSTRA_7
    
    ; Retorno de segurança
    SJMP LEITURA_BOTOES

; Carrega o valor correspondente à chave pressionada no Acumulador
MOSTRA_0: MOV A, #0 
          SJMP ATUALIZA_DISPLAY
MOSTRA_1: MOV A, #1 
          SJMP ATUALIZA_DISPLAY
MOSTRA_2: MOV A, #2 
          SJMP ATUALIZA_DISPLAY
MOSTRA_3: MOV A, #3 
          SJMP ATUALIZA_DISPLAY
MOSTRA_4: MOV A, #4 
          SJMP ATUALIZA_DISPLAY
MOSTRA_5: MOV A, #5 
          SJMP ATUALIZA_DISPLAY
MOSTRA_6: MOV A, #6 
          SJMP ATUALIZA_DISPLAY
MOSTRA_7: MOV A, #7 
          SJMP ATUALIZA_DISPLAY

ATUALIZA_DISPLAY:
    ; Busca o padrão binário na memória de programa usando DPTR e A 
    MOVC A, @A+DPTR         
    
    ; Envia o padrão para a porta P1 (acende o número no display)
    MOV P1, A               
    
    SJMP LEITURA_BOTOES


; Padrões binários para display de 7 segmentos tipo Ânodo Comum
; Mapeamento EdSim51: P1.7=DP, P1.6=g, P1.5=f, P1.4=e, P1.3=d, P1.2=c, P1.1=b, P1.0=a
; Lógica invertida: 0 = segmento aceso, 1 = segmento apagado

TABELA_7SEG:
    DB 11000000B  ; Padrão para o número 0
    DB 11111001B  ; Padrão para o número 1
    DB 10100100B  ; Padrão para o número 2
    DB 10110000B  ; Padrão para o número 3
    DB 10011001B  ; Padrão para o número 4
    DB 10010010B  ; Padrão para o número 5
    DB 10000010B  ; Padrão para o número 6
    DB 11111000B  ; Padrão para o número 7
END