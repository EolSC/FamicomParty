.include "../../src/include/game_constants.inc"	; подключим заголовк game_constants.inc

.BYTE DATA_PALETTE_ENVIRONMENT ; номер палитры в банке палитр (BANK_PALETTES_01)  
.BYTE DATA_SPRITE_ENVIRONMENT  ; банк спрайтов(может быть разным)
.BYTE BANK_TILEMAPS_02         ; банк тайлов комнаты(все тайлы всегда в одном банке с адреса A000)
.BYTE DATA_SPRITE_ENVIRONMENT  ; индекс в таблице спрайтов
.BYTE 2, 2 ; размеры комнаты в тайлах, X*Y
; номера тайлов комнаты в таблице тайлов. Будет N= X*Y записей
.BYTE DATA_TILEMAP_ENVIRONMENT1, DATA_TILEMAP_ENVIRONMENT2 
.BYTE DATA_TILEMAP_ENVIRONMENT3, DATA_TILEMAP_ENVIRONMENT4 
.BYTE 1	 ; число дверей в комнате 
.BYTE 1	 ; число прямоугольников проходимости(максимально 4)
; данные о двери - 1  
.BYTE 0 ; номер комнаты в которую дверь ведет(с 0) 
.BYTE 0 ; номер двери в комнате в которую попадем (с 0)
.BYTE 0 ; x координата камеры при входе через эту дверь
.BYTE 0 ; y координата камеры при входе через эту дверь
; ... таких дверей N

; данные о прямоугольниках проходимости
.BYTE 0, 0, 0, 0, 0 ; формат (x1, y1, x2,y2), в координатах комнаты. Задает допустимый прямоугольник движения игрока

