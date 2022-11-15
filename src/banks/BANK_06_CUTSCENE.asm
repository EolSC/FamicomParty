.include "../include/bank_ids.inc"

.segment "ROM_6"	; Страница данных 
	.byte BANK_SPRITES_CUTSCENE	; номер страницы
Cutscene_Table:

	.WORD Cutscene01
	.WORD Cutscene02
	.WORD Cutscene03
	.WORD Cutscene04
;	.WORD CutsceneEnding

Cutscene01:
  .include "../../data/sprites/cutscene/cutscene_01.asm"
Cutscene02:
  .include "../../data/sprites/cutscene/cutscene_02.asm"
Cutscene03:
  .include "../../data/sprites/cutscene/cutscene_03.asm"
Cutscene04:
  .include "../../data/sprites/cutscene/cutscene_04.asm"
;CutsceneEnding:
;  .include "../../data/sprites/cutscene/cutscene_ending.asm"


.export Cutscene_Table