; "Охранная" проверка на недопущение
; повторного ключения файла
.ifndef MACRO_INC_GUARD
MACRO_INC_GUARD		= 1		; Охранный символ

.include "macro_utils/addition.inc"
.include "macro_utils/branching.inc"
.include "macro_utils/division.inc"
.include "macro_utils/logic.inc"
.include "macro_utils/multiplication.inc"
.include "macro_utils/stack.inc"
.include "macro_utils/subtraction.inc"

; ********************
; * Полезные макросы *
; ********************

; store dest, src - сохранить байт в память
; чтобы избежать обильных многословных конструкций вида из:
;	lda значение
;	sta переменная	; переменная = значение
; которые заполняют переменные в памяти этот макрос
; позволяет записывать в одну строку:
;	store переменная, значение	; переменная = значение
; dest и src могут быть любыми аргументами инструкций lda/sta
; так что обратите внимание, что нужен префикс # для констант!
; портит аккумулятор!
.macro store dest, src
	lda src
	sta dest
.endmacro

; store dest, src - сохранить байт в память
; чтобы избежать обильных многословных конструкций вида из:
;	lda значение
;	sta переменная	; переменная = значение
; которые заполняют переменные в памяти этот макрос
; позволяет записывать в одну строку:
;	store переменная, значение	; переменная = значение
; dest и src могут быть любыми аргументами инструкций lda/sta
; так что обратите внимание, что нужен префикс # для констант!
; портит аккумулятор!
.macro store_2_values dest1, dest2,  src
	lda src
	sta dest1
	sta dest2
.endmacro

; store_addr dest, addr - сохранить адрес в слово в памяти
; чтобы избежать многословных конструкций вида:
;	lda # < addr	; загрузить lsb байт адреса
;	sta dest	; сохранить в начало слова
;	lda # > addr	; загрузить msb байт адреса
;	sta dest + 1	; сохранить в конец слова
; которые сохраняет адрес переменной в слово в памяти этот макрос
; позволяет записывать в одну строку:
;	store_addr переменная, адрес	; переменная = адрес
; dest и addr должны быть адресами в памяти
; портит аккумулятор!
.macro store_addr dest, addr
	lda # < (addr)
	sta dest
	lda # > (addr)
	sta dest + 1
.endmacro

; store_addr dest, addr - сохранить адрес в слово в памяти
; dest и addr должны быть адресами в памяти
; портит аккумулятор!
.macro store_const_addr dest, addr
	lda #.LOBYTE(addr)
	sta dest
	lda #.HIBYTE(addr)
	sta dest + 1
.endmacro

; store_word dest, word - сохранить слово в память.
; по сути то же самое что и store_addr, но название
; подчёркивает что сохраняется данное, а не адрес.
; портит аккумулятор!
.macro store_word dest, word
	lda # < (word)
	sta dest
	lda # > (word)
	sta dest + 1
.endmacro

; store_word dest, word - сохранить слово в память.
; портит аккумулятор!
.macro store_word_to_word dest, word
	store dest, word
	store dest+1, word+1	
.endmacro

; fill_ppu_addr - записать в PPU_ADDR адрес в VRAM
; чтобы избежать многословной конструкции (в теле макроса)
; можно записать в одну строку 
;	fill_ppu_addr адрес-в-vram
; vaddr должен быть адресом, переставлять нижний и верхний
; байты не нужно
; портит аккумулятор!
.macro fill_ppu_addr vaddr
	lda # > (vaddr)
	sta PPU_ADDR
	lda # < (vaddr)
	sta PPU_ADDR
.endmacro

; jump_if_keys1_is_down - перейти на метку label если в keys1_is_down
; зажжён хотя бы один бит в переданном сканкоде key_code.
; Т.е. можно передать несколько битовых паттернов кнопок 
; наложенных по OR и если хоть одна окажется нажата - перехода не будет.
; портит аккумулятор!
.macro jump_if_keys1_is_down key_code, label
	lda keys1_is_down
	and # key_code
	bne label
.endmacro

; jump_if_keys2_is_down - перейти на метку label если в keys2_is_down
; зажжён хотя бы один бит в переданном сканкоде key_code.
; портит аккумулятор!
.macro jump_if_keys2_is_down key_code, label
	lda keys2_is_down
	and # key_code
	bne label
.endmacro

