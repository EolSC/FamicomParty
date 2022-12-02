.include "../include/bank_ids.inc"

.segment "ROM_5"	; Страница данных 
	.byte BANK_SPRITES_INTERFACE	; номер страницы
Interface_Table:
	.WORD Interface_PC
	.WORD Copyright
Interface_PC:
 ; .include "../../data/sprites/interface/pc_interface.asm"
Interface_Copyright:
  .include "../../data/sprites/interface/copyright.asm"

  

.global Interface_Table