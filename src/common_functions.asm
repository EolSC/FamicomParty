.include "include/neslib.inc"	; подключим заголовк neslib.inc
.include "include/mmc3.inc"	; подключим заголовк neslib.inc

.segment "RAM"			
				
; Кнопки нажатые на геймпадах во время предыдущего вызова update_keys.
keys1_prev:	.byte 0
keys2_prev:	.byte 0

; Сегмент кода в ROM картриджа, причём последние его 16 Кб ($C000-FFFF).
; Третья четверть ROM ($8000-BFFF) пока зарезервирована под использование с мапперами.
.segment "ROM_H"

; update_keys - перечитать кнопки с геймпадов 1 и 2.
; текущие зажатые кнопки -> keysX_is_down
; предыдущие зажатые кнопки -> keysX_prev
; кнопки нажатые между этими состояниями -> keyX_was_pressed
; Код адаптирован из https://wiki.nesdev.com/w/index.php/Controller_reading_code
.proc update_keys
	; Сохраняем предыдущие нажатые кнопки
	store keys1_prev, keys1_is_down
	store keys2_prev, keys1_is_down
	; Инициируем опрос геймпадов записью 1 в нижний бит JOY_PAD1
	lda # $01		; После записи в порт 1 состояния кнопок начинают в геймпадах
	sta JOY_PAD1		; постоянно записываться в регистры-защёлки...
	sta keys2_is_down	; Этот же единичный бит используем для остановки цикла ниже
	lsr a			; Обнуляем аккумулятор (тут быстрее всего сделать это сдвигом вправо)
	sta JOY_PAD1		; Запись 0 в JOY_PAD1 фиксирует регистры-защёлки и их можно считывать
	
loop:	lda JOY_PAD1		; Грузим очередную кнопку от первого контроллера
	and # %00000011		; Нижний бит - стандартный контроллер, следующий - от порта расширения
	cmp # $01		; Бит Carry установится в 1 только если в аккумуляторе не 0 (т.е. нажатие)
	rol keys1_is_down	; Прокрутка keys1_pressed через Carry, если Ki - это i-ый бит, то:
				; NewCarry <- K7 <- K6 <- ... <- K1 <- K0 <- OldCarry
	lda JOY_PAD2		; Делаем всё то же самое для второго геймпада...
	and # %00000011
	cmp # $01
	rol keys2_is_down	; Однако на прокрутке keys2_pressed в восьмой раз в Carry выпадет
	bcc loop		; единица которую мы положили в самом начале и цикл завершится.
	; Далее обновляем keysX_was_pressed - логический AND нового состояния кнопок с NOT предыдущего,
	; т.е. "то что было отжато ранее, но нажато сейчас".
	lda keys1_prev		; берём предыдущее состояние,
	eor # $FF		; инвертируем (через A XOR $FF),
	and keys1_is_down	; накладываем по AND на новое состояние,
	sta keys1_was_pressed	; и сохраняем в keys_was_pressed
	
	lda keys2_prev		; и всё то же самое для второго геймпада...
	eor # $FF
	and keys2_is_down
	sta keys2_was_pressed
	rts			; возвращаемся из процедуры
.endproc

; clear_ram - очистка памяти zero page и участка $0200-07FF
; портит: arg0w
.proc clear_ram
	; Очистка zero page
	lda # $00		; a = 0
	ldx # $00		; x = 0
loop1:	sta $00, x		; [ $00 + x ] = y
	inx			; x++
	bne loop1		; if ( x != 0 ) goto loop1
	; Очищаем участок памяти с $200-$7FF
	store_addr arg0w, $0200	; arg0w = $2000
	lda # $00		; a = 0
	ldx # $08		; x = 8
	ldy # $00		; y = 0
loop2:	sta (arg0w), y		; [ [ arg0w ] + y ] = a
	iny			; y++
	bne loop2		; if ( y != 0 ) goto loop2
	inc arg0w + 1		; увеличиваем старший байт arg0w
	cpx arg0w + 1		; и если он не достиг границы в X
	bne loop2		; то повторяем цикл
	rts			; возврат из процедуры
