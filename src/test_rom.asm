.include "include/ppu_constants.inc"

.include "include/header.inc"
	
.segment "CODE"

.proc irq_handler
    RTI
.endproc

.proc nmi_handler
RTI
.endproc

.import reset_handler

BACKGROUND_COLOR = $31
.export main
.proc main
    LDX PPUSTATUS               ; Requesting PPU STATUS to clear address latches 
    LDX #PPU_FIRST_PALETTE      ; Storing first pallete address -> X
    STX PPUADDR                 ; First Palette -> PPUADDR
    LDX #$00                    ; Color index  -> X
    STX PPUADDR                 ; Color index -> PPUADDR
    LDA #BACKGROUND_COLOR       ; Setting BG_COLOR -> A
    STA PPUDATA                 ; A -> PPUDATA, setting bg color
    LDA #%00011110              ; Setting PPUMASK
    STA PPUMASK
forever:
    JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.res 8192
