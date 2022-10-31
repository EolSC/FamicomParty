.include "include/ppu_constants.inc"
.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
    SEI             ; disable interrups
    CLD             ; Disable decimal mode bit
    LDX #$00        ; 0 -> X
    STX PPUCTRL     ; 0 -> PPUCTRL
    STX PPUMASK     ; 0 -> PPUMASK

vblankwait:         ; Waiting for PPU to initialize
    BIT PPUSTATUS
    BPL vblankwait
    JMP main
.endproc