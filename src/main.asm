; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "include/neslib.inc"
; Подключаем заголовок библиотеки маппера MMC3
.include "include/mmc3.inc"

; Сегмент векторов прерываний и сброса/включения - находится в самых
; последних шести байтах адресного пространства процессора ($FFFA-FFFF)
; и содержит адреса по которым процессор переходит при наступлении события
.segment "VECTORS"	
	.addr nmi	; Вектор прерывания NMI (процедура nmi ниже)
	.addr reset	; Вектор сброса/включения (процедура reset ниже)
	.addr irq	; Вектор прерывания IRQ (процедура irq ниже)
.segment "ROM_H"	; Сегмент кода в ПЗУ картриджа (страницы $C000-$FFFF)

; Импортируемые процедуры текстового движка
.import print_char
.import reset_string
.import clear_text_area
.import load_letters_sprites

; Общие функции
.import load_from_table
.import load_sprite_from_table
.import load_tilemap_from_table
.import load_tilemap_attributes_from_table
.import update_nametable_scrolling


; Метка начала таблиц
.import Text_table			; текстов
.import Cutscene_Table		; спрайтов катсцен
.import Interface_Table		; спрайтов интерфейса
.import Title_Table			; спрайтов стартового экрана
.import Tilemap_Table1		; тайлмапов 1
.import Tilemap_Table2		; тайлмапов 2
.import Tilemap_Table3		; тайлмапов 3
.import Table_palettes		; палитр
.import Environment_Table1	; спрайтов фонов уровней 1

; irq - процедура обработки прерывания IRQ
; Пока сразу же возвращается из прерывания как заглушка.
.proc irq
	rti		; Инструкция возврата из прерывания
.endproc

; nmi - процедура обработки прерывания NMI
; Обрабатывает наступление прерывания VBlank от PPU (см. процедуру wait_nmi)
.proc nmi
	inc vblank_counter	; Просто увеличим vblank_counter
	rti			; Возврат из прерывания
.endproc

; wait_nmi - ожидание наступления прерывания VBlank от PPU
; Согласно статье https://wiki.nesdev.com/w/index.php/NMI ожидание VBlank
; опросом верхнего бита PPU_STATUS в цикле может пропускать целые кадры из-за
; специфической гонки состояний, поэтому правильнее всего перехватывать прерывание,
; в нём наращивать счётчик (процедура nmi выше) и ожидать его изменения как в коде ниже.
.proc wait_nmi
	lda vblank_counter
notYet:	cmp vblank_counter
	beq notYet
	rts
.endproc

; fill_bgr_palette - заполнить палитру фона
; портит A, Y, arg0w
; вход:
;	arg0w - адрес таблицы с набором палитр ( 4 * 4 байта)
.proc fill_bgr_palette
	fill_ppu_addr PPU_BGR_PALETTES	; палитры в VRAM находятся по адресу $3F00
	ldy # 0							; зануляем счётчик и одновременно индекс
loop:
	lda (arg0w), y		; сложный режим адресации - к слову лежащему в zero page
						; по однобайтовому адресу arg0w прибавляется Y и 
						; в A загружается байт из полученного адреса
	sta PPU_DATA				; сохраняем в VRAM
	iny							; инкрементируем Y
	cpy # NES_PALETTE_SIZE		; проверяем на выход за границу цикла
	bne loop					; и зацикливаемся если она еще не достигнута
	rts							; выходим из процедуры
.endproc

; fill_attribs - заполнить область цетовых атрибутов байтом в аккумуляторе
; адрес в PPU_ADDR уже должен быть настроен на эту область атрибутов!
.proc fill_attribs
	ldx # 64		; надо залить 64 байта цветовых атрибутов
loop:	sta PPU_DATA		; записываем в VRAM аккумулятор
	dex			; декрементируем X
	bne loop		; цикл по счётчику в X
	rts			; возврат из процедуры
.endproc

; выбирает текст из первого банка 
; arg0b - смещение в Text_table
; Портит A, Y; изменяет text_address
.proc select_text_proc
	store_addr address_pointer, Text_table
	jsr load_from_table	; load_from_table
						; загружаем буквы в PPU
	store_word_to_word address_pointer, data_pointer
	rts
