; Arthur Alves da Costa - 13751207

ORG 0000H
JMP INICIO

; Vetor de interrupção timer 1 (Endereço 001BH)

ORG 001BH
    PUSH ACC            ; Salva o contexto do Acumulador na pilha
    INC R0              ; Incrementa a variável de processo (contagem)
    
    MOV A, R0
    CJNE A, #10, FIM_ISR ; Compara a variável de processo com 10
    
    ; Se atingiu 10 eventos, chama a subrotina dedicada para zerar o sistema
    CALL ROTINA_RESET    ; 

FIM_ISR:
    POP ACC             ; Restaura o contexto do Acumulador
    RETI                ; Retorna da interrupção

ORG 0030H
INICIO:
    ; Configuração do Timer 1 (Modo 2: Auto-reload 8 bits) e Interrupções
    ; TMOD = 01100000B (60H): Timer 1 configurado como Contador Externo (C/T=1)
    MOV TMOD, #01100000B
    
    ; Carrega FFH para garantir que o Timer estoure e gere interrupção a cada pulso do sensor
    MOV TH1, #0FFH
    MOV TL1, #0FFH
    
    ; Habilita a chave geral de interrupções (EA) e a específica do Timer 1 (ET1)
    SETB EA
    SETB ET1
    SETB TR1            ; Habilita o temporizador

    ; Inicialização das variáveis e periféricos
    CLR F0              ; F0 = 0 (Define o estado inicial da direção do motor)
    SETB P3.0           ; Aciona o motor
    CLR P3.1            
    SETB P2.0           ; Configura chave SW0 como entrada
    SETB P3.5           ; Configura P3.5 como entrada para o sensor
    
    MOV R0, #0          ; Inicializa a variável de processo em 0
    MOV DPTR, #TABELA_7SEG  

LOOP_PRINCIPAL:
    ; 1. Verifica e atualiza a direção do motor
    CALL VERIFICA_CHAVE  

    ; 2. Atualiza o display de 7 segmentos (Livre de polling do contador) 
    MOV A, R0           ; Move a variável de processo para o Acumulador
    MOVC A, @A+DPTR     ; Busca o padrão numérico 
    
    ; 3. Sinalização visual do sentido de rotação
    ; Insere o estado armazenado em F0 no bit 7 (Ponto Decimal) do display 
    MOV C, F0           
    MOV ACC.7, C        
    
    MOV P1, A           ; Envia padrão atualizado à porta P1 

    SJMP LOOP_PRINCIPAL 

; SUB-ROTINA: ROTINA_RESET
; Responsável por parar o timer, zerar a variável e reiniciar a contagem
ROTINA_RESET:
    CLR TR1             ; Para o temporizador 
    MOV R0, #0          ; Zera a variável de processo (volta para 0) 
    MOV TL1, #0FFH      ; Garante o reinício controlado do pulso
    SETB TR1            ; Reinicia a contagem 
    RET
;Direção do motor 
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
    CPL F0              ; Inverte o sentido em memória
    CPL P3.0            ; Inverte o pino físico do motor
    CPL P3.1            
    
    ; Integração solicitada: Chama a rotina de reset ao efetivar a mudança de direção [cite: 91]
    CALL ROTINA_RESET   
    RET

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