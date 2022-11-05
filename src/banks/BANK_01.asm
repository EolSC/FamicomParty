.segment "ROM_1"	; Страница данных 1 (вторые 8Кб из 64 ROM картриджа) для адреса $8000
	.byte $01	; номер страницы
	.byte "And this is text from second one", 0	; Строка текста