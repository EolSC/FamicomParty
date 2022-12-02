.include "include/neslib.inc"	; подключим заголовк neslib.inc

; ******************************
; * Сегмент данных движка карт *
; ******************************

; Хранит данные о состоянии карты - собранных предметах, убитых врагах и т.д.
; Удобно разделить игру на 10 локаций, о каждой из которых мы храним 32 байта
; флагов. Это позволяет хранить данные о 256 событиях/предметах или точках интереса

.segment "RAM"	

; 320 байт под 10 локаций
.res 320
; Резерв под остальные данные - флаги состояния дверей
.res 80