.endproc

; warm_up - "разогрев" - после включения дождаться пока PPU дойдёт
; до рабочего состояния после чего с ним можно работать.
.proc warm_up
	lda # 0			; a = 0
	sta PPU_CTRL		; Отключим прерывание NMI по VBlank
	sta PPU_MASK		; Отключим вывод графики (фона и спрайтов)
	sta APU_DMC_0		; Отключить прерывание IRQ цифрового звука
	bit APU_STATUS		; Тоже как то влияет на отключение IRQ
	sta APU_CONTROL		; Отключить все звуковые каналы
	; Отключить IRQ FRAME_COUNTER (звук)
	store APU_FRAME_COUNTER, # APU_FC_IRQ_OFF	
	cld			; Отключить десятичный режим (который на Ricoh 2A03 и не работает)

	; Ждём наступления первого VBlank от видеочипа
	bit PPU_STATUS		; Первый надо пропустить из-за ложного состояния при включении
wait1:	bit PPU_STATUS		; Инструкция bit записывает старший бит аргумента во флаг знака
	bpl wait1		; Поэтому bpl срабатывает при нулевом бите PPU_STAT_VBLANK

	; Пока ждём второго VBlank - занулим RAM
	jsr clear_ram

	; Ждём еще одного VBlank
wait2:	bit PPU_STATUS
	bpl wait2	
	rts			; Выходим из процедуры
.endproc

; far_jsr - вызов процедуры из нетекущего банка памяти
; вход: far_jsr_page - страница памяти где находится процедура
; 	far_jsr_addr - адрес процедуры внутри сегмента PRG_H1
; Регистры как на входе в процедуру так и на выходе из неё не портятся.
.proc far_jsr
	sta glob_temp0		; Сохраним A во времянку.
	lda $A000 		; Возьмём текущий селектор страницы в PRG_H1
	pha			; и сохраним в стек.
	lda # MMC3_PRG_H1	; Выбираем банк PRG_H1
	sta MMC3_BANK		; в порту ввода-вывода MMC3_BANK.
	lda far_jsr_page	; Загружаем страницу процедуры в A,
	sta MMC3_PAGE		; Активируем эту страницу в текущем банке
	lda glob_temp0		; Восстановим A из glob_temp0
	jsr invoke		; Переходим на активатор процедуры через jsr чтобы
				; возврат произошёл на следующую инструкцию
	sta glob_temp0		; Сохраним возвращённый из процедуры A во времянке
	lda # MMC3_PRG_H1	; Выбираем банк PRG_H1
	sta MMC3_BANK		; в порту MMC3_BANK.
	pla			; Восстанавливаем старую страницу из стека в A
	sta MMC3_PAGE		; Активируем её записью в порт MMC3_PAGE
	lda glob_temp0		; Восстанавливаем возвращённый процедурой аккумулятор
	rts			; и выходим.
invoke:	
	jmp (far_jsr_addr)	; Косвенный переход на адрес хранимый в far_jsr_addr
.endproc


; locate_in_vpage - выставить в PPU_ADDR адрес байта в 
; странице PPU_SCR0 на координаты тайла (arg1b, arg0b)
;   arg0b - от 0 до 31
;   arg1b - от 0 до 29
; портит аккумулятор, arg0w, arg1w
.proc locate_in_vpage_proc
	store arg2b, arg1b		; перемещаем arg0b в arg1w
	store arg3b, #0			; зануляем верхний байт arg1w
	store arg1b, #0			; зануляем верхний байт в arg0w
	MULT_WORD_BY_32 arg0w	; умножение arg1b * 32
	ADD_WORD_TO_WORD arg0w, arg1w	; в arg0w - адрес arg0b + arg1b * 32
	store_addr arg1w, PPU_SCR0
	ADD_WORD_TO_WORD arg0w, arg1w ; добавляем адрес PPU_SCR0
	lda PPU_STATUS
	lda arg1b
	sta PPU_ADDR
	lda arg0b
	sta PPU_ADDR
	rts
.endproc