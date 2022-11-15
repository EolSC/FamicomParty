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

.segment "ZPAGE": zp	; Сегмент zero page, это надо пометить через ": zp"
vblank_counter:	.byte 0	; Счётчик прерываний VBlank


.segment "RAM"		; Сегмент неинициалиsзированных данных в RAM

text_table_offset: .byte 0


; С MMC3 в сегменте ROM_H у нас располагаются последние страницы ROM картриджа
; т.е. в данной конфигурации с 64Кб ROM - 6 и 7 по порядку.
.segment "ROM_H"	; Сегмент данных в ПЗУ картриджа (страницы $C000-$FFFF)
palettes:		; Подготовленные наборы палитр (для фона и для спрайтов)
	; Повторяем наборы 2 раза - первый для фона и второй для спрайтов
	.repeat 2	
	.byte $FF, $00, $10, $20	; Черный, серый, светло-серый, белый
	.byte $0F, $16, $1A, $11	; -, красный, зеленый, синий
	.byte $0F, $1A, $11, $16	; -, зеленый, синий, красный
	.byte $0F, $11, $16, $1A	; -, синий, красный, зеленый
	.endrep
  
.segment "ROM_H"	; Сегмент кода в ПЗУ картриджа (страницы $C000-$FFFF)

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

; fill_palettes - заполнить все наборы палитр данными из адреса в памяти
; вход:
;	arg0w - адрес таблицы с набором палитр (2 * 4 * 4 байта)
.proc fill_palettes
	fill_ppu_addr PPU_BGR_PALETTES	; палитры в VRAM находятся по адресу $3F00
	ldy # 0							; зануляем счётчик и одновременно индекс
loop:
	lda (arg0w), y		; сложный режим адресации - к слову лежащему в zero page
				; по однобайтовому адресу arg0w прибавляется Y и 
				; в A загружается байт из полученного адреса
	sta PPU_DATA		; сохраняем в VRAM
	iny			; инкрементируем Y
	cpy # 2 * 4 * 4		; проверяем на выход за границу цикла
	bne loop		; и зацикливаемся если она еще не достигнута
	rts			; выходим из процедуры
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

; Метка начала таблицы текстов
.import Text_table
.import Cutscene_Table
; выбирает текст из первого банка 
; ипользует смещение text_table_offset
; Портит A, Y; изменяет text_address
.proc select_text_proc
	store_addr address_pointer, Text_table
	store arg0b, text_table_offset
	; выставим банк BANK_PRG_TEXT_ENGINE и адрес load_from_table как
	set_far_dest # BANK_PRG_TEXT_ENGINE, load_from_table			
	jsr far_jsr			; и совершим межстраничный переход	
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



; Импортируемые процедуры текстового движка
.import print_string
.import clear_text_area
.import load_letters_sprites

