; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "include/neslib.inc"
; Подключаем заголовок библиотеки маппера MMC3
.include "include/mmc3.inc"

.segment "ROM_H"	; Сегмент кода в ПЗУ картриджа (страницы $C000-$FFFF)

.export enter_room_proc
; Процедура входа игрока в комнату
; портит 
; вход 
; arg0b - номер комнаты 
; arg1b - номер двери через которую входим 
.proc enter_room_proc
	
	rts
.endproc


