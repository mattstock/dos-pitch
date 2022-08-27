    DOSSEG
    .MODEL small
    .STACK 200h

    Heart   EQU 03h
    Diamond EQU 04h
    Club    EQU 05h
    Spade   EQU 06h

    .DATA

    Cards DB 'A',03,'2',03,'3',03,'4',03,'5',03,'6',03,'7',03
         DB '8',03,'9',03,'0',03,'J',03,'Q',03,'K',03 
         DB 'A',04,'2',04,'3',04,'4',04,'5',04,'6',04,'7',04
         DB '8',04,'9',04,'0',04,'J',04,'Q',04,'K',04 
         DB 'A',05,'2',05,'3',05,'4',05,'5',05,'6',05,'7',05
         DB '8',05,'9',05,'0',05,'J',05,'Q',05,'K',05 
         DB 'A',06,'2',06,'3',06,'4',06,'5',06,'6',06,'7',06
         DB '8',06,'9',06,'0',06,'J',06,'Q',06,'K',06 
    Deck DB 52 DUP(?)
    Msg DB 'This is a test string$'
    
    .CODE
    EXTRN Rand:PROC
    EXTRN RandInit:PROC
    EXTRN PrintHex:PROC
    EXTRN PrintHexByte:PROC
    
ProgramStart:   
    mov ax, @data
    mov ds, ax
    mov es, ax
    
;    call RandInit
;    call ShuffleDeck
    mov al, 0e4h
    call PrintHexByte
    mov al, 56h
    call PrintHexByte
    mov ax, 4edah
    call PrintHex
    mov ah, 4ch
    mov al, 0
    int 21h


    PROC PrintDeck
    mov si,OFFSET Deck
    mov cx, 52
s2:
    lodsb
    call PrintHex
    loop s2
    ret
    ENDP PrintDeck

    




    
    ; ShuffleDeck generates a random deck from the cards
    PROC ShuffleDeck
    mov si,OFFSET Deck
    mov cx, 52
    mov dl, 52
s1:
    call Rand
    mov ah,0
    div dl
    push ax
    call PrintHexByte
    pop ax
    xor bx,bx
    mov bl, ah
    mov al, [si+bx]
    call PrintHex
    mov [si+bx], cl
    loop s1
    ret
    ENDP ShuffleDeck
END
