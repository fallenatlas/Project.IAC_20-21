Term_escreve    EQU     FFFEh ;Terminal
Term_cursor     EQU     FFFCh

Temp_Ativ       EQU     FFF7h ;Temporizador
Temp_Cont       EQU     FFF6h
Temp_Rate       EQU     2     ;200 ms refresh rate
Temp_Start      EQU     1

Disp7_0         EQU     FFF0h  ;Display de 7 segmentos 
Disp7_1         EQU     FFF1h
Disp7_2         EQU     FFF2h
Disp7_3         EQU     FFF3h
Disp7_4         EQU     FFEEh
Disp7_5         EQU     FFEFh

INT_MASK        EQU     FFFAh  ;mascara de Interrupções
INT_MASK_VAL    EQU     801bh ;100000000010010b Temporizador, 0 e seta para cima

Altura_max      EQU     1F0Ah ;Valor do cursor quando o dino atinge altura max
Cursor_Pes_Chao EQU     250Ah ;Valor do cursor quando o dino está no chão

STACKBASE       EQU     8000h  ;Constantes das funções atualizajogo e geracacto
constxor        EQU     b400h  ;Constante usada para gerar o terreno
const95         EQU     7999h  ;Constante usada para gerar o terreno

                ORIG    4000h
                
valorterreno    TAB     80    ;Tabela com os valores de altura do terreno

                ORIG    0000h
                
                ;Variáveis 
x               WORD    5  ;Semente de criação do terreno
Estado_jogo     WORD    0  ;0->Jogo não decorre 1->Jogo decorre
DISPLAY_0       WORD    0  ;Valor que aparece no display0
DISPLAY_1       WORD    0  ;Valor que aparece no display1
DISPLAY_2       WORD    0  ;Valor que aparece no display2
DISPLAY_3       WORD    0  ;Valor que aparece no display3
DISPLAY_4       WORD    0  ;Valor que aparece no display4
Timer_tick      WORD    0  ;
Estado_Dino     WORD    0  ;0->Dino no chao, -1->Dino desce, 1->Dino sobe
Cursor_Pes      WORD    250Ah  ;Posição do cursor dos pés do dinossauro
Dino_Tab        TAB     4  ;Tabela com os caracteres do dinossauro
Cacto_Tab       TAB     5  ;Tabela com os caracteres dos cactos
Cacto_Vazio     TAB     5  ;
Game_Over_Tab   TAB     9  ;Tabela com os caracteres GAME OVER


                ORIG    1000h
                
Main:           MVI     R1, '┴'     ;Guardar caracteres do Dinosssauro em tabela
                MVI     R2, Dino_Tab
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '┤'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '┌'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '^'
                STOR    M[R2], R1
                
                MVI     R1, '║'     ;Guardar caracteres do Cacto em tabela
                MVI     R2, Cacto_Tab
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '╠'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '╣'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '║'     
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, '╦'
                STOR    M[R2], R1
                
                MVI     R1, 'G'     ;Guardar caracteres GAME OVER em tabela
                MVI     R2, Game_Over_Tab 
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'A'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'M'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'E'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, ' '
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'O'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'V'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'E'
                STOR    M[R2], R1
                
                INC     R2
                MVI     R1, 'R'
                STOR    M[R2], R1

                MVI     R6, STACKBASE  ;Inicializar pilha
                
                MVI     R1, INT_MASK      ;Definir máscara
                MVI     R2, INT_MASK_VAL
                STOR    M[R1], R2
                
                ENI        ;Iniciar interrupções
                
                MVI     R2, Estado_jogo   
Loop:           LOAD    R1, M[R2]      ;Se botão Key0 nao for pressionado não
                CMP     R1, R0         ;começamos jogo
                BR.Z    Loop  
                
                MVI     R5, Timer_tick ;Atualizar score quando passar 200 ms
                LOAD    R1, M[R5]
                CMP     R1, R0
                JAL.NZ  Process_pontos
                
                BR      Loop
                
                
