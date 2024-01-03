.include "include/neslib.inc"	; подключим заголовк neslib.inc

; ******************************
; * Сегмент инвентаря          *
; ******************************

; Хранит данные о содержащихся у игрока предметах
; Формат предметов
; 1й байт - тип предмета(0-255)
; 2й байт - количество предметов. Для стакабельных предметов тут число(патроны, лента). Для оружия - количество патронов

.segment "RAM"	

inventory_slot0:    .word 0
inventory_slot1:    .word 0
inventory_slot2:    .word 0
inventory_slot3:    .word 0
inventory_slot4:    .word 0
inventory_slot5:    .word 0
inventory_slot6:    .word 0
inventory_slot7:    .word 0

; резерв под 100 WORD ящика
.res 200

; резерв оставшейся памяти
.res 84



