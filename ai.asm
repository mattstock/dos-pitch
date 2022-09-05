    IDEAL
    DOSSEG
    MODEL small

    INCLUDE "ai.inc"
    INCLUDE "globals.inc"
    INCLUDE "misc.inc"

    ; For debug
GLOBAL PrintCard:PROC
    
    DATASEG

    Counters    DB 4 DUP(0)
    DebMsg      DB 'I found a $'
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
    call PrintCard
    call PrintCrLf
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
@@done:
    pop cx
    pop bx
    pop ax
    pop di
    pop si
    ret
ENDP AiBid

END
    
