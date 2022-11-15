.include "../include/bank_ids.inc"
; банк спрайтов Environment(часть 1)
.segment "ROM_2"	; Страница данных 
	.byte BANK_SPRITES_ENV_1_2_7	; номер страницы

	.WORD Environment_1
	.WORD Environment_2
	.WORD Environment_7
Environment_1:
.include "../../data/sprites/environment/environment_1.asm"
Environment_2:
.include "../../data/sprites/environment/environment_2.asm"
Environment_7:
.include "../../data/sprites/environment/environment_7.asm"
