.include "../include/bank_ids.inc"
; Банк для текстов игры
.segment "ROM_0"			; Страница данных
	.byte BANK_DATA_TEXT	; Первый байт - номер страницы
Text_table: 			; метка начала таблицы текстов	
							; Далее идут адреса текстов
	.word Text_screen1	 
	.word Text_screen2
	.word Text_screen3
	.word Text_screen4
	.word Text_screen5

; Экран 1	
.export Text_table
; Специальные символы в текста
; $A - новая линия
; 0 - завершающий 0
; текст интро
; Экран 1	

Text_screen1:
	.byte "July 1998, Raccoon city", 0	
Text_screen2:
	.byte "Alpha team is flying over ",$A,"the northwest part of", $A,"racoon forest.", 0	
Text_screen3:
	.byte "Our mission is to find", $A, "the missing bravo team.", 0	
Text_screen4:
	.byte "Did you find them?", 0	
Text_screen5:
	.byte "No, not yet.", 0	

; Экран 2	
Text_screen6:
	.byte "There have been several murders recently.", 0		
Text_screen7:
	.byte "Many killed by unknown monsters.", 0	
Text_screen8:
	.byte "Bravo team was unaware of this when they came to investigate.", 0	
; Экран 3	
Text_screen9:
	.byte "Chris, look!", 0	
Text_screen10:
	.byte "There's no one in Bravo team's helicopter.", 0	
Text_screen11:
	.byte "It's strange that their equipment is still here.", 0	
Text_screen12:
	.byte "But we soon knew why.", 0	
; Экран 4
Text_screen13:
	.byte "Hey! Come here, Joseph.", 0	
Text_screen14:
	.byte "No, don't go.", 0	
Text_screen15:
	.byte "Jill, get in the house!", 0		
Text_screen16:
	.byte "They fled into the house where they thought it would be safe.", 0	
Text_screen17:
	.byte "But...", 0


