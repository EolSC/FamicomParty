.include "../include/bank_ids.inc"

.segment "ROM_7"	; Страница данных 
	.byte BANK_SPRITES_TITLE	; номер страницы
Title_Table:
	.WORD Title_Logo
	.WORD Title_SaveScreen

Title_Logo:
  .include "../../data/sprites/interface/title_logo.asm"
Title_SaveScreen:
  .include "../../data/sprites/interface/save_screen.asm"


.global Title_Table