    DOSSEG
    .MODEL small
    .STACK 200h

    Heart   EQU 03h
    Spade   EQU 06h
    Club    EQU 05h
    Diamond EQU 04h

    .DATA

    Suits DB 03,04,05,06
    Cards DB 'A234567890JQK'
    NumPlayers DB ? ; 2 or 4
    
    .CODE
    EXTRN Rand:PROC
    EXTRN RandInit:PROC
    
ProgramStart PROC NEAR
    mov ax, @data
    mov ds, ax
    call RandInit

    call RandCard
    
    mov ah, 4ch
    int 21h
    ENDP ProgramStart

    ; Pick a random card
RandCard PROC NEAR
    call Rand
    mov ah, 0
    mov cl, 13
    div cl              ; ah is a card index
    mov bl, ah
    mov bh, 0
    mov dh, [Cards+bx]
    call Rand
    shr ax, 14          ; 4 suits so only use top 2 bits
    mov bx, ax
    mov dl, [Suits+bx]
    mov ax, dx
    ret
    ENDP RandCard
    
;;; AX is the hex number to be printed
PrintHex PROC NEAR
    mov cl, 16
loop2:
    sub cl, 4
    mov dx, ax
    shr dx, cl
    and dl, 0fh
    push ax
    mov ah, 2
    cmp dl, 9h
    jg alpha
    add dl, '0'
    jmp p1
alpha:
    sub dl, 10
    add dl, 'A'
p1:     
    int 21h
    pop ax
    cmp cl, 0
    jnz loop2
    push ax
    mov ah, 2
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h
    pop ax
    ret
    ENDP PrintHex
    
END
