.include "../include/bank_ids.inc"

.segment "ROM_3"	; Страница данных 
	.byte BANK_SPRITES_ENV_3_4_5	; номер страницы
Environment_Table2:		
	.WORD Environment_3
	.WORD Environment_4
	.WORD Environment_5
Environment_3:
.include "../../data/sprites/environment/environment_3.asm"
Environment_4:
.include "../../data/sprites/environment/environment_4.asm"
Environment_5:
.include "../../data/sprites/environment/environment_5.asm"
