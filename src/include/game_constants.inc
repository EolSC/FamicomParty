.include "common_constants.inc"
; *****************
; Блок игровых констант
; разделенных на блоки по игровым
; подсистемам
; *****************

; **********************
; *  Работа с памятью  *
; **********************

; размер блока данных для чтения
DATA_BLOCK_SIZE = $10

; **********************
; *  Текстовый движок  *
; **********************

; метки начала и конца блока спрайтов дефолтного шрифта
.import LettersStart
.import LettersEnd

; Символ, обозначающий переход на новую строку в текстовом движке
NEWLINE = $A

; Максимальное количество напечатанных символов в строке текста
; текстовый движок печатает по 1 букве, при окончании вывода текущей строки
; движок увеличивает printed_text_length до MAX_TEXT_SIZE чтобы можно было 
; понять что вывод закончен и можно переходить к следующей строке
MAX_TEXT_SIZE = $FF

; Размер текстовой области в интро
TEXT_AREA_SIZE = $DF



LETTERS_START = LettersStart
LETTERS_END = LettersEnd

; Размер блока спрайтов дефолтного шрифта в блоках по 16 байт
LETTERS_SIZE = (LETTERS_END - LETTERS_START) / 16
; Смещене адресов спрайтов текста в PPU в катсценах
; распологает графику текста под текущим изображением катсцены
ASCII_OFFSET = $210        ; смещение для ASCII символов относительно 0
TEXT_SPRITES_OFFSET_PPU = $A10 ; смещение для спрайтов текста в PPU с учетом остальной графики

; Немного математики тут. Т.к. спрайты текста у нас лежат по произвольному смещению,
; код символа не соответствует коду ASCII
; Чтобы вывод текста работал верно нужно прибавить к коду символа дельту 
; которая считается как (TEXT_SPRITES_OFFSET_PPU - $10) - ASCII_OFFSET
; Это разница между текущим кодом символа и реальным смещением спрайта
; $10 вычитаем потому что в спрайтах текста нет символа "пробел", мы
; предполагаем что в PPU будет пусто, и двигаем текст на $10 чтобы оставить этот проблел
; Полученную дельту в нужно поделить на $10 т.к. каждый спрайт у нас 8х8 = 8 байт
ASCII_TO_SPRITE_OFFSET = ((TEXT_SPRITES_OFFSET_PPU) - ASCII_OFFSET)/$10

; Символ, которым очищается текстовая область
EMPTY_TEXT_SPRITE = $20 + ASCII_TO_SPRITE_OFFSET

; Адрес с которого в память грузятся спрайты текста
; грузим c 
TEXT_SPRITES_ADDRESS_IN_PPU = PPU_BGR_TBL + TEXT_SPRITES_OFFSET_PPU

TEXT_SPRITES_END_IN_PPU = TEXT_SPRITES_ADDRESS_IN_PPU + LETTERS_SIZE * 16

TEXT_BOX_X		 = 4	; координаты текстовой области в интро
TEXT_BOX_Y_UPPER = 19

TEXT_COUNT = 5			; число строк в интро


; ******************************
; *  Адреса данных в таблицах  *
; ******************************

DATA_SPRITE_COPYRIGHT = $01   ; Спрайт интро экрана
DATA_TILEMAP_COPYRIGHT = $00  ; Спрайт тайлмапа интро
DATA_PALETTE_COPYRIGHT = $20  ; Номер палитры для интро

DATA_SPRITE_CUTSCENE_01 = $00   ; Спрайт катсцены 1
DATA_TILEMAP_CUTSCENE_01 = $01  ; Тайлмап катсцены 1
DATA_PALETTE_CUTSCENE_01 = $10  ; Номер палитры для катсцены

DATA_SPRITE_CUTSCENE_02 = $01   ; Спрайт катсцены 2
DATA_TILEMAP_CUTSCENE_02 = $02  ; Тайлмап катсцены 2
DATA_PALETTE_CUTSCENE_02 = $11  ; Номер палитры для катсцены

DATA_SPRITE_CUTSCENE_03 = $02   ; Спрайт катсцены 3
DATA_TILEMAP_CUTSCENE_03 = $03  ; Тайлмап катсцены 3
DATA_PALETTE_CUTSCENE_03 = $12  ; Номер палитры для катсцены

DATA_SPRITE_CUTSCENE_04 = $03   ; Спрайт катсцены 4
DATA_TILEMAP_CUTSCENE_04 = $04  ; Тайлмап катсцены 4
DATA_PALETTE_CUTSCENE_04 = $13  ; Номер палитры для катсцены

DATA_SPRITE_TITLE_LOGO   = $00   ; Спрайт экрана Biohazard
DATA_TILEMAP_TITLE_LOGO  = $05  ; Тайлмап Biohazard
DATA_PALETTE_LOGO        = $1   ; Номер палитры для лого Biohazard

DATA_SPRITE_SAVESCREEN   = $01   ; Спрайт экрана загрузки сохранения
DATA_TILEMAP_SAVESCREEN = $06  ; Тайлмап экрана загрузки сохранения

DATA_SPRITE_DIFFICULTY   = $00  ; Спрайт экрана выбора сложности
DATA_TILEMAP_DIFFICULTY  = $00  ; Тайлмап выбора сложности

DATA_SPRITE_ENVIRONMENT   = $01  ; Спрайт фона особняка
DATA_TILEMAP_ENVIRONMENT1 = $01  ; Тайлмап фона 1
DATA_TILEMAP_ENVIRONMENT2 = $02  ; Тайлмап фона 2
DATA_TILEMAP_ENVIRONMENT3 = $03  ; Тайлмап фона 3
DATA_TILEMAP_ENVIRONMENT4 = $04  ; Тайлмап фона 4
DATA_PALETTE_ENVIRONMENT  = $18  ; Палитра фона


; ******************************
; * Состояние игры             *
; ******************************

GAME_STATE_INTRO = $00      ; Экран интро
GAME_STATE_CUTSCENE1 = $01  ; Катсцены 1-4
GAME_STATE_CUTSCENE2 = $02
GAME_STATE_CUTSCENE3 = $03
GAME_STATE_CUTSCENE4 = $04
GAME_STATE_LOAD_GAME_SELECTED = $05 ; Выбрана опция LoadGame на стартовом экране
GAME_STATE_NEW_GAME_SELECTED  = $06 ; Выбрана опция NewGame на стартовом экране
GAME_STATE_INTRO_CUTSCENE     = $07 ; Стартовая катсцена


; Максимальные индексы текста для каждой катсцены
MAX_TEXT_CUTSCENE_01 = $06
MAX_TEXT_CUTSCENE_02 = $0A
MAX_TEXT_CUTSCENE_03 = $0E
MAX_TEXT_CUTSCENE_04 = $16

; Сложность игры
; хранится в переменной player_state_flags
GAME_DIFFICULTY_EASY          = %00000001 ; Выбрана сложность Easy
GAME_DIFFICULTY_HARD          = %00000000 ; Выбрана сложность Hard

; Читы
CHEAT_SKIP_ALL_INTRO = %00000001        ; Чит на пропуск всей интро-секции. Сразу начинает новую игру со сложностью Easy



TILEMAP_ORIENT_DL = %00000000 ; левый нижний угол
TILEMAP_ORIENT_DR = %00000001 ; правый нижний угол
TILEMAP_ORIENT_UL = %00000010 ; левый верхний угол
TILEMAP_ORIENT_UR = %00000011 ; правый верхний угол