    DOSSEG
    .MODEL small
    .STACK 200h

    Heart   EQU 03h
    Diamond EQU 04h
    Club    EQU 05h
    Spade   EQU 06h

    .DATA

    Suits DB 03,04,05,06
    Cards DB 'A234567890JQK'
    NumPlayers DB ? ; 2 or 4
    
    .CODE
    EXTRN Rand:PROC
    EXTRN RandInit:PROC
    EXTRN PrintHex:PROC
    
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
    
    
END
