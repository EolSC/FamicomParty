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
.globalzp  address_pointer	 		; Переиспользуемый адрес для загрузки данных
.globalzp  data_pointer 	 		; Переиспользуемые данные которые мы читаем в данный момент


; Экспорт/импорт из остальной памяти - .global
.global keys1_was_pressed
.global keys2_was_pressed
.global printed_text_length

.global update_keys
.global warm_up
.global far_jsr
.global locate_in_vpage_proc