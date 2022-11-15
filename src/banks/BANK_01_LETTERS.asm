.include "../include/bank_ids.inc"
.segment "ROM_1"	; Страница данных
	.byte BANK_SPRITES_LETTERS	; номер страницы

LettersStart:
.incbin "../sprites/letters.chr"
LettersEnd:

.export LettersStart
.export LettersEnd
