; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "include/neslib.inc"
.include "include/mmc3.inc"
.segment "ROM_H"	


.export reset_string
.export print_char
.export clear_text_area
.export load_letters_sprites
.export load_from_table
.export load_sprite_from_table
.export load_tilemap
.export load_tilemap_attributes
.export load_tilemap_from_table
.export load_tilemap_attributes_from_table
.export update_nametable_scrolling

; reset_string - процедура вывода строки с текстом по адресу arg1w на экран
; портит A
; Выводит строку посимвольно. Эта процедура подготавливает строку к печати, 
; для печати нужно вызывать print_char
; вход 
; arg1b - координата X текста
; arg0b - координата Y текста

.proc reset_string
	store text_box_x, arg1b
	store text_box_y, arg0b
	store text_offset_x, arg1b
	store text_offset_y, arg0b

	lda #00
	sta current_symbol
	sta printed_text_length	

	rts
.endproc
; print_char - процедура вывода строки с текстом по адресу arg1w на экран
; координаты вывода текста в (arg1b, arg0b)
; портит A, X, Y, arg0w, arg1w, arg6b, arg7b
.proc print_char
	lda current_symbol			
	cmp printed_text_length
	bcs end
	inc current_symbol
	tay
write_char:
	store arg1b, text_offset_x
	store arg0b, text_offset_y
	jsr locate_in_vpage_proc ; Находим координаты тайла (X, Y) в видеопамяти
	lda (address_pointer), y	; Загружаем A из адреса (arg1w+Y)
	beq text_end	; если загруженный байт нулевой - идём на выход
	cmp #NEWLINE	; если встречаем символ NEWLINE 
	beq newline_sym ; переходим на новую строку
	clc
	adc #ASCII_TO_SPRITE_OFFSET		; добавляем смещение к коду символа
	sta PPU_DATA	; иначе сохраняем его в VRAM
	inc text_offset_x
	jmp end
newline_sym:

	ldy text_offset_y		; Y для текущей строки
	iny 					; вниз на 2 строки
	iny
	sty text_offset_y		
	store text_offset_x, text_box_x	; возврат по X
	jmp end
text_end:				; если напечатан весь текст - увеличим счетчик чтобы
	ldx #MAX_TEXT_SIZE	; можно было его скипнуть
	stx printed_text_length
	stx current_symbol
end:	
	rts		; возврат из процедуры
.endproc	

; clear_text_area - процедура очистки текстовой области
; портит A, X, arg0w, arg1w
.proc clear_text_area
	ldx #TEXT_AREA_SIZE
	jsr locate_in_vpage_proc ; Находим координаты тайла (arg1b, arg0b) в видеопамяти
	lda #EMPTY_TEXT_SPRITE		; заполняем пробелами
fill_loop:
	sta PPU_DATA	; иначе сохраняем его в VRAM
	dex
	beq end
	jmp fill_loop	; и возвращаемся в цикл
end:	
	rts		; возврат из процедуры
.endproc	

; load_data_to_ppu -процедура загрузки данных в PPU
; портит A, X, Y, 
; вход :
; address_pointer - адрес с которого грузим данные
; arg0b - размер загружаемых данных в блоках 
; arg1b - размер блока в байтах
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
   cpy arg1b
   bne CopyByte

   ;обновляем счетчик, выходим если блок скопирован
   dex
   beq Done

   ;переход к следующему блоку
   clc
   lda address_pointer+0
   adc arg1b				; увеличиваем адрес на размер блока
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
	lda #DATA_BLOCK_SIZE
	sta arg1b
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

; load_sprite_from_table - загружает спрайты интро в видеопамять
; портит A, X, Y
; вход :
; address_pointer - адрес таблицы спрайтов
; arg0b - номер изображения 
; arg1w - адрес в PPU
; sprite_bank - банк из которого грузим спрайты
.proc load_sprite_from_table
	mmc3_set_bank_page # MMC3_PRG_H0, sprite_bank	; В банке данных выберем страницу спрайтов
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

	lda #DATA_BLOCK_SIZE
	sta arg1b	
	jsr load_data_to_ppu
	rts
.endproc

