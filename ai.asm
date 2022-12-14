    IDEAL
    DOSSEG
    MODEL small

    INCLUDE "\tasm\imacros.mac"
    INCLUDE "\tasm\bios.inc"
    INCLUDE "\tasm\ibios.mac"
    INCLUDE "\tasm\dos.inc"
    INCLUDE "\tasm\idos.mac"

    INCLUDE "ai.inc"
    INCLUDE "globals.inc"
    INCLUDE "player.inc"
    INCLUDE "misc.inc"

GLOBAL AddToTrick:PROC    
GLOBAL PrintCard:PROC    

    DATASEG

    Counters    DB 4 DUP(0)
    TmpPlayer   DB ?
    
    CODESEG
    
    ; player index in al
    ;
    ; We need to evaluate each suit that we have in our hand to determine
    ; if we want to try to bid.  The AI should also count cards in the discard
    ; pile if any, if that makes it smarter.  For now, we'll just focus on
    ; the hand in question.
PROC AiBid
    push si
    push di
    push ax
    push bx
    push cx
    mov si, OFFSET Players
    mov [TmpPlayer], al
    cmp al, 0
    je @@basedone
    xor ah, ah
    mov cx, ax
@@getplayer:
    add si, 2*HandSize
    loop @@getplayer
@@basedone:
    mov cx, HandSize
@@look:
    cld
    lodsw               ; al is suit ah is card
    ; Look for cards that make us want to up our bid strength
    cmp ah,'J'
    je @@bidup
    cmp ah,'2'
    je @@bidup
    cmp ah,'A'
    je @@bidup
    jmp @@nobid
@@bidup:
    xor ah, ah
    mov di, ax
    mov al, [Counters+di-Heart]
    inc al
    mov [Counters+di-Heart], al
@@nobid:
    loop @@look

    ; Evaluate each suit
    mov bx, 0
    mov ah, [Counters]          ; start with hearts value
    mov al, 0
@@checkem:
    cmp ah, [Counters+bx]
    jae @@notbig
    mov ah, [Counters+bx]       ; new trump
    mov al, bl
@@notbig:
    inc bx
    cmp bx, 4
    jne @@checkem
    cmp ah, [Bid]               ; Compare our bet suit with the current bid
    jbe @@done
    ; Set up new bit and trump value
    mov [Bid], ah
    mov cl, [TmpPlayer]
    mov [Pitcher], cl
    mov [Trump], al
    add [Trump], Heart
    ; tell player the new bid
    push ax
    mov al, [Pitcher]
    call PrintPlayerMsg
    pop ax
    mov ah, 9
    mov dx, OFFSET BidMsg
    int 21h
    mov ah, 2
    mov dl, [Bid]
    add dl, '0'
    int 21h
    call PrintCrLf
@@done:
    pop cx
    pop bx
    pop ax
    pop di
    pop si
    ret
ENDP AiBid

    ; CurrentPlayer is the player index
PROC AiPlay
    push ax
    push bx
    push cx
    push dx
    push si

    mov al, [CurrentPlayer]
    call PrintPlayerMsg         ; Player x
    mov dx, OFFSET PlayMsg      ; plays
    DosCall DOS_WRITE_STRING

    ; Get AI hand reference into bx
    mov bx, OFFSET Players
    xor ch, ch
    mov cl, [CurrentPlayer]
@@loop:
    add bx, 2*HandSize
    loop @@loop

    ; for now, just pick the first available card
    mov si, 0
@@loop2:
    mov ax, [bx+si]
    cmp ax, 'xx'
    jne @@found
    add si, 2
    cmp si, 2*HandSize
    jne @@loop2
    jmp @@done 
@@found:
    mov [WORD PTR bx+si], 'xx'
    ; ax is the card we picked
    call AddToTrick     
    call PrintCard
@@done:    
    call PrintCrLf
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP AiPlay
    
END
    