.endproc

.proc hide_all_sprites 
	; Отключим все спрайты выводом их за границу отрисовки по Y
	ldx # 0		; В X разместим указатель на текущий спрайт
	lda # $FF	; В A координата $FF по Y
	ldy # $5F   ; В Y - пустой спрайт
sz_loop:	
	sta SPR_TBL, x	; Сохраним $FF в координату Y текущего спрайта
	inx
	inx
	inx
	inx		; И перейдём к следующему
	bne sz_loop	; Если X не 0, то идём на следующую итерацию
	rts
.endproc

; load_pallete_by_index - загружает палтру по индексу из банка 09
; портит A, Y, arg0w, arg1w
; вход :
; arg2b - номер палитры
.proc load_pallete_by_index
	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_PALETTES_01			; В банке данных выберем страницу палитр
	; загружаем из Table_palettes 
	store_addr arg0w, Table_palettes
	store arg3b, #0
	; вычисляем смещение для палитры с индексом DATA_PALETTE_COPYRIGHT
	MULT_WORD_BY_16 arg1w					; умножаем индекс на 16(16 байт размер палитры)
	ADD_WORD_TO_WORD arg0w, arg1w			; прибавляем к адресу таблицы
	jsr fill_bgr_palette
	rts
.endproc

; update_ppu_state - обновляет флаги PPU_CTRL, PPU_MASK
; портит A
; вход :
; active_ppu_ctrl - текущий набор флагов PPU_CTRL
; active_ppu_mask - текущий набор флагов PPU_MASK
.proc update_ppu_state
	; обновляем состояние из памяти
	store PPU_CTRL, active_ppu_ctrl
	store PPU_MASK, active_ppu_mask
	jsr update_scrolling
	rts
.endproc

; clear_ppu_state - сбрасывает флаги PPU_CTRL, PPU_MASK
; портит A
.proc clear_ppu_state
	; обновляем состояние 
	store PPU_CTRL, #0
	store PPU_MASK, #0
	rts
.endproc


; отключает скроллинг для текущей графики
.proc update_scrolling
	store PPU_SCROLL, ppu_scroll_x ; Перед началом кадра выставим скроллинг
	store PPU_SCROLL, ppu_scroll_y ; в (0, 0) чтобы панель рисовалась фиксированно	
	rts
.endproc

; Процедура обновления кадра
.proc render_static_frame
	jsr update_scrolling	; скроллинг
	jsr wait_nmi			; ждем окончания отрисовки
	jsr update_keys			; обновляем ввод
	rts
.endproc

.proc wait_next_frame
	store PPU_CTRL, #PPU_VBLANK_NMI
	lda #1
	sta vblank_counter
	jsr wait_nmi
	jsr update_ppu_state
	rts
.endproc

; load_image_by_index - загружает спрайты интро в видеопамять
; портит A, X, Y, arg0w, arg1w, arg2w, arg3w
; вход :
; address_pointer - адрес таблицы спрайтов
; data_pointer - адрес таблицы тайлмапов
; arg1w - адрес в PPU вкоторый грузим данные
; arg0b - номер изображения 
; arg1b - номер тайлмапа 
; sprite_bank - номер банка спрайтов
; tilemap_bank - номер банка тайлмапа
; arg2w - адрес в PPU с которого грузить изображение
.proc load_image_by_index 
	lda arg1b ; запоминаем arg1b в стек
	pha
	; запоминаем данные в arg3w
	store_word_to_word arg3w, data_pointer
	jsr load_sprite_from_table
	; запоминаем в arg0b смещение тайлмапа
	pla 
	sta arg1b ; достаем из стека оффсет для тайл мапа
	pha
	store_word_to_word address_pointer, arg3w ; восстанавливаем адрес таблицы тайлмапов
	store arg0b, arg1b						  ; передаем оффсет тайлмапа в arg0b
	mmc3_set_bank_page # MMC3_PRG_H1, tilemap_bank	; В банке данных выберем страницу tilemap_bank
	jsr load_tilemap_from_table
	pla 
	sta arg0b								  ; восстанавливаем из стека номер тайлмапа и кладем в arg0b
	store_word_to_word address_pointer, arg3w ; восстанавливаем адрес таблицы тайлмапов
	ADD_WORD_TO_WORD_IMM arg1w, PPU_ATTR_OFFSET
	jsr load_tilemap_attributes_from_table
	rts
