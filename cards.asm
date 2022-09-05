    IDEAL
    DOSSEG
    MODEL small
    STACK 200h
    
    INCLUDE "random.inc"
    INCLUDE "misc.inc"
    INClUDE "video.inc"
    INCLUDE "ai.inc"
    INCLUDE "globals.inc"
    
    DEBUG       EQU 0
    
    DATASEG

    ; Card deck structure
    Deck        DB '2',03,'3',03,'4',03,'5',03,'6',03 
                DB '2',04,'3',04,'4',04,'5',04,'6',04 
                DB '2',05,'3',05,'4',05,'5',05,'6',05 
                DB '2',06,'3',06,'4',06,'5',06,'6',06
                DB 'A',03,'7',03,'8',03,'9',03,'0',03,'J',03,'Q',03,'K',03 
                DB 'A',04,'7',04,'8',04,'9',04,'0',04,'J',04,'Q',04,'K',04 
                DB 'A',05,'7',05,'8',05,'9',05,'0',05,'J',05,'Q',05,'K',05 
                DB 'A',06,'7',06,'8',06,'9',06,'0',06,'J',06,'Q',06,'K',06,'$$'
    TopIdx      DW Deck

    ; As cards are used, Discard grows.  We track the active trick as the cards
    ; between the Trick pointed and TopDiscard.
    Discard     DB 2*DeckSize DUP(?)
    TopDiscard  DW Discard
    TrickPtr    DW Discard

    Trump       DB ?
    Bid         DB 0
    Trick       DB 0
    Dealer      DB 0
    Pitcher     DB ?
    NumPlayers  DB 2
    
    ; Player tracking
    ; Human is always player 0 and initial dealer
    Players     DW HandSize*MaxPlayers DUP('x?')
    Scores      DB MaxPlayers DUP(0)
    
    ; Various game messages
    PlayerMsg   DB 'Player $'
    TopMsg      DB 'Top of deck: $'
    ScoreMsg    DB ' score: $'
    TrickMsg    DB 'Trick: $'
    BidAsk      DB 'Your bid? $'
    BidMsg      DB ' bids: $'
    BidErrMsg   DB 'Bid must be greater than high bid.$'
    PitcherBidMsg       DB ' wins bidding with: $'
    
    CODESEG

GLOBAL GetIndex:PROC
GLOBAL PrintDeck:PROC
GLOBAL PrintPlayerMsg:PROC
GLOBAL ShuffleDeck:PROC
GLOBAL DrawCard:PROC
GLOBAL PrintCard:PROC
GLOBAL DrawHands:PROC
GLOBAL PrintHands:PROC
GLOBAL PlayerBid:PROC
GLOBAL GetBids:PROC

ProgramStart:   
    mov ax, @data
    mov ds, ax

    call RandInit
gameloop:       
    call ShuffleDeck

    call DrawHands
    call PrintHands

    ; Print trick info
    mov dx, OFFSET TrickMsg
    mov ah, 9
    int 21h
    mov al, [Trick]
    call PrintDecByte
    call PrintCrLf

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
    
    call GetBids
    call PrintCrLf

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
    mov dl, [Bid]
    add dl, '0'
    int 21h                             ; and bid for trick
    call PrintCrLf

    ; exit to DOS
    call CleanExit


    
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
@@swaps:
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
    loop @@swaps

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
    push ax
    push dx
    mov dx, ax
    xchg dh, dl
    mov ah, 2
    ; if it's a 0 for 10, add an extra leading 1
    cmp dl, '0'
    jnz plain
    push dx
    mov dl, '1'
    int 21h
    pop dx
plain:  
    int 21h
    xchg dh, dl
    int 21h
    pop dx
    pop ax
    ret
    ENDP PrintCard

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
    mov cl, [NumPlayers]
    push ax
dh1:
    call DrawCard
    mov [di], ax                ; put card in player hand
    add di, HandSize*2          ; move to the next player
    loop dh1
    pop ax
    add bx, 2
    cmp bx, HandSize*2
    jnz dh0

    pop cx
    pop bx
    pop ax
    pop di
    ret
    ENDP DrawHands
    
    PROC PrintHands
    push si
    push ax
    push bx
    push cx
    push dx
    mov si, OFFSET Players
    mov bl, 0
lp:
    mov al, bl
    call PrintPlayerMsg
    mov ah, 2
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov cx, HandSize
lph:    
    lodsw
    call PrintCard
    mov ah, 2
    mov dl, ' '
    int 21h
    loop lph
    call PrintCrLf
    inc bl
    cmp bl, [NumPlayers]
    jnz lp
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret
    ENDP PrintHands

; al is the player index
PROC PrintPlayerMsg
    push dx
    push ax
    mov dx, OFFSET PlayerMsg
    mov ah, 9
    int 21h
    mov dl, '1'
    add dl, al
    mov ah, 2
    int 21h
    pop ax
    pop dx
    ret
ENDP PrintPlayerMsg

; Ask players for bids, ending on the dealer.
; Resulting bid value stored in Bid variable.
; Player 0 (player) is asked for bid via kbd.
PROC GetBids
    ; Add 1 to dealer index and mod based on number of players
    ; If that player is the human, prompt for bid.
    ; If that player is an AI, run the bid processing based on hand and
    ; discards.  Depth of discard knowledge is level of difficulty.  Full
    ; card counting should be pretty hard.
    ; End when all players have bid.
    push ax
    push cx
    mov cl, [Dealer]
@@nextbid:
    inc cl
    cmp cl, [NumPlayers]        ;
    jb @@checkplayer            ; modulus
    sub cl, [NumPlayers]        ;
@@checkplayer:
    cmp cl, 0           ; is this the human?
    je @@playerinput
    mov al, cl
    call AIBid
    cmp cl, [Dealer]    ; are we done with bidding?
    je @@finished
    jmp @@nextbid
@@playerinput:
    call PlayerBid
    cmp cl, [Dealer]    ; are we done with bidding?
    je @@finished
    jmp @@nextbid
@@finished:
    pop cx
    pop ax
    ret
ENDP GetBids

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
    pop dx
    pop bx
    pop ax
    ret
ENDP PlayerBid

END

