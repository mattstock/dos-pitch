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

    INCLUDE "player.inc"
    INCLUDE "globals.inc"
    INCLUDE "misc.inc"

    DATASEG

    BidAsk      DB 'Your bid? $'
    TrumpAsk    DB 'Your trump suit? $'
    CardMsg     DB 'Card? $'
    CardsMsg    DB 'Your cards: $'
    BidErrMsg   DB 'Bid must be greater than high bid.$'
    ScoreMsg    DB ' score: $'
    PitcherBidMsg       DB ' chooses trump $'
    PlayerMsg   DB 'Player $'
    HighMsg     DB 'High: $'
    LowMsg      DB 'Low: $'
    JackMsg     DB 'Jack: $'
    GameMsg     DB 'Game: $'
    
    CODESEG
    
; al is the player index
PROC PrintPlayerMsg
    push dx
    push ax
    mov dx, OFFSET PlayerMsg
    DosCall DOS_WRITE_STRING
    mov dl, '1'
    add dl, al
    DosCall DOS_WRITE_CHARACTER
    pop ax
    pop dx
    ret
ENDP PrintPlayerMsg

; Ask the player for a bid
PROC PlayerBid
    push ax
    push bx
    push dx
@@bidask:
    mov dx, OFFSET BidAsk
    mov ah, 9
    int 21h                     ; prompt
    mov ah, 1
    int 21h                     ; wait for 0,1,2,3,4
    sub al, '0'
    cmp al, 0
    jz @@done                   ; pass
    cmp al, [Bid]               ; needs to be larger than current bid
    jbe @@err
    cmp al, 4
    ja @@err
    mov [Bid], al
    mov [Pitcher], 0
    jmp @@done
@@err:
    mov dx, OFFSET BidErrMsg
    mov ah, 9
    int 21h                     ; for shame
    call PrintCrLf
    jmp @@bidask
@@done:
    call PrintCrLf
    pop dx
    pop bx
    pop ax
    ret
ENDP PlayerBid

PROC PlayerTrump
    push ax
    push dx
@@trytrump:    
    mov dx, OFFSET TrumpAsk
    mov ah, 9
    int 21h                     ; prompt
    mov ah, 1
    int 21h                     ; wait for d, s, h, c
    cmp al, 's'
    je @@spade
    cmp al, 'd'
    je @@diamond
    cmp al, 'h'
    je @@heart
    cmp al, 'c'
    je @@club
    call PrintCrLf
    jmp @@trytrump
@@spade:
    mov [Trump], Spade
    jmp @@done
@@diamond:
    mov [Trump], Diamond
    jmp @@done
@@club:
    mov [Trump], Club
    jmp @@done
@@heart:
    mov [Trump], Heart
@@done:
    call PrintCrLf
    pop dx
    pop ax
    ret
ENDP PlayerTrump

PROC HumanPlay
    ; print the human player's remaining cards
    push ax
    push bx
    push cx
    push dx
    push si
    mov ah, 9
    mov dx, OFFSET CardsMsg
    int 21h
    mov cx, HandSize
    mov si, OFFSET Players
    cld
@@ploop:
    lodsw
    cmp ah, 'x'
    je @@foo
    push ax
    mov ah, 2
    mov dl, '1'
    add dl, HandSize
    sub dl, cl
    int 21h
    mov dl, ':'
    int 21h
    pop ax
    call PrintCard
    mov ah, 2
    mov dl, ' '
    int 21h
@@foo:
    loop @@ploop
    call PrintCrLf

@@tryagain:
    ; ask for a card
    mov ah, 9
    mov dx, OFFSET CardMsg
    int 21h

    ; Prompt for card
    mov ah, 1
    int 21h
    call PrintCrLf
    ; al is the key
    xor ah, ah
    sub al, '1'
    cmp al, HandSize
    ja @@tryagain
    cmp al, 0
    jb @@tryagain
    shl ax, 1
    mov si, ax
    mov ax, [Players+si]
    cmp ah , 'x'
    je @@tryagain
    ; move the card to the next free slot
    mov [Players+si], 'xx'
    call AddToTrick

    push ax
    mov dx, OFFSET PlayerMsg
    mov ah, 9
    int 21h                     ; player
    mov dl, cl
    add dl, '1'
    mov ah, 2
    int 21h                     ; X
    mov ah, 9
    mov dx, OFFSET PlayMsg
    int 21h                     ; plays
    pop ax
    call PrintCard
    call PrintCrLf
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP HumanPlay

PROC AnnounceStart
    push ax
    push dx
    mov dx, OFFSET PlayerMsg
    mov ah, 9
    int 21h
    mov ah, 2
    mov dl, [Pitcher]
    add dl, '1'
    int 21h                             ; print player
    mov ah, 9
    mov dx, OFFSET PitcherBidMsg
    int 21h
    mov ah, 2
    mov dl, [Trump]
    int 21h
    call PrintCrLf
    pop dx
    pop ax
    ret
ENDP AnnounceStart

PROC RoundReport
    push ax
    push bx
    push cx
    push dx
    
    xor bx, bx
    xor cx, cx
@@spl:
    mov al, cl
    call PrintPlayerMsg
    mov dx, OFFSET ScoreMsg
    mov ah, 9
    int 21h
    mov bx, OFFSET Scores
    add bx, cx
    mov al, [bx]
    call PrintHexByte
    call PrintCrLf
    inc cl
    cmp cl, [NumPlayers]
    jne @@spl

    mov dx, OFFSET HighMsg
    mov ah, 9
    int 21h
    mov al, [HighPlayer]
    call PrintPlayerMsg
    call PrintCrLf

    mov dx, OFFSET LowMsg
    mov ah, 9
    int 21h
    mov al, [LowPlayer]
    call PrintPlayerMsg
    call PrintCrLf

    mov dx, OFFSET JackMsg
    mov ah, 9
    int 21h
    mov al, [JackPlayer]
    call PrintPlayerMsg
    call PrintCrLf

    mov dx, OFFSET GameMsg
    mov ah, 9
    int 21h

    call PrintCrLf

    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP RoundReport
    
END
    
