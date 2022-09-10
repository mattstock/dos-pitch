    IDEAL
    DOSSEG
    MODEL small
    STACK 200h

    ; TASM macros and includes
    INCLUDE "\tasm\imacros.mac"
    INCLUDE "\tasm\bios.inc"
    INCLUDE "\tasm\ibios.mac"
    INCLUDE "\tasm\dos.inc"
    INCLUDE "\tasm\idos.mac"
    INCLUDE "\tasm\kbd.inc"
    
    INCLUDE "random.inc"
    INCLUDE "misc.inc"
    INClUDE "video.inc"
    INCLUDE "ai.inc"
    INCLUDE "globals.inc"
    
    DEBUG       EQU 0
    
    DATASEG

    ; tracking random handler stuff
    PspAddress          DW ?
    Old1BHandlerSeg     DW ?
    Old1BHandlerOfs     DW ?
    Old00HandlerSeg     DW ?
    OldooHandlerOfs     DW ?
    
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
    
    Trump       DB ?
    Bid         DB 0
    Trick       DB 0
    Dealer      DB 0
    Pitcher     DB ?
    NumPlayers  DB 4
    
    ; Player tracking
    ; Human is always player 0 and initial dealer
    Players     DW HandSize*MaxPlayers DUP('x?')
    Scores      DB MaxPlayers DUP(0)

    CurrentP    DB 0                            ; current player during trick
    CurrentDis  DW HandSize*MaxPlayers DUP(?)
    CurrentCnt  DB 0
    
    ; Trick tracking
    DiscardP1   DW HandSize*MaxPlayers DUP('??')
    DiscardP2   DW HandSize*MaxPlayers DUP('??')
    DiscardP3   DW HandSize*MaxPlayers DUP('??')
    DiscardP4   DW HandSize*MaxPlayers DUP('??')
    DisP1Cnt    DB 0
    DisP2Cnt    DB 0
    DisP3Cnt    DB 0
    DisP4Cnt    DB 0
    
    ; Various game messages
    PlayerMsg   DB 'Player $'
    TopMsg      DB 'Top of deck: $'
    ScoreMsg    DB ' score: $'
    TrickMsg    DB 'Trick: $'
    BidAsk      DB 'Your bid? $'
    TrumpAsk    DB 'Your trump suit? $'
    BidMsg      DB ' bids: $'
    CardMsg     DB 'Card? $'
    CardsMsg    DB 'Your cards: $'
    BidErrMsg   DB 'Bid must be greater than high bid.$'
    PitcherBidMsg       DB ' chooses trump $'
    
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
GLOBAL PlayerTrump:PROC
GLOBAL GetBids:PROC
GLOBAL AnnounceStart:PROC
GLOBAL RoundReport:PROC
GLOBAL HumanPlay:PROC
GLOBAL ClearCards:PROC
GLOBAL ReportWin:PROC

    
ProgramStart:
    ; command line args are here
    ;80h length, 81h is string
    mov [PspAddress], es

    ; ctrl-c handler
    SetVector 23h, <seg Terminate>,<offset Terminate>
    
    mov ax, @data
    mov ds, ax

    call RandInit
    call ShuffleDeck

@@handloop:
    call DrawHands
    call PrintHands

    call GetBids

    ; if player won, ask for trump
    cmp [Pitcher], 0 
    jne @@noprompt
    call PlayerTrump
@@noprompt:
    call AnnounceStart    ; Print winner of bidding process

    ; ch tracks round loop, cl tracks trick loop
    mov ch, HandSize
@@roundloop:
    mov cl, [Pitcher]
@@trick:
    cmp cl, 0
    jne @@aip
    call HumanPlay
    jmp @@next
@@aip:
    call AiPlay
@@next:
    inc cl
    cmp cl, [NumPlayers]
    jne @@norot
    xor cl, cl
@@norot:
    cmp cl, [Pitcher]
    jnz @@trick
    
    ; for now, don't score the result
    ;call ReportWin
    ;call ClearCards     ; put in discard for winner
    ;mov [Pitcher], al   ; change who goes first
    
    dec ch
    jnz @@roundloop
    
;    call ScoreResults
    call RoundReport

    ; exit to DOS
    call Terminate


PROC Terminate
    DosCall DOS_TERMINATE_EXE
ENDP Terminate
    
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
    ; if it's a 0 for 10, add an extra leading 1
    cmp dl, '0'
    jnz plain
    push dx
    mov dl, '1'
    DosCall DOS_WRITE_CHARACTER
    pop dx
plain:  
    DosCall DOS_WRITE_CHARACTER
    xchg dh, dl
    DosCall DOS_WRITE_CHARACTER
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
@@dh0:    
    mov di, OFFSET Players
    add di, bx                  ; which card are we working with?
    xor cx, cx
    mov cl, [NumPlayers]
    push ax
@@dh1:
    call DrawCard
    mov [di], ax                ; put card in player hand
    add di, HandSize*2          ; move to the next player
    loop @@dh1
    pop ax
    add bx, 2
    cmp bx, HandSize*2
    jnz @@dh0

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
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP RoundReport

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
    mov bl, [CurrentCnt]
    xor bh, bh
    mov [CurrentDis+bx], ax
    inc [CurrentCnt]
    mov [Players+si], 'xx'
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ENDP HumanPlay

PROC ClearCards
    ret
ENDP ClearCards

PROC ReportWin
    ret
ENDP ReportWin
    
END