; Общие функции
.import load_from_table
.import load_sprite_from_table

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
	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_SPRITES_LETTERS	; В банке данных выберем страницу спрайтов текста
	mmc3_set_bank_page # MMC3_PRG_H1, # BANK_PRG_TEXT_ENGINE	; В банке кода выберем страницу BANK_PRG_TEXT_ENGINE
	
	store MMC3_MIRROR, # MMC3_MIRROR_V	; Выставим вертикальное зеркалирование
	store MMC3_RAM_PROTECT, # 0		; Отключим RAM (если бы она даже была)

	; **********************************************
	; * Стартуем видеочип и запускаем все процессы *
	; **********************************************
	cli			; Разрешаем прерывания

	store PPU_CTRL, # 0 ; отключаем PPU перед записью
	store PPU_MASK, # 0 ; отключаем PPU перед записью
	; запрашиваем чтобы очистить адрес
    LDX PPU_STATUS     
	store_addr arg0w, palettes	; параметр arg0w = адрес наборов палитр	      	
	jsr fill_palettes		; загружаем палитры
	fill_ppu_addr PPU_SCR0_ATTRS	; настроим PPU_ADDR на атрибуты SCR0
	lda # 0					; выберем в A нулевую палитру
	jsr fill_attribs		; и зальём её область атрибутов SCR0	

	jsr hide_all_sprites	; загружаем спрайты

	; выставим банк BANK_PRG_TEXT_ENGINE и адрес load_letters_sprites как
	set_far_dest # BANK_PRG_TEXT_ENGINE, load_letters_sprites			
	jsr far_jsr			; и совершим межстраничный переход	
						; загружаем буквы в PPU

	fill_page_by PPU_SCR0, EMPTY_SYMBOL

	; загружаем из Cutscene_Table изображение с индексом arg0b
	store_addr address_pointer, Cutscene_Table
	; в arg1w пишем конец таблицы символов
	lda #00;.LOBYTE(TEXT_SPRITES_END_IN_PPU)
	sta arg1w
	lda #00;.HIBYTE(TEXT_SPRITES_END_IN_PPU)
	sta arg1w + 1	
	; выбираем  катсцену с индексом 0 
	store arg0b, #0
	; Предварительно выставим банки памяти CPU
	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_SPRITES_CUTSCENE	; В банке данных выберем страницу спрайтов текста
	; выставим банк BANK_PRG_TEXT_ENGINE и адрес load_letters_sprites как
	set_far_dest # BANK_PRG_TEXT_ENGINE, load_sprite_from_table			
	jsr far_jsr			; и совершим межстраничный переход	
						; загружаем буквы в PPU

	; ***************************
	; * Основной цикл программы *
	; ***************************

	; Включим генерацию прерываний по VBlank и источником тайлов для спрайтов
	; сделаем второй банк видеоданных где у нас находится шрифт.
	store PPU_CTRL, # PPU_VBLANK_NMI | PPU_BGR_TBL_1000	
	; Включим отображение спрайтов и то что они отображаются в левых 8 столбцах пикселей
	store PPU_MASK, # PPU_SHOW_BGR | PPU_SHOW_LEFT_BGR | PPU_SHOW_SPR | PPU_SHOW_LEFT_SPR

	mmc3_set_bank_page # MMC3_PRG_H0, # BANK_DATA_TEXT	; В банке данных выберем страницу 0 т.к. дальше будет работа с текстами
	lda #0
	sta text_table_offset
	jsr select_text_proc

main_loop:		; основной цикл


	jsr wait_nmi											; дожидаемся VBlank

	lda printed_text_length									; проверяем допечатан ли текущий текст
	cmp #MAX_TEXT_SIZE										; если в printed_text_length - #FF, значит текст отрисован
	beq update_controller									; переходим на обновление ввода игрока
	inc printed_text_length									; иначе увеличиваем printed_text_length
	jmp update_text_main_loop								; и продолжаем рисовать текст

update_text_main_loop:

	store arg1b, #TEXT_BOX_X								; загружаем в arg0b координату X вывода
	store arg0b, #TEXT_BOX_Y_UPPER							; загружаем в arg1b координату Y вывода	
	set_far_dest # BANK_PRG_TEXT_ENGINE, print_string		; выставим банк 4 и адрес print_string как
															; цель межстраничного перехода
	jsr far_jsr												; и совершим межстраничный переход

	jmp update_scroll
update_controller:
	jump_if_keys1_was_not_pressed KEY_START, update_scroll
show_next_text:												; показываем следущий текст

	lda #0													; обнуляем счетчик символов
	sta printed_text_length
	store arg1b, #TEXT_BOX_X								; загружаем в arg0b координату X вывода
	store arg0b, #TEXT_BOX_Y_UPPER							; загружаем в arg1b координату Y вывода	
	set_far_dest # BANK_PRG_TEXT_ENGINE, clear_text_area	; выставим банк 4 и адрес clear_text_area как
															; цель межстраничного перехода
	jsr far_jsr												; и совершим межстраничный переход

	inc text_table_offset									; увиличиваем смещение в таблице текстов
	jsr select_text_proc									; загружаем адрес следующего текста
	lda text_table_offset
	cmp #TEXT_COUNT											; проверям дошли ли до концаю Умножение на 2 т.к. каждый адрес это word
	beq reset_text_table_offset								; если да - сбрасываем 

update_scroll:

	store PPU_SCROLL, # 0									; Перед началом кадра выставим скроллинг
	store PPU_SCROLL, # 0									; в (0, 0) чтобы панель рисовалась фиксированно	
	jsr update_keys											; Обновим состояние кнопок опросив геймпады
	jmp main_loop											; И уходим ждать нового VBlank в бесконечном цикле
reset_text_table_offset:									; сброс таблицы текстов

	store text_table_offset, #0								; сбрасываем смещение
	jsr select_text_proc										; обновляем адрес рисуемого текста
	jmp main_loop											; и возвращаемся в цикл
.endproc