.endproc


; load_image - загружает изображение в память
; портит A, X, Y, arg0w, arg1w, arg2w, arg3w
; вход :
; address_pointer - адрес таблицы спрайтов
; data_pointer - адрес таблицы тайлмапов
; arg2w - адрес в PPU вкоторый грузим данные
; arg0b - номер изображения 
; arg1b - номер тайлмапа 
; arg2b - номер палитры
; sprite_bank - номер банка спрайтов
; tilemap_bank - номер банка тайлмапа
; arg2w - адрес в PPU с которого грузить изображение
.proc load_background_image
	jsr clear_ppu_state
	A_TO_STACK arg0b
	A_TO_STACK arg1b
	store_word_to_word arg3w, arg2w
	jsr load_pallete_by_index
	FROM_STACK_TO_A arg1b
	FROM_STACK_TO_A arg0b
	store_word_to_word arg1w, arg3w
	jsr load_image_by_index
	jsr wait_next_frame
	rts
.endproc

; load_copyright_image - загружает стартовое изображение в память фона
; использует и портит то же что и load_background_image
.proc load_copyright_image

	; загружаем из Interface_Table изображение с индексом arg0b
	store_addr address_pointer, Interface_Table
	store arg0b, #DATA_SPRITE_COPYRIGHT
	store sprite_bank, #BANK_SPRITES_INTERFACE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_COPYRIGHT
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_COPYRIGHT

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	rts
.endproc

; load_cutscene_01 - загружает первую катсцену в память фона
; использует и портит то же что и load_background_image
; выход:
; arg1b - индекс текста, после которого переключаемся дальше на следующую катсцену
.proc load_cutscene_01

	; загружаем из Cutscene_Table изображение с индексом arg0b
	store_addr address_pointer, Cutscene_Table
	store arg0b, #DATA_SPRITE_CUTSCENE_01
	store sprite_bank, #BANK_SPRITES_CUTSCENE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_CUTSCENE_01
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_CUTSCENE_01

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	store arg1b, #MAX_TEXT_CUTSCENE_01
	rts
.endproc

; load_cutscene_02 - загружает первую катсцену в память фона
; использует и портит то же что и load_background_image
; выход:
; arg1b - индекс текста, после которого переключаемся дальше на следующую катсцену

.proc load_cutscene_02

	; загружаем из Cutscene_Table изображение с индексом arg0b
	store_addr address_pointer, Cutscene_Table
	store arg0b, #DATA_SPRITE_CUTSCENE_02
	store sprite_bank, #BANK_SPRITES_CUTSCENE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_CUTSCENE_02
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_CUTSCENE_02

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	store arg1b, #MAX_TEXT_CUTSCENE_02	
	rts
.endproc

.proc load_cutscene_03

	; загружаем из Cutscene_Table изображение с индексом arg0b
	store_addr address_pointer, Cutscene_Table
	store arg0b, #DATA_SPRITE_CUTSCENE_03
	store sprite_bank, #BANK_SPRITES_CUTSCENE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_CUTSCENE_03
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_CUTSCENE_03

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	store arg1b, #MAX_TEXT_CUTSCENE_03	
	rts
.endproc

.proc load_cutscene_04

	; загружаем из Cutscene_Table изображение с индексом arg0b
	store_addr address_pointer, Cutscene_Table
	store arg0b, #DATA_SPRITE_CUTSCENE_04
	store sprite_bank, #BANK_SPRITES_CUTSCENE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_CUTSCENE_04
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_CUTSCENE_04

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	store arg1b, #MAX_TEXT_CUTSCENE_04	
	rts
.endproc

