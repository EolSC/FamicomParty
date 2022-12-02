.include "../include/bank_ids.inc"
; Банк для текстов игры
.segment "ROM_0"			; Страница данных
	.byte BANK_DATA_TEXT	; Первый байт - номер страницы
Text_table: 			; метка начала таблицы текстов	
							; Далее идут адреса текстов
	.word Text_screen1	 
	.word Text_screen2
	.word Text_screen3
	.word Text_screen3_2
	.word Text_screen4
	.word Text_screen5
	.word Text_screen6
	.word Text_screen7
	.word Text_screen8
	.word Text_screen9
	.word Text_screen10
	.word Text_screen11
	.word Text_screen12
	.word Text_screen13
	.word Text_screen14
	.word Text_screen15
	.word Text_screen16
	.word Text_screen17
	.word Text_screen18
	.word Text_screen19
	.word Text_screen20
	.word Text_screen21
	.word Intro_text1
	.word Intro_text2
	.word Intro_text3
	.word Intro_text4
	.word Intro_text5
	.word Intro_text6
	.word Intro_text7
	.word Intro_text8
	.word Intro_text9
	.word Intro_text10
	.word Intro_text11
	.word Intro_text12





; Экран 1	
.export Text_table
; Специальные символы в текста
; $A - новая линия
; 0 - завершающий 0

; *********************************
; *  Катсцены перед главным меню  *
; *********************************
; Экран 1	
Text_screen1:
	.byte "July 1998, Raccoon forest.", 0	
Text_screen2:
	.byte "Alpha team is flying around",$A,"the forest zone situated", $A,"in the northwest", $A,"Raccoon city.", 0	
Text_screen3:
	.byte "We were searching for the", $A, "the helicopter of our", $A, "compatriots Bravo team.", 0
Text_screen3_2:
	.byte "who disappeared", $A,"during the middle of", $A,"our mission.", 0	
Text_screen4:
	.byte "Chris:",$A,"- Did you find it?", 0	
Text_screen5:
	.byte "Joseph:",$A,"- No, I haven't",$A,"found it yet.", 0	

; Экран 2	
Text_screen6:
	.byte "Bizzare murder cases", $A, "have recently occured", $A, "in Raccoon city.", 0		
Text_screen7:
	.byte "There are outlandish", $A, "reports of families", $A, "being attacked by a group", $A, "of about 10 people.", 0	
Text_screen8:
	.byte "Victums were apperently", $A, "eaten.", 0	
Text_screen9:
	.byte "Bravo team went to the", $A, "hideout of the group", $A, "and disappeared.", 0	

; Экран 3	
Text_screen10:
	.byte "Jill:", $A,"- Look, Chris!", 0	
Text_screen11:
	.byte "It was Bravo", $A, "team's helicopter.", $A, "Nobody was in it.", 0	
Text_screen12:
	.byte "But strangely most of", $A, "the equipment was", $A, "still there.", 0	
Text_screen13:
	.byte "However, we soon", $A, "discovered why...", 0	

; Экран 4
Text_screen14:
	.byte "Joseph:",$A,"- Hey! Come here!", 0	
Text_screen15:
	.byte "Joseph:",$A,"- Aaargh!", 0	
Text_screen16:
	.byte "Jill:",$A,"- Joseph!", 0
Text_screen17:
	.byte "Chris:",$A,"- No, don't go!", 0
Text_screen18:
	.byte "Chris:",$A,"- Jill, run for that house!", 0
Text_screen19:
	.byte "They have escaped",$A,"into the mansion",0
Text_screen20:
	.byte "where they thought",$A,"it would be safe.",0
Text_screen21:
	.byte "Yet...", 0

; *********************************
; *  Интро-сценка в особняке *
; *********************************

Intro_text1:
	.byte "Barry: - What is this?", 0
Intro_text2:
	.byte "Wesker: - Wow! What a mansion!", 0
Intro_text3:
	.byte "Jill: - Captain Whesker, where is Chris?", 0
Intro_text4:
	.byte "Wesker: - Stop it! Don't open that door!", 0
Intro_text5:
	.byte "Jill: - But Chris is...", 0
Intro_text6:
	.byte "*Gunshot fired*", 0
Intro_text7:
	.byte "Barry: - What is it?", 0
Intro_text8:
	.byte "Wesker: - May be it's Chris", 0
Intro_text9:
	.byte "Wesker: - Now Jill can you go?", 0
Intro_text10:
	.byte "Barry: - I'm going with you", 0
Intro_text11:
	.byte "Barry: - Chris is our old partner", 0
Intro_text12:
	.byte "Wesker: - Ok, but stay alert!", 0