Process_pontos: DEC     R6           ;Guardar Valores dos registos
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2

                MVI     R2,Timer_tick  ;Zona crítica
                DSI     
                LOAD    R1,M[R2]
                DEC     R1
                STOR    M[R2],R1
                ENI
                
                
.show_time:     MVI     R1, valorterreno     ;R2 - Altura chao/cacto
                MVI     R2, 0009h            ;R3 - Cursor dos pes do dinossauro
                ADD     R1, R1, R2           ;R4 - 0100H
                LOAD    R2, M[R1]            ;R5 - Cursor pes dino no chao
                MVI     R1, Cursor_Pes 
                LOAD    R3, M[R1]
                MVI     R4, 0100h
                MVI     R5, Cursor_Pes_Chao
                CMP     R2, R0
                BR.NZ   .Colisao
                BR      .ADD_DISPLAY_0
                
.Colisao:       CMP     R3, R5      
                BR.NN   .eh_colisao_1 ;Se haver colisão saltar para eh_colisao_1
                SUB     R5, R5, R4
                DEC     R2
                CMP     R2, R0
                BR.NZ   .Colisao
                BR      .ADD_DISPLAY_0
                
.eh_colisao_1:  MVI     R1, Estado_jogo 
                MVI     R2, 0    ;Colocar estado de jogo a 0
                STOR    M[R1], R2
                MVI     R1, 1923h   ;R1 - Cursor da letra G
                MVI     R2, Game_Over_Tab ;R2 - Endereço da tabela Game_Over_Tab
                MVI     R5, 9   ;R5 - Contador do loop para os 9 caracteres

.eh_colisao_2:  DSI      ;Disable interrupções
                ;Escrever GAME OVER no centro do terminal
                MVI     R4, Term_cursor   
                STOR    M[R4], R1
                LOAD    R3, M[R2]
                MVI     R4, Term_escreve
                STOR    M[R4], R3
                INC     R2
                INC     R1
                DEC     R5
                CMP     R5, R0
                BR.NZ   .eh_colisao_2
                
                MVI     R1, valorterreno
                MVI     R2, 80
                
.Reset_terreno: ;Dar reset ao terreno para começar sem cactos
                STOR    M[R1], R0   
                DEC     R2
                INC     R1
                CMP     R2, R0
                BR.NZ   .Reset_terreno
                ENI     
                JMP     R7


                
                
                ;Atualizar tempo
.ADD_DISPLAY_0: MVI     R1, Estado_jogo  ;Escrever pontos no display0
                LOAD    R2, M[R1]
                CMP     R2, R0
                JMP.Z   R7
                MVI     R1,DISPLAY_0
                LOAD    R2, M[R1]
                
                ;Se o algarismo das unidades for 9 incrementar as dezenas
                MVI     R4, 9   
                CMP     R2, R4
                BR.NN   .ADD_DISPLAY_1   
                ;Atualizar unidades      
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_0
                STOR    M[R1],R2
                
                
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      .show_jogo
                
                
.ADD_DISPLAY_1:  
                MOV     R2, R0           ;O máximo de pontos é 9999 
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_0
                STOR    M[R1],R2            
                ;zona das dezenas
                MVI     R1,DISPLAY_1
                LOAD    R2,M[R1]
                
                ;Se o algarismo das dezenas for 9 incrementar as centenas
                MVI     R4, 9  
                CMP     R2, R4
                BR.NN   .ADD_DISPLAY_2
                ;Atualizar dezenas       
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_1
                STOR    M[R1],R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      .show_jogo
                
.ADD_DISPLAY_2: MOV     R2, R0
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_1
                STOR    M[R1],R2 
                ;zonas das centenas
                MVI     R1,DISPLAY_2
                LOAD    R2,M[R1]
                
                MVI     R4, 9
                CMP     R2, R4
                BR.NN   .ADD_DISPLAY_3  
                
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_2
                STOR    M[R1],R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      .show_jogo
                