.proc load_title_image

	; загружаем из Title_Table изображение с индексом arg0b
	store_addr address_pointer, Title_Table
	store arg0b, #DATA_SPRITE_TITLE_LOGO
	store sprite_bank, #BANK_SPRITES_TITLE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_TITLE_LOGO
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_LOGO

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	rts
.endproc

.proc load_difficulty_image

	; загружаем из Title_Table изображение с индексом arg0b
	store_addr address_pointer, Title_Table
	store arg0b, #DATA_SPRITE_TITLE_LOGO
	store sprite_bank, #BANK_SPRITES_TITLE

	; загружаем из Tilemap_Table2 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table2
	store arg1b, #DATA_TILEMAP_DIFFICULTY
	store tilemap_bank, #BANK_TILEMAPS_02
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_LOGO

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	rts
.endproc

.proc load_save_sceen_image

	; загружаем из Title_Table изображение с индексом arg0b
	store_addr address_pointer, Title_Table
	store arg0b, #DATA_SPRITE_SAVESCREEN
	store sprite_bank, #BANK_SPRITES_TITLE

	; загружаем из Tilemap_Table1 изображение с индексом arg1b
	store_addr data_pointer, Tilemap_Table1
	store arg1b, #DATA_TILEMAP_SAVESCREEN
	store tilemap_bank, #BANK_TILEMAPS_01
	; индекс для палитры копирайта
	store arg2b, #DATA_PALETTE_LOGO

	; пишем данные в nametable для Background
	store_addr arg2w, PPU_BGR_TBL

	jsr load_background_image
	rts
.endproc

.proc load_environment_sprites
	; загружаем из Environment_Table1 изображение с индексом arg0b
	store_addr address_pointer, Environment_Table1
	store arg0b, #DATA_SPRITE_ENVIRONMENT
	store sprite_bank, #BANK_SPRITES_ENV_1_2_7
	; пишем данные в nametable для Background
	store_addr arg1w, PPU_BGR_TBL
	jsr load_sprite_from_table

	; индекс для палитры фона
	store arg2b, #DATA_PALETTE_ENVIRONMENT
	jsr load_pallete_by_index
	
	rts
.endproc

.proc load_environment_tilemap
	store_addr address_pointer, Tilemap_Table2

	store arg0b, #DATA_TILEMAP_ENVIRONMENT1
	jsr load_from_table
	store_addr tilemap_address_upleft, data_pointer

	store arg0b, #DATA_TILEMAP_ENVIRONMENT2
	jsr load_from_table
	store_addr tilemap_address_upright, data_pointer

	store arg0b, #DATA_TILEMAP_ENVIRONMENT3
	jsr load_from_table
	store_addr tilemap_address_downleft, data_pointer

	store arg0b, #DATA_TILEMAP_ENVIRONMENT4
	jsr load_from_table
	store_addr tilemap_address_downright, data_pointer

	store arg0b, #DATA_TILEMAP_ENVIRONMENT4
	jsr load_from_table
	store_addr tilemap_address_downright, data_pointer
	jsr update_nametable_scrolling
	rts
.endproc

; анимация выбранной опции в стартовом меню
;портит А, argob
.proc blink_selected_text
	; выбираем 8й цвет палитры для текста
	; выбираем 8й цвет палитры
	jsr wait_nmi
	inc generic_counter
	lda generic_counter
	cmp #$05
	bne exit
	inc arg0b	 
	lda #$00
	sta generic_counter
	store PPU_CTRL, #0
	store PPU_MASK, #0
	fill_ppu_addr PPU_BGR_PALETTES + $7	

	; обновляем текст
	lda arg0b		
	and #%00000111
	sta arg0b
	cmp #4
	bcc load_value
	lda #7
	sbc arg0b
load_value:	
	MULT_A_BY_16
	sta PPU_DATA
	store PPU_CTRL, active_ppu_ctrl
	store PPU_MASK, active_ppu_mask
exit:
	rts
.endproc

.proc change_selected_item
	jsr wait_nmi

	store PPU_CTRL, #0
	store PPU_MASK, #0
	fill_ppu_addr $23E0

	ldx #8
	lda arg1b
loop:	
	sta PPU_DATA
	dex
	bne loop
	ldx #8
	lda arg2b
