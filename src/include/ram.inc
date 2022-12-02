; ****************************************
; * Экспорт/импорт глобальных переменных *
; ****************************************

; Экспорт/импорт из zero page надо делать через .globalzp
.globalzp arg0w
.globalzp arg1w
.globalzp arg2w
.globalzp arg3w

.globalzp arg0b
.globalzp arg1b
.globalzp arg2b
.globalzp arg3b
.globalzp arg4b
.globalzp arg5b
.globalzp arg6b
.globalzp arg7b

.globalzp keys1_is_down
.globalzp keys2_is_down

.globalzp far_jsr_page
.globalzp far_jsr_addr
.globalzp glob_temp0
.globalzp address_pointer	 		; Переиспользуемый адрес для загрузки данных
.globalzp data_pointer 	 		; Переиспользуемые данные которые мы читаем в данный момент
.globalzp vblank_counter

.globalzp tilemap_address_upleft	 		; Тайлмап верхнего левого угла
.globalzp tilemap_address_upright	 		; Тайлмап верхнего правого угла
.globalzp tilemap_address_downleft	 		; Тайлмап нижнего левого угла
.globalzp tilemap_address_downright 		; Тайлмап нижнего правого угла


; Экспорт/импорт из остальной памяти - .global
.global keys1_was_pressed
.global keys2_was_pressed
.global keys1_prev
.global keys2_prev

.global printed_text_length
.global current_symbol
.global text_offset_x
.global text_offset_y
.global text_box_x
.global text_box_y

.global scroll_x
.global scroll_y

; tilemap min range 
.global tilemap_min_x
.global tilemap_min_y
;  tilemap max range 
.global tilemap_max_x
.global tilemap_max_y

.global tilemap_orientation

; размер тайлмапа
.global tilemap_width
.global tilemap_height

.global sprite_bank
.global tilemap_bank
.global active_ppu_ctrl
.global active_ppu_mask
.global ppu_scroll_x
.global ppu_scroll_y
.global prev_ppu_scroll_x
.global prev_ppu_scroll_y

.global game_state
.global player_state_flags
.global generic_counter
.global selected_cheat

.global update_keys
.global warm_up
.global far_jsr
.global locate_in_vpage_proc