.ADD_DISPLAY_3: MOV     R2, R0     ;Não é usado o display dos milhares
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_2
                STOR    M[R1],R2 
                ;ZONA DOS MILHARES
                MVI     R1,DISPLAY_3
                LOAD    R2,M[R1]
                
                MVI     R4, 9
                CMP     R2, R4
                BR.NN   .MAKE0
                
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_3
                STOR    M[R1],R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      .show_jogo
                
.MAKE0:         MOV     R2, R0      
                STOR    M[R1], R2
                
                MVI     R1, '0'
                ADD     R2, R2, R1
                
                MVI     R1,Disp7_3
                STOR    M[R1],R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                BR      .show_jogo
                
                
.show_jogo:      DEC     R6          ;guardar valores dos registos
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R1, valorterreno   ;atualizar o chao
.cacto_atualiza:
                MVI     R4, 404Fh
                CMP     R1, R4         
                BR.Z    .DES_DINO     ;se tivermos acabado de percorrer a
                LOAD    R2, M[R1]          ;tabela, acabar o ciclo
                CMP     R2, R0
                BR.NZ   .desenha_cacto      ;se o valor na tabela for diferente
                MOV     R4, R1             ;de 0 desenhar cacto
                MVI     R5, 4000h
                SUB     R4, R4, R5
                MVI     R5, 2600h
                ADD     R4, R4, R5
                MVI     R5, Term_cursor    ;se for zero desenhar o chao 
                STOR    M[R5], R4
                MVI     R2, '_'
                MVI     R3, Term_escreve
                STOR    M[R3], R2
                
                MVI     R2, 0100h
                SUB     R4, R4, R2
                MVI     R2, ' '
                STOR    M[R5], R4
                STOR    M[R3], R2
                
                MVI     R2, 0100h
                SUB     R4, R4, R2
                MVI     R2, ' '
                STOR    M[R5], R4
                STOR    M[R3], R2
                
                MVI     R2, 0100h
                SUB     R4, R4, R2
                MVI     R2, ' '
                STOR    M[R5], R4
                STOR    M[R3], R2
                
                MVI     R2, 0100h
                SUB     R4, R4, R2
                MVI     R2, ' '
                STOR    M[R5], R4
                STOR    M[R3], R2
                
                INC     R1
                BR      .cacto_atualiza    ;ir para o proximo endereco da tabela
                
.desenha_cacto:  MVI     R3, Cacto_Tab
                MVI     R5, 4000h         ;determinar a posicao a meter o cacto
                MOV     R4, R1
                SUB     R4, R4, R5
                MVI     R5, 2600h
                ADD     R4, R4, R5       
                
.altura:        DEC     R6
                STOR    M[R6], R4
                
                MVI     R5, Term_cursor    ;desenhar o caracter correspondente 
                STOR    M[R5], R4          ;a altura do cacto
                
                LOAD    R4, M[R3]
                
                MVI     R5, Term_escreve
                STOR    M[R5], R4
                
                LOAD    R4, M[R6]
                INC     R6
                
                MVI     R5, 0100h
                SUB     R4, R4, R5
                
                INC     R3
                DEC     R2
                CMP     R2, R0           ;ir para o proximo caracter
                BR.NN   .altura
                INC     R1               ;se o cacto estiver todo desenhado
                BR      .cacto_atualiza   ;analizar o resto da tabela
                
.DES_DINO:      MVI     R1, Estado_Dino
                LOAD    R3, M[R1]
                MVI     R4, Cursor_Pes
                LOAD    R2, M[R4]  ;Cursor dos pés do dinossauro
                CMP     R3, R0
                BR.NZ   .SALTA_DESCE
                
.CONSTROI_DINO: MVI     R1, Dino_Tab              
                MVI     R5, 4    ;Contador do loop

