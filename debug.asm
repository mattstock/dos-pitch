    IDEAL
    DOSSEG
    MODEL small

    ; TASM macros and includes
    INCLUDE "\tasm\imacros.mac"
    INCLUDE "\tasm\bios.inc"
    INCLUDE "\tasm\ibios.mac"
    INCLUDE "\tasm\dos.inc"
    INCLUDE "\tasm\idos.mac"
    INCLUDE "\tasm\kbd.inc"

    INCLUDE "debug.inc"
    INCLUDE "globals.inc"
    INCLUDE "misc.inc"

    DATASEG

    CODESEG
    
    ; PrintDeck
PROC PrintDeck
    push dx
    push ax
    mov dx,OFFSET Deck
    DosCall DOS_WRITE_STRING
    pop ax
    pop dx
    ret
ENDP PrintDeck

END
    
