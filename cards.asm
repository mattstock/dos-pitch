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
    Deck DB 104 DUP(?)
    
    .CODE
    EXTRN Rand:PROC
    EXTRN RandInit:PROC
    EXTRN PrintHex:PROC
    
PROC ProgramStart
    mov ax, @data
    mov ds, ax
    mov es, ax
    call RandInit
    call GenerateCards
    mov si,OFFSET Deck
    mov cx, 52
s2:
    lodsw
    mov bx, ax
    mov dl, bl
    mov ah, 2
    int 21h
    mov dl, bh
    int 21h
    mov dl, ','
    int 21h
    loop s2
    mov ah, 4ch
    mov al, 0
    int 21h
ENDP ProgramStart

PROC GenerateCards
    cld
    mov di,OFFSET Deck
    mov bx,OFFSET Suits
    mov dx, 4
s1:     
    mov ah, [bx] ; load suit symbol
    mov cx, 13
    mov si,OFFSET Cards
cardloop:
    lodsb ; pull in card number to AL
    stosw ; write AX with card and suit
    loop cardloop
    inc bx
    dec dx
    jnz s1
    
    ret
    ENDP GenerateCards

    ; Pick a random card
PROC RandCard
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
