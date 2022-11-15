.include "../include/bank_ids.inc"
; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "../include/neslib.inc"

.segment "ROM_3E"	; Страница кода $3E (8Кб из 64 ROM картриджа) для адреса $A000
	.byte BANK_PRG_2	; номер страницы