loop1:	
	sta PPU_DATA
	dex
	bne loop1
	store PPU_CTRL, active_ppu_ctrl
	store PPU_MASK, active_ppu_mask
	jsr update_scrolling
exit:
	rts
.endproc
; Процедура обновления катсцен
; Портит
; вход:
; game_state - текущее состояние игры
.proc update_cutscenes
	lda game_state
	cmp #GAME_STATE_CUTSCENE1
	bne load_cutscene_2
load_cutscene_1:
	jsr load_cutscene_01
	jmp exit
load_cutscene_2:
	cmp #GAME_STATE_CUTSCENE2
	bne load_cutscene_3
	jsr load_cutscene_02
	jmp exit
load_cutscene_3:
	cmp #GAME_STATE_CUTSCENE3
	bne load_cutscene_4
	jsr load_cutscene_03
	jmp exit
load_cutscene_4:
	cmp #GAME_STATE_CUTSCENE4
	jsr load_cutscene_04
	bne exit
exit:
	rts
.endproc

.proc draw_cutscenes
	; запоминаем что перешли в экран первой катсцены
	store game_state, #GAME_STATE_CUTSCENE1

	jsr clear_ppu_state

	clear_background_table
	; грузим спрайты текста
	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_SPRITES_LETTERS	
	jsr load_letters_sprites
	store arg1b, #TEXT_BOX_X								; загружаем в arg0b координату X вывода
	store arg0b, #TEXT_BOX_Y_UPPER							; загружаем в arg1b координату Y вывода		
	jsr reset_string
	; запомним в стеке нулевой индекс текста
	lda #0
	pha
cutscenes_start: 
	jsr update_cutscenes

	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_DATA_TEXT	; В банке данных выберем страницу 0 т.к. дальше будет работа с текстами

	ldy arg1b	; читаем максимальный индекс текста для катсцены
	pla
	sta arg0b	; выберем нужный текст
	tya			; положим в стек сначала номер максимального текста для катсцены
	pha 
	lda arg0b	; потом текущий индекс
	pha 		; 
	jsr select_text_proc


main_loop:		; основной цикл


	jsr render_static_frame	

	lda printed_text_length									; проверяем допечатан ли текущий текст
	inc printed_text_length									; иначе увеличиваем printed_text_length

	jsr clear_ppu_state
	jsr print_char	
	jsr update_ppu_state									

update_controller:
	jump_if_keys1_was_not_pressed KEY_START, update_scroll
show_next_text:												; показываем следущий текст

	store arg1b, #TEXT_BOX_X								; загружаем в arg0b координату X вывода
	store arg0b, #TEXT_BOX_Y_UPPER							; загружаем в arg1b координату Y вывода	
	jsr reset_string										; обнуляем счетчик символов
	jsr clear_ppu_state
	jsr clear_text_area										
	jsr wait_next_frame	

	pla 													; Достаем из стека текущий индекс
	sta arg0b												; копируем в arg0b и arg2b
	inc arg0b
	store arg2b, arg0b
	jsr select_text_proc									; загружаем адрес следующего текста
	pla														; грузим из стека максимальный индекс
	cmp arg2b												; проверям дошли ли до конца
	beq start_next_cutscene									; если да - сбрасываем 
	pha														; иначе снова сохраняем макс. значение
	lda arg2b
	pha														; и текущий индекс текста
update_scroll:
	jsr wait_nmi
	jsr update_scrolling
	jmp main_loop											; И уходим ждать нового VBlank в бесконечном цикле

start_next_cutscene:										; переход к следующему game_state
	inc game_state							
	lda game_state
	cmp #GAME_STATE_LOAD_GAME_SELECTED
	beq exit												; если катсцены показаны - движемся дальше
	lda arg2b												; перед переходом - сохраним в стек индекс текущего текста
	pha 
	jmp cutscenes_start
exit:
	rts	
.endproc

; Инициализация читов
; Портит - А
; записывает в selected_cheat выбранный чит, который меняет игровую последовательность
; Вызывается в самом начале функции reset, список читов в game_constants
.proc enable_cheats
	; пропуск Интро
	store selected_cheat, #CHEAT_SKIP_ALL_INTRO
	rts