.Dino_chao_loop: 
                LOAD    R3, M[R1]   ;Caracter ASCII do dinossauro
                MVI     R4, Term_cursor
                STOR    M[R4], R2           ;desenhar o dinossauro
                MVI     R4, Term_escreve
                STOR    M[R4], R3
                INC     R1
                DEC     R5
                MVI     R4, 0100h
                SUB     R2, R2, R4
                CMP     R5, R0
                BR.NZ   .Dino_chao_loop
                

.FIM_reset_cron: 
                LOAD    R5, M[R6]      ;Load registos 
                INC     R6 
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7
                
.SALTA_DESCE:   MVI     R5, 1    ;Ver se dino está a descer
                CMP     R3, R5
                BR.NZ   .DESCE
                
                MVI     R5, Altura_max  ;Ver se dino começa a descer
                CMP     R2, R5
                BR.Z    .START_DESCE
                
                ;'eliminar' o dino para o desenhar noutra posição
                DEC     R6          
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                MVI     R3, ' '     
                MVI     R4, Term_cursor
                STOR    M[R4], R2           ;desenhar o dinossauro
                MVI     R4, Term_escreve
                STOR    M[R4], R3
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                
                MVI     R5, 0100h
                SUB     R2, R2, R5
                STOR    M[R4], R2
                BR      .CONSTROI_DINO
                
.START_DESCE:   MVI     R3, -1
                STOR    M[R1], R3
                                
.DESCE:         MVI     R5, Cursor_Pes_Chao   ;Desenha o dino quando desce
                CMP     R2, R5
                BR.Z    .FICA_CHAO
                
                DEC     R6
                STOR    M[R6], R3
                DEC     R6
                STOR    M[R6], R4
                MVI     R3, 0300h
                DEC     R6
                STOR    M[R6], R2
                SUB     R2, R2, R3
                MVI     R3, ' '
                MVI     R4, Term_cursor
                STOR    M[R4], R2           ;desenhar o dinossauro
                MVI     R4, Term_escreve
                STOR    M[R4], R3
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6

                MVI     R5, 0100h
                ADD     R2, R2, R5
                STOR    M[R4], R2
                BR      .CONSTROI_DINO
                               
.FICA_CHAO:     MVI     R3, 0
                STOR    M[R1], R3 
                
                BR      .CONSTROI_DINO
;-------------------------------------------------------------------------------
;FUNCOES AUXILIARES INTERRUPCOES
;-------------------------------------------------------------------------------

Aux_Inicia_jogo:DEC     R6       ;Função auxiliar da Key0
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                 DEC     R6
                STOR    M[R6], R3
                 DEC     R6
                STOR    M[R6], R4
                 DEC     R6
                STOR    M[R6], R5
                
                MVI     R1, Disp7_0     ;Colocar o score a 0
                STOR    M[R1], R0
                MVI     R1, Disp7_1
                STOR    M[R1], R0
                MVI     R1, Disp7_2
                STOR    M[R1], R0
                MVI     R1, Disp7_3
                STOR    M[R1], R0
                
                MVI     R1, DISPLAY_0    ;Colocar o score a 0
                STOR    M[R1], R0
                MVI     R1, DISPLAY_1
                STOR    M[R1], R0
                MVI     R1, DISPLAY_2
                STOR    M[R1], R0
                MVI     R1, DISPLAY_3
                STOR    M[R1], R0
                
                
                MVI     R1, 1923h   ;R1 - Cursor da letra G
                MVI     R2, ' '
                MVI     R5, 9   ;R5 - Contador do loop para os 9 caracteres
                
