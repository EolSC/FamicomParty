.include "../include/bank_ids.inc"
; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "../include/neslib.inc"

.segment "ROM_3C"	; Страница кода $3C (8Кб из 64 ROM картриджа) для адреса $A000
	.byte BANK_PRG_TEXT_ENGINE	; номер страницы



.export print_string
.export clear_text_area
.export load_letters_sprites
.export load_from_table
.export load_sprite_from_table
; print_string - процедура вывода строки с текстом по адресу arg1w на экран
; координаты вывода текста в (arg1b, arg0b)
; портит A, X, Y, arg0w, arg1w, arg6b, arg7b
.proc print_string
	store arg6b, arg1b ; координата x во времянку
	store arg7b, arg0b ; координата y во времянку
	ldy #0			; Обнуляем Y
	ldx printed_text_length
write_string:
	jsr locate_in_vpage_proc ; Находим координаты тайла (X, Y) в видеопамяти
fill_loop:
	lda (address_pointer), y	; Загружаем A из адреса (arg1w+Y)
	beq text_end	; если загруженный байт нулевой - идём на выход
	cmp #NEWLINE	; если встречаем символ NEWLINE 
	beq newline_sym ; переходим на новую строку
	sta PPU_DATA	; иначе сохраняем его в VRAM
	dex
	beq end
	iny				; инкрементируем Y
	jmp fill_loop	; и возвращаемся в цикл
newline_sym:
	iny
next_string:
	txa
	ldx arg7b		; Y для текущей строки
	inx 			; вниз на 2 строки
	inx
	stx arg7b		; инициализируем Y-координату строки arg7b и arg1b
	stx arg0b
	ldx arg6b		; и X-координату в arg0b
	stx arg1b
	tax
	jmp write_string ; и печатаем следующую строку
text_end:				; если напечатан весь текст - увеличим счетчик чтобы
	ldx #MAX_TEXT_SIZE	; можно было его скипнуть
	stx printed_text_length

end:	
	rts		; возврат из процедуры
.endproc	

; clear_text_area - процедура очистки текстовой области
; портит A, X, arg0w, arg1w
.proc clear_text_area
	ldx #TEXT_AREA_SIZE
	jsr locate_in_vpage_proc ; Находим координаты тайла (arg1b, arg0b) в видеопамяти
	lda #EMPTY_SYMBOL		; заполняем пробелами
fill_loop:
	sta PPU_DATA	; иначе сохраняем его в VRAM
	dex
	beq end
	jmp fill_loop	; и возвращаемся в цикл
end:	
	rts		; возврат из процедуры
.endproc	

; load_data_to_ppu -процедура загрузки данных в PPU
; портит A, Y, 
; вход :
; address_pointer - адрес с которого грузим данные
; arg0b - размер загружаемых данных в блоках по 16 байт
; arg1w - адрес в PPU по которому мы кладем данные
.proc load_data_to_ppu
   ;настраиваем адрес с которого копируем

   ;устанавливаем адрес в который пишем данные в PPU
   ldy #01
   ldx arg1w, Y
   stx PPU_ADDR
   dey
   ldx arg1w, Y 
   stx PPU_ADDR

   ;подготавливаем копирование в цикле
   ldx arg0b

CopyTile:

   ;подготовка к передаче байта данных
   ldy #$00

CopyByte:

   ;копируем 1 байт и перемещаемся к следующему
   lda (address_pointer), y
   sta PPU_DATA
   iny

   ;возвращаемся в CopyByte если не дошли до конца блока
   cpy #DATA_BLOCK_SIZE
   bne CopyByte

   ;обновляем счетчик, выходим если блок скопирован
   dex
   beq Done

   ;переход к следующему блоку
   clc
   lda address_pointer+0
   adc #DATA_BLOCK_SIZE	; увеличиваем адрес на размер блока
   sta address_pointer+0
   bcc CopyTile
   inc address_pointer+1
   bcs CopyTile

Done:
	rts
.endproc

; загружает спрайты текста в PPU
; портит A
.proc load_letters_sprites
	; адрес блока спрайтов
	lda #.LOBYTE(LETTERS_START)
	sta address_pointer
	lda #.HIBYTE(LETTERS_START)
	sta address_pointer + 1
	; Адрес для спрайтов текста в PPU. См. game_constants.inc
	lda #.LOBYTE(TEXT_SPRITES_ADDRESS_IN_PPU)
	sta arg1w
	lda #.HIBYTE(TEXT_SPRITES_ADDRESS_IN_PPU)
	sta arg1w + 1
	; Размер блока спрайтов
	lda #.LOBYTE(LETTERS_SIZE)
	sta arg0b
	jsr load_data_to_ppu 
	rts
.endproc

; load_from_table - загружает данные из таблицы по смещению
; портит A, X, Y
; вход :
; address_pointer - адрес с которого грузим данные
; arg0b - смещение в словах от стартового адреса
; выход:
; data_pointer - указатель на адрес данных в которых лежат нужные данные
.proc load_from_table
	lda arg0b
	MULT_A_BY_2 ; умножаем адрес * 2 чтобы получить смещение в байтах
	tay
	lda (address_pointer), y
	sta data_pointer
	iny
	lda (address_pointer), y
	sta data_pointer + 1
	rts
.endproc 

; load_intro_image - загружает спрайты интро в видеопамять
; портит A, X, Y
; вход :
; address_pointer - адрес таблицы спрайтов
; arg0b - номер изображения 
; arg1w - адрес в PPU
.proc load_sprite_from_table
	jsr load_from_table
	; запоминаем данные в address_pointer
	store_word_to_word address_pointer, data_pointer	
	; читаем размер в начале
	ldy #00
	lda (address_pointer), Y
	; запоминаем размер в arg0b
	sta arg0b
	; пропускаем 2 байта размера в начале спрайта
	inc address_pointer
	inc address_pointer
	jsr load_data_to_ppu
	rts
.endproc