.endproc
; reset - стартовая точка всей программы - диктуется вторым адресом в сегменте 
; VECTORS оформлена как процедура, но вход в неё происходит при включении консоли 
; или сбросу её по кнопке RESET, поэтому ей некуда "возвращаться" и она 
; принудительно инициализирует память и стек чтобы работать с чистого листа.
.proc reset
	; ***********************************************************
	; * Первым делом нужно привести систему в рабочее состояние *
	; ***********************************************************
	sei			; запрещаем прерывания
	ldx # $FF		; чтобы инициализировать стек надо записать $FF в X
	txs			; и передать его в регистр вершины стека командой 
				; Transfer X to S (txs)
	
	sta MMC3_IRQ_OFF	; Выключим IRQ маппера
	
	; Теперь можно пользоваться стеком, например вызывать процедуры
	jsr warm_up		; вызовем процедуру "разогрева" (см. neslib.s)
	
	; Предварительно выставим банки памяти PPU просто по порядку
	mmc3_set_bank_page # MMC3_CHR_H0, # 0
	mmc3_set_bank_page # MMC3_CHR_H1, # 2
	mmc3_set_bank_page # MMC3_CHR_Q0, # 4
	mmc3_set_bank_page # MMC3_CHR_Q1, # 5
	mmc3_set_bank_page # MMC3_CHR_Q2, # 6
	mmc3_set_bank_page # MMC3_CHR_Q3, # 7
	
	; Предварительно выставим банки памяти CPU
	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_DATA_TEXT			; В банке данных выберем страницу текста
	
	store MMC3_MIRROR, # MMC3_MIRROR_H	; Выставим вертикальное зеркалирование
	store MMC3_RAM_PROTECT, # MMC3_RAM_ENABLED | MMC3_RAM_PROTECTED	; Включим SRAM и выставим защиту от записи

	; **********************************************
	; * Стартуем видеочип и запускаем все процессы *
	; **********************************************
	cli			; Разрешаем прерывания


	; запрашиваем чтобы очистить адрес
    LDX PPU_STATUS 

	; ***************************
	; * Основной цикл программы *
	; ***************************

	jsr enable_cheats
	jsr hide_all_sprites	; загружаем спрайты

	; Включим генерацию прерываний по VBlank и источником тайлов для спрайтов
	; сделаем второй банк видеоданных где у нас находится шрифт.
	store active_ppu_ctrl, # PPU_VBLANK_NMI | PPU_BGR_TBL_1000 | PPU_SCR_Y240	
	; Включим отображение спрайтов и то что они отображаются в левых 8 столбцах пикселей
	store active_ppu_mask, # PPU_SHOW_BGR | PPU_SHOW_SPR | PPU_SHOW_LEFT_BGR 

	store ppu_scroll_x, #0
	store ppu_scroll_y, #0

	store tilemap_min_x, #0						; init min/max tilemap size
	store tilemap_min_y, #0						; using (0,0,SCREEN_SPRITE_COUNT_X, SCREEN_SPRITE_COUNT_Y) for fullscreen images
	store tilemap_max_x, #SCREEN_SPRITE_COUNT_X	; such as Copyright, Cutscenes, TitleScreen
	store tilemap_max_y, #SCREEN_SPRITE_COUNT_Y



	lda selected_cheat
	cmp #CHEAT_SKIP_ALL_INTRO
	beq cheat_start_new_game

	jsr clear_ppu_state
	jsr load_copyright_image
	jsr update_ppu_state
	jmp show_title_image		; Показываем заставку

cheat_start_new_game:	; Cheat game start
						; Using Easy difficulty as the default value for CheatMode
	store player_state_flags, #GAME_DIFFICULTY_EASY
	jmp start_new_game
show_title_image:
	
	jsr render_static_frame
	jump_if_keys1_was_not_pressed KEY_START, show_title_image
	jsr draw_cutscenes										; Если start нажат - ижем в процедуру отрисовки катсцен


load_start_game_screen:										; Переход к стартовому экрану
	store game_state, #GAME_STATE_LOAD_GAME_SELECTED		; обновляем game_state
	jsr load_title_image