.loop_del_game_over:
                MVI     R4, Term_cursor
                STOR    M[R4], R1
                MVI     R4, Term_escreve
                STOR    M[R4], R2          ;apagar as letras game over quando
                INC     R1                 ;começa o jogo
                DEC     R5
                CMP     R5, R0
                BR.NZ   .loop_del_game_over
                
                
                MVI     R1, Temp_Ativ   ;Iniciar cronómetro
                MVI     R2, Temp_Start
                STOR    M[R1], R2
                MVI     R1, Timer_tick
                STOR    M[R1], R0
                MVI     R1, Temp_Cont
                MVI     R2, Temp_Rate
                STOR    M[R1], R2

                
                MVI     R4, 80
                MVI     R2, 2600h             
.Chao_loop:     MVI     R1, Term_cursor    ;Desenhar o chão na linha 
                STOR    M[R1], R2
                MVI     R1, '_'
                MVI     R3, Term_escreve
                STOR    M[R3], R1
                INC     R2
                DEC     R4
                CMP     R4, R0
                BR.NZ   .Chao_loop
                
                MVI     R2, 250Ah    ;Posicão dos pés do dinossauro
                MVI     R1, Term_cursor
                STOR    M[R1], R2
                MVI     R1, '┴'
                MVI     R3, Term_escreve
                STOR    M[R3], R1
                
                MVI     R2, 2400h
                MVI     R1, Term_cursor
                
                
                MVI     R2, Estado_jogo ;Mudar variável para 1 de modo a
                                        ;começar o jogo
                MVI     R1, 1
                STOR    M[R2], R1
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7
                
Aux_Reset_Cron: DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                
                MVI     R1, Temp_Ativ   ;Reiniciar cronómetro
                MVI     R2, Temp_Start
                STOR    M[R1], R2
                
                MVI     R1, Timer_tick
                LOAD    R2, M[R1]
                INC     R2
                STOR    M[R1], R2
                
                MVI     R1, Temp_Cont
                MVI     R2, Temp_Rate
                STOR    M[R1], R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7
                
                
Salta_Dino:     DEC     R6       ;Função auxiliar da seta para cima
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R1, Estado_Dino ;Mudamos a variável de modo a sabermos
                MVI     R2, 1    ;que o dinossauro se encontra no ato de saltar
                STOR    M[R1], R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                JMP     R7
                
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                

                
Chamafuncao:    DEC     R6
                STOR    M[R6], R7
                MVI     R1, Estado_jogo
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    .Return_terreno
                
                MVI     R1, valorterreno    ;Atribuir os valores dos parâmetros
                MVI     R2, 80
                
                DEC     R6
                STOR    M[R6], R1           ;Guardar os argumentos na pilha 
                DEC     R6
                STOR    M[R6], R2
                
                JAL     atualizajogo
                
.Return_terreno: 
                LOAD    R7, M[R6]
                INC     R6
                ;Ir para a função atualizajogo
                JMP     R7   ;Programa que chama a função atualizajogo   
                
                
                
atualizajogo:   DEC     R6             ;guardar R4, R5
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5

                INC     R6
                INC     R6
                
                LOAD    R2, M[R6]
                INC     R6
                
                LOAD    R1, M[R6] ;Carregar os argumentos da função atualizajogo
                INC     R6
                
                DEC     R6
                DEC     R6
                DEC     R6          ;Colocar o StackPointer na primeira posição
                DEC     R6
                
                DEC     R2
                ADD     R4, R1, R2   ;Começar pelo fim/mais à direita da tabela 

                
.LoopTabela:    LOAD    R5, M[R4]        ;Percorrer todos os valores da tabela
                
                CMP     R4, R1
                BR.Z    .EliminarCacto   ;Se o valor mais à esquerda é um cacto
                CMP     R5, R0           ;Se nao for cacto passar para posição
                                         ;seguinte          
                BR.P    .Shiftcacto    ;Se for um cacto passá-lo para a esquerda
                DEC     R4  
                BR      .LoopTabela

