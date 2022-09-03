    IDEAL
    DOSSEG
    MODEL small
    STACK 200h
    
    INCLUDE "random.inc"
    INCLUDE "misc.inc"
    
    Heart       EQU 03h
    Diamond     EQU 04h
    Club        EQU 05h
    Spade       EQU 06h

    DeckSize    EQU 32
    
    DEBUG       EQU 0
    
    DATASEG
    
    FullDeck    DB '2',03,'3',03,'4',03,'5',03,'6',03 
                DB '2',04,'3',04,'4',04,'5',04,'6',04 
                DB '2',05,'3',05,'4',05,'5',05,'6',05 
                DB '2',06,'3',06,'4',06,'5',06,'6',06
    Deck        DB 'A',03,'7',03,'8',03,'9',03,'0',03,'J',03,'Q',03,'K',03 
                DB 'A',04,'7',04,'8',04,'9',04,'0',04,'J',04,'Q',04,'K',04 
                DB 'A',05,'7',05,'8',05,'9',05,'0',05,'J',05,'Q',05,'K',05 
                DB 'A',06,'7',06,'8',06,'9',06,'0',06,'J',06,'Q',06,'K',06,'$$'

    TopIdx DW Deck

    LABEL Players WORD
    Player1 DW 5 DUP('x?')
    Player2 DW 5 DUP('x?')
    Player3 DW 5 DUP('x?')
    Player4 DW 5 DUP('x?')

    PlayerMsg DB 'Player $'
    Oops DB 'Something bad happend$'
    
    CODESEG
        GLOBAL GetIndex:PROC
        GLOBAL PrintDeck:PROC
        GLOBAL ShuffleDeck:PROC
        GLOBAL DrawCard:PROC
        GLOBAL PrintCard:PROC
        GLOBAL DrawHands:PROC
        GLOBAL PrintHands:PROC

ProgramStart:   
    mov ax, @data
    mov ds, ax
    mov es, ax
    ASSUME es:@data, ds:@data

    call RandInit
    call ShuffleDeck

    mov ax, 4
    call DrawHands
    call PrintHands
    
    ; exit to DOS
    mov ah, 4ch
    mov al, 0
    int 21h

    ; PrintDeck
    PROC PrintDeck
    push dx
    push ax
    mov dx,OFFSET Deck
    mov ah, 9
    int 21h
    pop ax
    pop dx
    ret
    ENDP PrintDeck
    
    ; ShuffleDeck generates a random deck from the cards
    PROC ShuffleDeck
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    mov bx, OFFSET Deck
    mov cx, 200                 ; swap number of times
s1:
    call GetIndex
    shl ax, 1
    mov di, ax

    call GetIndex
    shl ax, 1
    mov si, ax

    ; Swap the two cards
    mov dx, [bx+si]
    mov ax, [bx+di]
    mov [bx+si], ax
    mov [bx+di], dx
    loop s1

    ; Reset to the top of the deck
    mov [TopIdx], OFFSET Deck
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    ENDP ShuffleDeck

    ; Pick a card and return index in AX
    PROC GetIndex
    push dx
    call Rand
    mov ah,0
    mov dl, DeckSize
    idiv dl
    xchg ah,al
    pop dx
    mov ah, 0
    ret
    ENDP GetIndex

    ; Grab top card from the deck
    ; Returns AX with card
    PROC DrawCard
    push bx
    mov bx, [TopIdx]
    mov ax, [bx]
    add [TopIdx],2
    pop bx
    xchg ah, al
    ret
    ENDP DrawCard

    ; Print card in AX
    PROC PrintCard
    push dx
    mov dx, ax
    xchg dh, dl
    mov ah, 2
    int 21h
    xchg dh, dl
    int 21h
    pop dx
    ret
    ENDP PrintCard

    ; Draw cards for number of players in AL
    PROC DrawHands
    push di
    push ax
    push bx
    push cx

    mov bx, 0
dh0:    
    mov di, OFFSET Players
    add di, bx                  ; which card are we working with?
    xor cx, cx
    mov cl, al
    push ax
dh1:
    call DrawCard
    mov [di], ax                ; put card in player hand
    add di, 5*2                 ; move to the next player
    loop dh1
    pop ax
    add bx, 2
    cmp bx, 10
    jnz dh0

    pop cx
    pop bx
    pop ax
    pop di
    ret
    ENDP DrawHands
    
    ; Print cards in hand for number of players in AL
    PROC PrintHands
    push si
    push ax
    push bx
    push cx
    push dx
    mov si, OFFSET Players
    mov bh, al
    mov bl, bh
lp:
    mov dx, OFFSET PlayerMsg
    mov ah, 9
    int 21h
    mov dl, '1'
    add dl, bh
    sub dl, bl
    mov ah, 2
    int 21h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov cx, 5
lph:    
    lodsw
    call PrintCard
    mov ah, 2
    mov dl, ' '
    int 21h
    loop lph
    call PrintCrLf
    dec bl
    jnz lp
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret
    ENDP PrintHands
  
END

