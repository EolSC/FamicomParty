.include "../include/bank_ids.inc"

.segment "ROM_12"	; Страница данных 
	.byte BANK_ROOMDATA	; номер страницы

; данные о комнатах. см. описание формата в docs/rooms/format.txt
Roomdata_Table:
	.WORD Room_Hall
Room_Hall:
.include "../../data/rooms/hall.asm"
 
.global Roomdata_Table