.EliminarCacto: DEC     R6         ;Se a penúltima posição for 0, por a última
                MOV     R5, R0                      ;posição a 0
                STOR    M[R4], R5
                INC     R6
                BR      .Addireita     ;Ir adicionar o valor gerado na função
                                     ;geracacto
                
                
.LoopTabelaPt2: LOAD    R5, M[R6]
                INC     R6

                DEC     R4
                STOR    M[R4], R5    ;Passar o cacto para a direita    
                
                DEC     R4           ;Não "contamos" esta posição então passar
                                     ;à frente
                CMP     R4, R1
                BR.N    .Addireita    ;Ir adicionar o valor gerado na função
                                     ;geracacto
                BR      .LoopTabela


.Shiftcacto:    DEC     R6           ;Guardar a altura do cacto na pilha
                STOR    M[R6], R5
                
                MOV     R5, R0
                STOR    M[R4], R5   ;Posição atual do vetor passa a ser 0
                
                CMP     R1, R4
                BR.Z    .Addireita   
                BR      .LoopTabelaPt2


.Addireita:     ADD     R4, R1, R2   

                MVI     R1, 4            ; R1 = altura maxima
                MVI     R2, 1
                
                DEC     R6
                STOR    M[R6], R7
                JAL     geracacto        ;chamar a função geracacto para colocar
                LOAD    R7, M[R6]        ;na tabela
                INC     R6
                
                STOR    M[R4], R3        ;Adiciona o valor gerado por geracacto
                                         ;à direita na tabela
                
                LOAD    R5, M[R6]
                INC     R6                ;recuperar R4, R5
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7       
                
                                



                
geracacto:      DEC     R6             ;guardar parâmetros
                STOR    M[R6], R4
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R4, x
                LOAD    R5, M[R4]      ;R5 = X = 5
                
                AND     R4, R5, R2     ;R4 = bit = x & 1
                
                SHR     R5             ;x = x >> 1
                
                CMP     R4, R0         ;if bit
                BR.P    .if_bit
                
                
.probcacto:     MVI     R4, x          ;atualizar o valor de x na memoria
                STOR    M[R4], R5

                MVI     R4, const95

                SHR     R5
                CMP     R5, R4          ;if x < 29491
                BR.N    .return0
                
                MOV     R4, R1
                DEC     R4
                
                AND     R3, R5, R4       ;(x & (altura - 1))
                INC     R3               ; return (x & (altura - 1)) + 1
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                


.if_bit:        MVI     R4, constxor
                XOR     R5, R5, R4          ;x = XOR(X, 0xb400)
                
                BR      .probcacto



.return0:       MOV     R3, R0              ; return 0
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                
;-------------------------------------------------------------------------------
;INTERRUPCOES
;-------------------------------------------------------------------------------
                ORIG    7F00h   ;interrupção da Key0
                
                DEC     R6        ;Guardar endereço de retorno
                STOR    M[R6], R7
                
                JAL     Aux_Inicia_jogo
                
                LOAD    R7, M[R6]  ;Dar Load ao endereço de retorno
                INC     R6
                RTI
                
                
                ORIG    7F30h  ;interrupção da Seta para cima
                DEC     R6
                STOR    M[R6], R1    ;Guardar registos 
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R7
                
                MVI     R1, Estado_Dino
                LOAD    R2, M[R1]
                CMP     R2, R0
                
                JAL.Z   Salta_Dino
                
                LOAD    R7, M[R6]
                INC     R6
                LOAD    R2, M[R6]   ;Dar Load aos registos
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                RTI
                                
                ORIG    7FF0h   ;Interrupção do cronómetro
                
                DEC     R6     ;Guardar endereço de retorno
                STOR    M[R6], R7  
                
                JAL     Aux_Reset_Cron
                
                DEC     R6     ;Guardar endereço de retorno
                STOR    M[R6], R7
                
                JAL     Chamafuncao
                
                LOAD    R7, M[R6]
                INC     R6      ;Dar Load ao endereço de retorno
                RTI
                
                
                