; read_tilemap_chunk - загружает тайлмап с учетом смещения
; портит A, Y, arg0w, arg1w, address_pointer
; вход :
; arg1w - адрес по которому кладем данные в PPU
; address_pointer - адрес с которого мы читаем тайлмап
; tilemap_min_x - смещение относительно начала тайлмапа в байтах по Y
; tilemap_min_y - смещение относительно начала тайлмапа в байтах по X
; tilemap_width  - размер читаемого куска тайлмапа по X
; tilemap_height - размер читаемого куска тайлмапа по Y
; tilemap_orientation - какой квадрант экрана занимает тайл
.proc read_tilemap_chunk
	ldy tilemap_min_y ; кладем tilemap_min_y в Y
	beq add_offset_x
add_offset_y:
	ADD_BYTE_TO_WORD address_pointer, tilemap_width
	dey
	bne add_offset_y
add_offset_x:	
	lda tilemap_orientation
	and #$01			; смотрим на нижний бит ориентации
	bne load_to_ppu		; для четной ориентации(левой) - прибавляем оффсет перед загрузкой в PPU(Левая сторона грузится со смещением слева)
	ADD_BYTE_TO_WORD address_pointer, tilemap_min_x ; смещаем данные на tilemap_min_x
	ADD_BYTE_TO_WORD arg1w, tilemap_min_x				; увеличиваем адрес в PPU на tilemap_min_x
load_to_ppu:	
	lda tilemap_width ; размер блока - tilemap_width
	sta arg1b
	lda #1
	sta arg0b 		 ; копируем 1 такой блок
	jsr load_data_to_ppu	; и грузим строку тайлмапа в память
	ADD_BYTE_TO_WORD address_pointer, tilemap_width				; увеличиваем адрес на tilemap_width
	ADD_BYTE_TO_WORD arg1w, tilemap_width				; увеличиваем адрес в PPU на tilemap_width
	lda tilemap_orientation
	and #$01			; смотрим на нижний бит ориентации
	beq next_step
	ADD_BYTE_TO_WORD address_pointer, tilemap_min_x ; для нечетной ориентации смещаем данные на tilemap_offset_x
	ADD_BYTE_TO_WORD arg1w, tilemap_min_x				; увеличиваем адрес в PPU на tilemap_min_x
next_step:	
	dec tilemap_height											; цикл по количеству строк
	bne add_offset_x
	rts
.endproc

; calc_scroll_tilemap - вычисляет скроллинг в спрайтах бекграунда
; портит A, 
.proc calc_scroll_tilemap
	DIV_A_BY_8_ADDR ppu_scroll_x
	sta tilemap_min_x
	DIV_A_BY_8_ADDR ppu_scroll_y
	sta tilemap_min_y
	rts
.endproc
; calc_scroll_tilemap_attributes - вычисляет скроллинг для таблицы аттрибутов
; портит A, 

.proc calc_scroll_tilemap_attributes
	lda ppu_scroll_x
	DIV_A_BY_32 
	sta tilemap_min_x
	lda ppu_scroll_y
	DIV_A_BY_32 
	sta tilemap_min_y
	rts
.endproc

; calc_tilemap_size - calculate sizes of tilemap dimensions in range (tilemap_min, tilemap_max)
; Corrupts A, 
; Input :
; tilemap_max_x - max value of tilemap width
; tilemap_max_y - max value of tilemap height
; tilemap_min_x - min value of tilemap width
; tilemap_min_y - min value of tilemap height
; Output
; tilemap_width  - tilemap size x
; tilemap_height - tilemap size y
.proc calc_tilemap_size
	lda tilemap_max_x
	SUB_A_SEC tilemap_min_x
	sta tilemap_width
	lda tilemap_max_y
	SUB_A_SEC tilemap_min_y
	sta tilemap_height
	rts
.endproc

; load_tilemap - загружает тайлмап с учетом смещения
; портит A, X, Y, arg0w, arg1w
; вход :
; address_pointer - адрес таблицы тайлмапов
; arg0b - номер тайлмапа в таблице
; scroll_x - скроллинг по X
; scroll_y - скроллинг по Y
.proc load_tilemap_from_table
	jsr load_from_table
	; теперь у нас в address_pointer - тайлмап
	store_word_to_word address_pointer, data_pointer
	jsr load_tilemap
	rts
.endproc