; jump_if_keys1_is_not_down - перейти на метку label если в keys1_is_down
; не зажжён хотя бы один бит в переданном сканкоде key_code.
; Т.е. можно передать несколько битовых паттернов кнопок 
; наложенных по OR и если хоть одна окажется нажата - перехода не будет.
; портит аккумулятор!
.macro jump_if_keys1_is_not_down key_code, label
	lda keys1_is_down
	and # key_code
	beq label
.endmacro

; jump_if_keys2_is_not_down - перейти на метку label если в keys2_is_down
; не зажжён хотя бы один бит в переданном сканкоде key_code.
; портит аккумулятор!
.macro jump_if_keys2_is_not_down key_code, label
	lda keys2_is_down
	and # key_code
	beq label
.endmacro

; jump_if_keys1_was_not_pressed - перейти на метку label если в keys1_was_pressed
; не зажжён хотя бы один бит в переданном сканкоде key_code.
.macro jump_if_keys1_was_not_pressed key_code, label
	lda keys1_was_pressed
	and # key_code
	beq label
.endmacro

; jump_if_keys1_was_pressed - перейти на метку label если в keys1_was_pressed
; зажжён хотя бы один бит в переданном сканкоде key_code.
.macro jump_if_keys1_was_pressed key_code, label
	lda keys1_was_pressed
	and # key_code
	bne label
.endmacro
; jump_if_keys2_was_not_pressed - перейти на метку label если в keys2_was_pressed
; не зажжён хотя бы один бит в переданном сканкоде key_code.
.macro jump_if_keys2_was_not_pressed key_code, label
	lda keys2_was_pressed
	and # key_code
	beq label
.endmacro

; locate_in_vpage - выставить в PPU_ADDR адрес байта в 
; указанной странице page на координаты тайла (cx, cy)
;   page - PPU_SCR0 или PPU_SCR1
;   cx - от 0 до 31
;   cy - от 0 до 29
; портит аккумулятор!
; Заметьте, что параметры заключаются в скобки потому что иначе при 
; подстановке сложных выражений они могли бы неправильно развернуться.
.macro	locate_in_vpage page, cx, cy
	fill_ppu_addr (page) + (cx) + ((cy) * 32)
.endmacro

; poke_vpage - записать байт value по координатам (cx, cy) 
; в указанной странице page.
; портит аккумулятор!
.macro	poke_vpage page, cx, cy, value
	locate_in_vpage page, cx, cy
	store PPU_DATA, value
.endmacro

; fill_vpage_line - записать байт value times раз начиная с
; координат (cx, cy) в указанной странице page. 
; times не может быть больше 255!
; портит: A, X
.macro	fill_vpage_line page, cx, cy, times, value
	.local mloop
	locate_in_vpage page, cx, cy
	lda value
	ldx times
mloop:	sta PPU_DATA
	dex
	bne mloop
.endmacro

; fill_page_by - заливает все байты тайлов страницы page байтом value
; не затрагивает область атрибутов.
; портит: A, X
.macro	fill_page_by page, value
	.local mloop
	fill_ppu_addr page
	ldx # 32 * 30 / 4
	lda value
mloop:	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	dex
	bne mloop
.endmacro

.macro clear_background_table 
	.local mloopx
	.local mloopy
	
	lda PPU_STATUS
	fill_ppu_addr PPU_BGR_TBL
	ldy #$10
	lda #00
mloopy:	
	ldx # $FF

mloopx:	
	sta PPU_DATA
	dex
	bne mloopx
	dey
	bne mloopy
.endmacro

; set_sprite - установить все поля спрайта
.macro	set_sprite num, cx, cy, tile, attr
	store SPR_FLD_X( num ), cx
	store SPR_FLD_Y( num ), cy
	store SPR_FLD_TILE( num ), tile
	store SPR_FLD_ATTR( num ), attr
.endmacro

; set_far_dest - макрос выставления страницы и адреса для межстраничного перехода
.macro set_far_dest ppage, paddr
	store		far_jsr_page, ppage	; сохраним страницу
	store_addr	far_jsr_addr, paddr	; сохраним адрес
.endmacro

; load_data - загружает данные по адресу from в память to
; Портит A, Y
.macro load_data from, to
	ldy #00
	lda (from), y		
	sta to
	iny
	lda (from), y
	sta to + 1
.endmacro

.endif
