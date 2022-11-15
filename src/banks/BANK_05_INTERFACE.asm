.include "../include/bank_ids.inc"

.segment "ROM_5"	; Страница данных 
	.byte BANK_SPRITES_INTERFACE	; номер страницы

	.WORD Interface_PC
	.WORD Copyright
	.WORD Palettes
Interface_PC:
  .include "../../data/sprites/interface/pc_interface.asm"
Interface_Copyright:
  .include "../../data/sprites/interface/copyright.asm"
  ; палитры из bank_01_palettes
Palettes:
  .include "../../data/palettes/bank_01_palettes.asm"