; load_tilemap - загружает тайлмап с учетом смещения
; портит A, X, Y, arg0w, arg1w
; вход :
; address_pointer - адрес тайлмапа
; arg1w - адрес по которому нужно записать тайлмап в PPU
; scroll_x - скроллинг по X
; scroll_y - скроллинг по Y
.proc load_tilemap
	jsr calc_scroll_tilemap
	jsr calc_tilemap_size
	; данные подготовлены, грузим их в PPU
	jsr read_tilemap_chunk
	rts
.endproc

; load_tilemap_attributes_from_table - загружает тайлмап с учетом смещения
; портит A, X, Y, arg0w, arg1w
; вход :
; address_pointer - адрес таблицы тайлмапов
; arg0b - номер тайлмапа в таблице
; arg1w - адрес по которому нужно записать тайлмап в PPU
; scroll_x - скроллинг по X
; scroll_y - скроллинг по Y
.proc load_tilemap_attributes_from_table
	jsr load_from_table
	; теперь у нас в address_pointer - тайлмап
	store_word_to_word address_pointer, data_pointer
	jsr load_tilemap_attributes
	rts
.endproc

; load_tilemap_attributes - загружает тайлмап с учетом смещения
; портит A, X, Y, arg0w, arg1w
; вход :
; address_pointer - адрес таблицы тайлмапов
; arg0b - номер тайлмапа в таблице
; arg1w - адрес по которому нужно записать тайлмап в PPU
; scroll_x - скроллинг по X
; scroll_y - скроллинг по Y
.proc load_tilemap_attributes
	jsr calc_scroll_tilemap_attributes
	jsr calc_tilemap_size
	ADD_WORD_TO_WORD_IMM address_pointer, PPU_ATTR_OFFSET
	; данные подготовлены, грузим их в PPU
	jsr read_tilemap_chunk
	rts
.endproc

; процедура обновления скроллинга
; портит A,X,Y, address_pointer
; вход:
; tilemap_address_upleft:  		адрес тайлмапа верхнего левого угла
; tilemap_address_upright:  	адрес тайлмапа верхнего правого угла
; tilemap_address_downleft: 	адрес тайлмапа нижнего левого угла
; tilemap_address_downright:  	адрес тайлмапа нижнего правого угла
; ppu_scroll_x, ppu_scroll_y ; скроллинг для PPU. Обновляет дельту между prev_ppu_scroll и ppu_scroll
; prev_ppu_scroll_x, prev_ppu_scroll_y ; предыдущие значения скроллинга

.proc update_nametable_scrolling


	store tilemap_max_x, ppu_scroll_x 	; We must only update new tiles in range between
	store tilemap_max_y, ppu_scroll_y	; ppu_scroll and prev_ppu_scroll

	store tilemap_min_x, prev_ppu_scroll_x
	store tilemap_min_y, prev_ppu_scroll_y

	lda ppu_scroll_y
	SUB_A_SEC prev_ppu_scroll_y ; if prev_ppu_scroll_y == ppu_scroll_y - jumping to
	beq update_downleft_corner  ; x scrolling logic

update_upleft_corner:
	store tilemap_orientation, #TILEMAP_ORIENT_UL
	store_addr address_pointer, tilemap_address_upleft
	jsr load_tilemap
	store_addr address_pointer, tilemap_address_upleft
	jsr load_tilemap_attributes	
update_upright_corner:
	store tilemap_orientation, #TILEMAP_ORIENT_UR
	store_addr address_pointer, tilemap_address_upright
	jsr load_tilemap
	store_addr address_pointer, tilemap_address_upright
	jsr load_tilemap_attributes	
update_downleft_corner:
	lda ppu_scroll_x
	SUB_A_SEC prev_ppu_scroll_x ; if prev_ppu_scroll_x == ppu_scroll_x - jumping to
	beq exit  ; exit

	store tilemap_orientation, #TILEMAP_ORIENT_DL
	store_addr address_pointer, tilemap_address_downleft
	jsr load_tilemap
	store_addr address_pointer, tilemap_address_downleft
	jsr load_tilemap_attributes
	
update_downright_corner:
	store tilemap_orientation, #TILEMAP_ORIENT_DR
	store_addr address_pointer, tilemap_address_downright
	jsr load_tilemap
	store_addr address_pointer, tilemap_address_downright
	jsr load_tilemap_attributes
exit:
	store prev_ppu_scroll_x, ppu_scroll_x
	store prev_ppu_scroll_y, ppu_scroll_y
	rts 
.endproc