show_start_game_screen:										; Основной экран игры
	jsr blink_selected_text									; выделяем цветом выбранную опцию
	jsr update_scrolling
	jsr update_keys
	jump_if_keys1_was_pressed KEY_UP, update_title_up_down	; При нажатии вверх или вниз - запоминаем выбор
	jump_if_keys1_was_pressed KEY_DOWN, update_title_up_down
	jump_if_keys1_was_pressed KEY_START, check_select_difficulty	; если нажат Start - перейдем к следующему экрану
	jmp show_start_game_screen
update_title_up_down:
	lda game_state
	cmp #GAME_STATE_LOAD_GAME_SELECTED
	bne select_load_game

select_new_game:	; выбран экран "новая игра"
	store game_state, #GAME_STATE_NEW_GAME_SELECTED
	store arg1b, #$55			; смена выделенного текста
	store arg2b, #$A5		
	jsr change_selected_item

	jmp show_start_game_screen	; возвращаемся в цикл

select_load_game: 	; выбран экран "загрузка"
	store game_state, #GAME_STATE_LOAD_GAME_SELECTED
	store arg1b, #$AA		; смена выделенного текста
	store arg2b, #$5A
	jsr change_selected_item	
	jmp show_start_game_screen	; возвращаемся в цикл
check_select_difficulty:
	lda game_state
	cmp #GAME_STATE_NEW_GAME_SELECTED
	bne show_savescreen
	jsr load_difficulty_image	; загружаем экран выбора сложности
	store player_state_flags, #GAME_DIFFICULTY_HARD	; по умолчанию - флаг сложности HARD	
	jmp show_select_difficulty
show_savescreen:
	jsr load_save_sceen_image	; загружаем экран выбора сложности
update_save_screen:
	jsr wait_nmi
	jsr update_scrolling
	jmp update_save_screen


show_select_difficulty:		; Экран выбора сложности
	jsr blink_selected_text
	jsr update_scrolling
	jsr update_keys
	; аналогично предыдущему экрану - выбираем опцию из двух и запоинаем выбор
	jump_if_keys1_was_pressed KEY_UP, update_difficulty_up_down
	jump_if_keys1_was_pressed KEY_DOWN, update_difficulty_up_down
	jump_if_keys1_was_pressed KEY_START, start_new_game	
	jmp show_select_difficulty	

update_difficulty_up_down:
	lda player_state_flags ; проверяем какая сложность была выбрана
	and #$01			   

	beq set_difficulty_easy ; если выбрана hard	 - перейдем к set_difficulty_easy
							; иначе проваливаемся в set_difficulty_hard
set_difficulty_hard:
	store player_state_flags, #GAME_DIFFICULTY_HARD
	store arg1b, #$AA		; смена выделенного текста
	store arg2b, #$5A
	jsr change_selected_item
	jmp show_select_difficulty

set_difficulty_easy:
	store player_state_flags, #GAME_DIFFICULTY_EASY
	store arg1b, #$55		; смена выделенного текста
	store arg2b, #$A5	
	jsr change_selected_item
	jmp show_select_difficulty	

start_new_game:
	store prev_ppu_scroll_x, #$80
	store prev_ppu_scroll_y, #$00
	store ppu_scroll_x, #$180
	store ppu_scroll_y, #$F0
	jsr clear_ppu_state
	clear_background_table
	jsr load_environment_sprites
	jsr load_environment_tilemap
	jsr update_nametable_scrolling
	jsr update_ppu_state
	store game_state, #GAME_STATE_INTRO_CUTSCENE
main_game:
	jump_if_keys1_is_down KEY_LEFT, test_scroll_left		; тестируем скроллинг
	jump_if_keys1_is_down KEY_RIGHT, test_scroll_right
	jmp main_update
test_scroll_left:
	dec ppu_scroll_x
	jmp main_update	
test_scroll_right:

	inc ppu_scroll_x
	jmp main_update	
main_update:

	jsr wait_nmi
	jsr update_scrolling
	jsr update_keys
	jmp main_game
.endproc