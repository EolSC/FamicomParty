.include "../include/bank_ids.inc"

.segment "ROM_4"	; Страница данных
	.byte BANK_SPRITES_ENV_6_8	; номер страницы

	.WORD Environment_6
	.WORD Environment_8
Environment_6:
.include "../../data/sprites/environment/environment_6.asm"
Environment_8:
.include "../../data/sprites/environment/environment_6.asm"



