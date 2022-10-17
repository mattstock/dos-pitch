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

    VsMsg               DB ' vs $'

    DebugMsg            DB 'Debugging $'
    
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

    ; al is player
    ; look up in the CurrentTrick and print the card
PROC PrintPlayerTrick
    push ax
    call TrickLookup
    call PrintCard
    pop ax
    ret
ENDP PrintPlayerTrick

    ; al is the best index so far
    ; ah is the one we just looked at
PROC PrintCompare
    push ax
    push dx

    push ax
    call PrintPlayerTrick
    mov dx, OFFSET VsMsg
    DosCall DOS_WRITE_STRING
    pop ax
    mov al, ah
    call PrintPlayerTrick
    mov dl, ':'
    DosCall DOS_WRITE_CHARACTER
    mov dl, ' '
    DosCall DOS_WRITE_CHARACTER

    pop dx
    pop ax
    ret
ENDP PrintCompare    

    ; print al
PROC PrintChar
    push ax
    push dx
    mov dl, al
    DosCall DOS_WRITE_CHARACTER
    pop dx
    pop ax
    ret    
ENDP PrintChar

    ; dump everything about the current scoring state
PROC DebugScoring
    push ax
    push dx
    mov dx, OFFSET Separator
    DosCall DOS_WRITE_STRING
    call PrintCrLf
    mov dx, OFFSET DebugMsg
    DosCall DOS_WRITE_STRING
    mov dx, OFFSET TrickMsg
    DosCall DOS_WRITE_STRING
    mov dl, [Trick]
    add dl, '1'
    DosCall DOS_WRITE_CHARACTER
    call PrintCrLf
    ; Print High and Player
    mov dx, OFFSET HighMsg
    DosCall DOS_WRITE_STRING
    mov dl, [HighCard]
    add dl, '0'
    DosCall DOS_WRITE_CHARACTER
    mov dl, ' '
    DosCall DOS_WRITE_CHARACTER
    mov dl, [HighPlayer]
    add dl, '1'
    DosCall DOS_WRITE_CHARACTER
    call PrintCrLf
    
    ; Print Low and Player
    mov dx, OFFSET LowMsg
    DosCall DOS_WRITE_STRING
    mov dl, [LowCard]
    add dl, '0'
    DosCall DOS_WRITE_CHARACTER
    mov dl, ' '
    DosCall DOS_WRITE_CHARACTER
    mov dl, [LowPlayer]
    add dl, '1'
    DosCall DOS_WRITE_CHARACTER
    call PrintCrLf

    ; Print Jack Player
    mov dx, OFFSET JackMsg
    DosCall DOS_WRITE_STRING
    mov dl, [JackPlayer]
    cmp dl, '?'
    je @@nojackforyou
    add dl, '1'
    DosCall DOS_WRITE_CHARACTER
    jmp @@game
@@nojackforyou:
    mov dl, '-'
    DosCall DOS_WRITE_CHARACTER
@@game:
    call PrintCrLf
    
    ; Print Game sum for each Player

    DosCall DOS_CHARACTER_INPUT
    
    mov dx, OFFSET Separator
    DosCall DOS_WRITE_STRING
    call PrintCrLf
    pop dx
    pop ax
    ret
ENDP DebugScoring

    
END
    
