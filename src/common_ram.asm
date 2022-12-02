.include "include/neslib.inc"	; подключим заголовк neslib.inc


; ******************************
; * Сегмент игровых переменных *
; ******************************



; Сегмент нулевой страницы zero page (помечен явно через :zp).
.segment "ZPAGE": zp

.res 229                  ; Суммарный размер свободной памяти
                           ; Нужен чтобы ориентироваться сколько еще данных влезет

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
vblank_counter:	    .byte 0	; Счётчик прерываний VBlank

; Адреса тайлмапов для скроллинга
tilemap_address_upleft:  	.word 0	 		; Тайлмап верхнего левого угла
tilemap_address_upright:  	.word 0	 		; Тайлмап верхнего правого угла
tilemap_address_downleft:  	.word 0	 		; Тайлмап нижнего левого угла
tilemap_address_downright: 	.word 0	 		; Тайлмап нижнего правого угла



; Сегмент неинициализированных данных в RAM консоли.
; Все заданные здесь переменные и данные должны быть заполнены нулями
; иначе линкер будет ругаться на инициализированную переменную. 
; Однако во время запуска программы их содержимое неизвестно и будет 
; занулятся явным образом в процедуре warm_up.
; Описывает общие еременные, хранящие состояние игрока, текстов, ХП врагов и т.д.
; Максимальный размер - 380 байт
.segment "RAM"			
				
.res 349                   ; Суммарный размер свободной памяти
                           ; Нужен чтобы ориентироваться сколько еще данных влезет
; Кнопки нажатые на геймпадах во время предыдущего вызова update_keys.
keys1_prev:	.byte 0
keys2_prev:	.byte 0
; Кнопки которые не были нажаты на предыдущем вызове update_keys и оказавшиеся нажатыми на текущем.
keys1_was_pressed:		.byte 0
keys2_was_pressed:		.byte 0

printed_text_length:	.byte 0
current_symbol:         .byte 0

text_offset_x:          .byte 0
text_offset_y:          .byte 0
text_box_x:             .byte 0
text_box_y:             .byte 0

; tilemap scrolling values
scroll_x:               .byte 0
scroll_y:               .byte 0

; tilemap min range 
tilemap_min_x:       .byte 0
tilemap_min_y:       .byte 0
;  tilemap max range 
tilemap_max_x:       .byte 0
tilemap_max_y:       .byte 0

; tilemap sizes
tilemap_width:       .byte 0
tilemap_height:      .byte 0
; tilemap orientation enum
tilemap_orientation: .byte 0


; банки данных
sprite_bank:       .byte 0
tilemap_bank:      .byte 0

; флаги для PPU_CTRL/PPU_MASK для случаев когда хочется их сохранить/восстановить
active_ppu_ctrl:    .byte 0
active_ppu_mask:    .byte 0

; скроллинг для PPU
ppu_scroll_x:    .byte 0
ppu_scroll_y:    .byte 0
; скроллинг для PPU
prev_ppu_scroll_x:    .byte 0
prev_ppu_scroll_y:    .byte 0
; Глобальное состояние игры. Используется в игровой логике для переключения экранов
; и обновления игровой логики
game_state:         .byte 0

; Флаги состояния игрока
player_state_flags: .byte 0

; счетчик для общих целей
generic_counter :   .byte 0
; выбранный чит
selected_cheat  :   .byte 0



