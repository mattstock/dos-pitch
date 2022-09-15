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
    INCLUDE "player.inc"
    INCLUDE "globals.inc"
    INCLUDE "debug.inc"
    
    DATASEG

    ; Card deck structure
    CardVals            DB '234567890JQKA'
    Deck                DB '2',03,'3',03,'4',03,'5',03,'6',03 
                        DB '2',04,'3',04,'4',04,'5',04,'6',04 
                        DB '2',05,'3',05,'4',05,'5',05,'6',05 
                        DB '2',06,'3',06,'4',06,'5',06,'6',06
                        DB 'A',03,'7',03,'8',03,'9',03,'0',03
                        DB 'J',03,'Q',03,'K',03 
                        DB 'A',04,'7',04,'8',04,'9',04,'0',04
                        DB 'J',04,'Q',04,'K',04 
                        DB 'A',05,'7',05,'8',05
                        DB '9',05,'0',05,'J',05,'Q',05,'K',05 
                        DB 'A',06,'7',06,'8',06,'9',06,'0',06
                        DB 'J',06,'Q',06,'K',06,'$$'
    TopIdx              DW Deck
    
    Trump               DB ?
    Bid                 DB 0
    Trick               DB 0
    Dealer              DB 0
    Pitcher             DB ?
    NumPlayers          DB 4

    ; Storage for scoring
    HighCard            DB 0
    HighPlayer          DB 0
    LowCard             DB 0
    LowPlayer           DB 0
    Game                DB MaxPlayers DUP(0)
    JackPlayer          DB 0
    GamePlayer          DB 0
    
    ; Player tracking
    ; Human is always player 0 and initial dealer
    Players             DW HandSize*MaxPlayers DUP(?)
    Scores              DB MaxPlayers DUP(0)

    ; Trick tracking
    Tricks              DW HandSize*MaxPlayers DUP('??')
    CurrentTrick        DW Tricks
    TrickWins           DB HandSize DUP(' ')
    
    ; Various game messages
    TopMsg              DB 'Top of deck: $'
    WinTrickStr         DB ' wins trick with $'
    BidMsg              DB ' bids $'
    PlayMsg             DB ' plays $'
    Separator           DB 20 DUP('-'),'$'
    TrickMsg            DB 'Trick: $'
    
CODESEG

GLOBAL GetIndex:PROC
GLOBAL ShuffleDeck:PROC
GLOBAL DrawCard:PROC
GLOBAL DrawHands:PROC
GLOBAL GetBids:PROC
GLOBAL ClearCards:PROC
GLOBAL ReportWin:PROC
GLOBAL CompareCards:PROC
GLOBAL SearchValue:PROC
GLOBAL ScoreResults:PROC
    
ProgramStart:
    ; command line args are here
    ;80h length, 81h is string
    ;mov [PspAddress], es

    ; ctrl-c handler
    ;SetVector 23h, <seg Terminate>,<offset Terminate>
    
    mov ax, @data
    mov ds, ax
    mov es, ax

    call RandInit
    call ShuffleDeck

@@handloop:
    call DrawHands
    call PrintHands

    mov [Trick], 0
    
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
    push ax
    push dx
    mov dx, OFFSET Separator
    DosCall DOS_WRITE_STRING
    call PrintCrLf
    mov dx, OFFSET TrickMsg
    DosCall DOS_WRITE_STRING
    mov dl, [Trick]
    add dl, '1'
    DosCall DOS_WRITE_CHARACTER
    call PrintCrLf
    pop dx
    pop ax
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

    ; End of round stuff
    call ReportWin      ; see who get high card and takes the trick
    inc [Trick]
    call ClearCards     ; put in discard for winner
    mov [Pitcher], al   ; change who goes first
    
    dec ch
    jnz @@roundloop
    
    call ScoreResults
    call RoundReport

    ; exit to DOS
    call Terminate


PROC Terminate
    DosCall DOS_TERMINATE_EXE
ENDP Terminate
    
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


    ; add ax card onto the trick
    ; bx is player index
PROC AddToTrick
    push bx
    push di
    shl bl, 1
    xor bh, bh
    mov di, [CurrentTrick]
    mov [di+bx], ax
    pop di
    pop bx
    ret
ENDP AddToTrick
    
    ; al gets all of the cards in the pot
PROC ClearCards
    push ax
    push bx
    ; first let's save the winner to the index
    xor bx, bx
    mov bl, [Trick]
    mov [TrickWins+bx], al
    ; Now we increment the CurrentTrick pointer to the next block
    xor bh, bh
    mov bl, [NumPlayers]
    shl bx, 1
    add [CurrentTrick], bx
    pop bx
    pop ax
    ret
ENDP ClearCards

    ; See who won the trick
    ; return the index of the player in al
PROC ReportWin
    push dx
    mov ax, 100h                ; start with player 0 as best

@@loop:
    call CompareCards           ; al is updated for best, ah is other player
    inc ah
    cmp ah, [NumPlayers]
    jne @@loop
    ; should have max card index in al now
    call PrintPlayerMsg         ; Player x
    push ax
    push bx
    push ax
    mov dx, OFFSET WinTrickStr  ; wins trick with
    DosCall DOS_WRITE_STRING
    pop ax
    xor ah, ah
    mov si, ax
    shl si, 1
    mov bx, [CurrentTrick]
    mov ax, [bx+si]   ; winning card
    call PrintCard
    call PrintCrLf
    call PrintCrLf
    pop ax
    pop bx
    pop dx
    ret
