PPUSTATUS = $2002           ; Mapped IO for PPU status
PPUCTRL = $2000             ; Mapped IO for PPU control
PPUMASK = $2001             ; PPU mask 

; PPU mask bits values 
; Bit #	Effect
; 0	Greyscale mode enable (0: normal color, 1: greyscale)
; 1	Left edge (8px) background enable (0: hide, 1: show)
; 2	Left edge (8px) foreground enable (0: hide, 1: show)
; 3	Background enable
; 4	Foreground enable
; 5	Emphasize red
; 6	Emphasize green
; 7	Emphasize blue

PPUADDR = $2006             ; Address which points to PPU data read/write location
PPUDATA = $2007             ; Mapped IO for writing data to selected PPU address

PPU_FIRST_PALETTE = $3F     ; NES PPU first palette memory location
                            ; More about NES palettes - https://www.nesdev.org/wiki/PPU_palettes