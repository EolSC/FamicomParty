; Подключаем заголовок библиотеки Famicom/NES/Денди
.include "../include/neslib.inc"

.segment "ROM_4"	; Страница кода 4 (пятые 8Кб из 64 ROM картриджа) для адреса $A000
	.byte $04	; номер страницы

.import inc_some
.export print_some
; print_some1 - процедура вывода строки с текстом по адресу $8001 на экран
; Главное что мы тут демонстрируем - это то, что процедура эта находясь в странице $04
; будет вызывать другую процедуру из страницы $05.
.proc print_some
	locate_in_vpage PPU_SCR0, 0, 3	; Позиционируемся на символ (0,3) в SCR0
	ldy # 0		; Обнуляем индексный регистр Y
fill_loop:
	lda $8001, y	; Загружаем A из адреса ($8001+Y)
	beq end		; если загруженный байт нулевой - идём на выход
	sta PPU_DATA	; иначе сохраняем его в VRAM
	iny		; инкрементируем Y
	jmp fill_loop	; и возвращаемся в цикл
end:	
	; В конце настроим адрес дальнего межстраничного перехода на процедуру
	; inc_some находящуюся в странице $05 и вызовем её межстраничным переходом.
	set_far_dest # 5, inc_some	; сохраним адрес перехода в zero-page
	jsr far_jsr	; и перейдём на процедуру межстраничного перехода
	rts		; возврат из процедуры
.endproc	