ENDP ReportWin

    ; given index in al, return the card in ax
PROC TrickLookup
    push si
    push bx
    xor ah, ah
    mov si, ax
    shl si, 1
    mov bx, [CurrentTrick]
    mov ax, [si+bx]   ; current winner
    pop bx
    pop si
    ret
ENDP TrickLookup

    ; look for the value in al in the Card list and return the index in al
    ; return ff if it's not found
PROC SearchValue
    push cx
    push di
    cld
    mov di, OFFSET CardVals
    mov cx, 13
    repne scasb
    ; a failure really shouldn't be possible, and if there's a bug
    ; we can't do much about it anyway
@@found:
    sub di, OFFSET CardVals
    dec di
    mov ax, di
    pop di
    pop cx
    ret
ENDP SearchValue

    ; al is current best card index
    ; ah is index for comparison
    ; update al is new card is better
PROC CompareCards
    push bx
    push cx
    push dx

    call PrintCompare

    ; pull in the two cards l is suit, and h is the value
    mov bx, ax
    call TrickLookup
    mov cx, ax                  ; cx is current high card
    mov al, bh
    call TrickLookup
    mov dx, ax                  ; dx is contender card
    mov ax, bx                  ; al is current player index, ah contender
    
    cmp cl, [Trump]             
    jne @@nocurrenttrump        ; current winner doesn't have trump
    cmp dl, [Trump]
    jne @@done                  ; current winner has trump, contender doesn't
@@testval:
    ; two trump (from above) or two non-trump (below), so compare values
    ; find ch in card list, then dh and see which is bigger
    push ax
    mov al, ch
    call SearchValue
    mov bl, al          ; bl is index of current value
    
    mov al, dh
    call SearchValue
    mov bh, al          ; bh is index of contender value
    pop ax
    cmp bh, bl          ; which value is larger?
    ja @@newwinner
    jmp @@done
@@nocurrenttrump:
    cmp dl, [Trump]
    jne @@testval                ; two non-trump, so look at the card values
@@newwinner:
    mov al, ah                  ; new card is trump
@@done:
    call PrintPlayerTrick
    call PrintCrLf
    pop dx
    pop cx
    pop bx
    ret
ENDP CompareCards

    ; Count the value of the cards for each player
    ; Need to compute high, low, jack, and game
    ; Should be able to do this in one pass
PROC ScoreResults
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; initialize the trackers
    mov [LowCard], 'A'
    mov [HighCard], '2'
    mov [JackPlayer], '?'
    mov [HighPlayer], '?'
    mov [LowPlayer], '?'
    mov ax, 0
    mov di, OFFSET Game
    xor ch, ch
    mov cl, [NumPlayers]
    rep stosb

    ; we need two loops, one to count tricks, and one to count cards
    ; bx tracking trick offset, and si tracking card offset
    ; di is used to index the Game count
    ; cl is the trickloop count, since it's just easier that way
    mov bx, 0
    mov cl, 0
@@trickloop:
    mov si, 0
    ; who won this trick?
    xor dh, dh
    mov dl, [TrickWins+bx]      ; load winner index into dl
    mov di, OFFSET Game
    add di, dx
@@cardloop:
    mov ax, [Tricks+bx+si]      ; load a card
    call PrintCard
    call PrintCrLf
    ; check if trump
    cmp al, [Trump]             ; check for trump
    jne @@gamecheck
    ;   if higher than high?
    ;     set High, assign di to HighPlayer
    ;   if lower than low?
    ;     set Low, assign di to LowPlayer
    ;   if jack
    ;     assign di to JackPlayer 
@@gamecheck:
    cmp ah, '0'
    jne @@jcheck
    add [BYTE PTR di], 10
@@jcheck:
    cmp ah, 'J'
    jne @@qcheck
    add [BYTE PTR di], 1
@@qcheck:
    cmp ah, 'Q'
    jne @@kcheck
    add [BYTE PTR di], 2
@@kcheck:
    cmp ah, 'K'
    jne @@gameover
    add [BYTE PTR di], 3
@@gameover:
    add si, 2                   ; increment by one card
    xor ah, ah
    mov al, [NumPlayers]
    shl al, 1
    cmp si, ax                  ; stop when we get to 2*NumPlayers
    jne @@cardloop
    add bx, ax                  ; Move to the next trick
    inc cl
    cmp cl, HandSize
    jne @@trickloop

    ; assign high, low, jack, game
    mov di, OFFSET Scores
    xor bh, bh
    mov bl, [HighPlayer]
    add [Scores+bx], 1
    mov bl, [LowPlayer]
    add [Scores+bx], 1
    cmp [JackPlayer], '?'
    je @@nojack
    mov bl, [JackPlayer]
    add [Scores+bx], 1
@@nojack:
    ; we'll do game later
    mov al, [Game]
    mov [Scores], al
    mov al, [Game+1]
    mov [Scores+1], al
    mov al, [Game+2]
    mov [Scores+2], al
    mov al, [Game+3]
    mov [Scores+3], al
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret    
ENDP ScoreResults

    
END ProgramStart

