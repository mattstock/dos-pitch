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
    INCLUDE "player.inc"

    DATASEG

    ; tracking random handler stuff
    PspAddress          DW ?
    Old1BHandlerSeg     DW ?
    Old1BHandlerOfs     DW ?
    Old00HandlerSeg     DW ?
    Old00HandlerOfs     DW ?
    
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

    ; debug output of current trick pile
PROC PrintTrick
    push ax
    push dx
    mov dx, OFFSET CurrentTrick
    DosCall DOS_WRITE_STRING
    call PrintCrLf
    pop dx
    pop ax
    ret
ENDP PrintTrick
        
PROC PrintHands
    push si
    push ax
    push bx
    push cx
    push dx
    mov si, OFFSET Players
    mov bl, 0
@@lp:
    mov al, bl
    call PrintPlayerMsg
    mov dl, ':'
    DosCall DOS_WRITE_CHARACTER
    mov dl, ' '
    DosCall DOS_WRITE_CHARACTER
    mov cx, HandSize
@@lph:    
    lodsw
    call PrintCard
    mov dl, ' '
    DosCall DOS_WRITE_CHARACTER
    loop @@lph
    call PrintCrLf
    inc bl
    cmp bl, [NumPlayers]
    jnz @@lp
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret
ENDP PrintHands

    ; al is the best index so far
    ; ah is the one we just looked at
PROC PrintCompare
    push ax
    push bx
    push cx
    push dx
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP PrintCompare    
    
END
    
