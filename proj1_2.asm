; Arthur Alves da Costa - 13751207
 
ORG 0000H
JMP INICIO

ORG 0030H
INICIO:
    ; Inicialização do sistema
    CLR F0          ; F0 = 0 (Define o estado inicial da direção do motor)
    SETB P3.0       ; P3.0 = 1 (Aciona o motor em um sentido inicial)
    CLR P3.1        ; P3.1 = 0 
    SETB P2.0       ; Configura o pino P2.0 (chave SW0) como entrada 

LOOP_PRINCIPAL:
    CALL VERIFICA_CHAVE  ; Monitora continuamente a chave
    SJMP LOOP_PRINCIPAL  ; Retorna ao início do laço

; SUB-ROTINA: VERIFICA_CHAVE
; Lê o estado da chave SW (P2.0) e compara com o estado salvo em F0

VERIFICA_CHAVE:
    MOV C, P2.0     ; Move a leitura do pino P2.0 para a flag Carry (C)
    
    ; O 8051 não possui comparação direta (CMP) entre bits isolados como C e F0
    ; Portanto, avalia-se o estado de F0 para decidir a lógica:
    JB F0, ESTADO_F0_ALTO
    
ESTADO_F0_BAIXO:
    ; Se F0 = 0, verifica se a chave lida (C) é 1 (houve mudança)
    JC MUDANCA_DETECTADA 
    RET                  ; Se a chave também for 0, mantém o sentido

ESTADO_F0_ALTO:
    ; Se F0 = 1, verifica se a chave lida (C) é 0 (houve mudança)
    JNC MUDANCA_DETECTADA 
    RET                  ; Se a chave também for 1, mantém o sentido

MUDANCA_DETECTADA:
    ; Se os estados diferirem, chama a rotina para inverter o motor
    CALL MUDA_DIRECAO
    RET

; SUB-ROTINA: MUDA_DIRECAO
; Inverte a variável de estado F0 e altera os sinais nos pinos do motor

MUDA_DIRECAO:
    CPL F0          ; Atualiza a variável de estado (inverte de 0 para 1 ou 1 para 0)
    CPL P3.0        ; Inverte o sinal de controle no pino P3.0
    CPL P3.1        ; Inverte o sinal de controle no pino P3.1
    RET

END