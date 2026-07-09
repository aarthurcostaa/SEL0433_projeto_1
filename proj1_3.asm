; Arthur Alves da Costa - 13751207

ORG 0000H
JMP INICIO

ORG 0030H
INICIO:
    ; Configuração do TMOD e Timer 1 
    ; Configuração para o Timer 1: GATE=0 | C/T=1 | M1=0 | M0=1 (Modo 1)
    ; C/T = 1 transforma o Timer em Contador por evento externo (pino P3.5)
    MOV TMOD, #01010000B
    
    ; Inicializa os registradores do Timer 1 com zero
    MOV TH1, #0
    MOV TL1, #0
    
    ; Habilita o Timer 1 para iniciar a contagem 
    SETB TR1 

    ; Inicialização das variáveis e periféricos
    CLR F0          ; F0 = 0 (Define o estado inicial da direção do motor)
    SETB P3.0       ; P3.0 = 1 (Aciona o motor em um sentido inicial)
    CLR P3.1        ; P3.1 = 0 
    SETB P2.0       ; Configura o pino P2.0 (chave SW0) como entrada
    SETB P3.5       ; Configura o pino P3.5 (T1) como entrada para o sensor
    
    ; Inicializa o DPTR para apontar para a tabela do display de 7 segmentos 
    MOV DPTR, #TABELA_7SEG  

LOOP_PRINCIPAL:
    ; 1. Verifica e atualiza a direção do motor 
    CALL VERIFICA_CHAVE  

    ; 2. Lê a variável de processo (contagem do Timer 1) 
    MOV A, TL1
    
    ; Limite de contagem
    CJNE A, #10, ATUALIZA_VARIAVEL ; Compara a contagem com 10
    
    ; Se chegou aqui, o contador atingiu 10. Reinicia o sistema de contagem
    MOV TL1, #0                    ; Reseta o contador físico do timer
    MOV A, #0                      ; Reseta o acumulador para exibir '0'
    
ATUALIZA_VARIAVEL:
    MOV R0, A       ; R0 atua como a variável que armazena a contagem (0 a 9)

    ; 3. Atualiza o display de 7 segmentos 
    MOV A, R0       ; Move o valor validado para o Acumulador
    MOVC A, @A+DPTR ; Busca o padrão numérico correspondente na tabela 
    MOV P1, A       ; Envia o padrão para acender o display 

    ; Retorna ao início do laço 
    SJMP LOOP_PRINCIPAL 

; Subs do check 2

VERIFICA_CHAVE:
    MOV C, P2.0     
    JB F0, ESTADO_F0_ALTO
ESTADO_F0_BAIXO:
    JC MUDANCA_DETECTADA 
    RET                  
ESTADO_F0_ALTO:
    JNC MUDANCA_DETECTADA 
    RET                  
MUDANCA_DETECTADA:
    CALL MUDA_DIRECAO
    RET

MUDA_DIRECAO:
    CPL F0          
    CPL P3.0        
    CPL P3.1        
    RET

; Mapeamento EdSim51: P1.7=DP, P1.6=g, P1.5=f, P1.4=e, P1.3=d, P1.2=c, P1.1=b, P1.0=a
TABELA_7SEG:
    DB 11000000B  ; 0
    DB 11111001B  ; 1
    DB 10100100B  ; 2
    DB 10110000B  ; 3
    DB 10011001B  ; 4
    DB 10010010B  ; 5
    DB 10000010B  ; 6
    DB 11111000B  ; 7
    DB 10000000B  ; 8
    DB 10010000B  ; 9
END