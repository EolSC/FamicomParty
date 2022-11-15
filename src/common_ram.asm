.include "include/neslib.inc"	; подключим заголовк neslib.inc

; Сегмент нулевой страницы zero page (помечен явно через :zp).
.segment "ZPAGE": zp

; Временные переменные и параметры в zero page общим объёмом 8 байт.
; Если процедуры используют их как входные параметры или портят, то 
; это следует описать в комментариях.
; Четыре двухбайтовых слова или адреса...
arg0w:		.word 0
arg1w:		.word 0
arg2w:		.word 0
arg3w:		.word 0
; ...и восемь байт, которые занимают места в соответсвующих словах по порядку,
; т.е., например, arg2w и arg4b/arg5b занимают одно и то же место в zero page.
arg0b		= arg0w + 0
arg1b		= arg0w + 1
arg2b		= arg1w + 0
arg3b		= arg1w + 1
arg4b		= arg2w + 0
arg5b		= arg2w + 1
arg6b		= arg3w + 0
arg7b		= arg3w + 1

; Текущие нажатые на геймпадах кнопки (на момент последнего вызова update_keys).
keys1_is_down:	.byte 0
keys2_is_down:	.byte 0

far_jsr_page:	.byte 0	; Страница на которую надо перейти межстраничным переходом
far_jsr_addr:	.word 0	; Адрес на который надо перейти межстраничным переходом

glob_temp0:			.byte 0			; Байт ультравременных данных в zero-page
address_pointer:  	.word 0	 		; Переиспользуемый адрес для загрузки данных
data_pointer: 	 	.word 0	 		; Переиспользуемые данные которые мы читаем в данный момент

; Сегмент неинициализированных данных в RAM консоли.
; Все заданные здесь переменные и данные должны быть заполнены нулями
; иначе линкер будет ругаться на инициализированную переменную. 
; Однако во время запуска программы их содержимое неизвестно и будет 
; занулятся явным образом в процедуре warm_up.
.segment "RAM"			
				
; Кнопки нажатые на геймпадах во время предыдущего вызова update_keys.
keys1_prev:	.byte 0
keys2_prev:	.byte 0
; Кнопки которые не были нажаты на предыдущем вызове update_keys и оказавшиеся нажатыми на текущем.
keys1_was_pressed:		.byte 0
keys2_was_pressed:		.byte 0
printed_text_length:	.byte 0