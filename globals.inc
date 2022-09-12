	IDEAL
	DOSSEG
	MODEL small

	Heart       EQU 03h
    	Diamond     EQU 04h
    	Club        EQU 05h
    	Spade       EQU 06h

	DeckSize    EQU 52
    	MaxPlayers  EQU 4
    	HandSize    EQU 6
    
	GLOBAL Bid:BYTE
	GLOBAL Pitcher:BYTE
	GLOBAL Players[HandSize*MaxPlayers]:WORD
	GLOBAL BidMsg:BYTE
	GLOBAL PlayMsg:BYTE
	GLOBAL Trump:BYTE
	GLOBAL TrickCards:BYTE
	GLOBAL Deck:BYTE
	GLOBAL NumPlayers:BYTE
	GLOBAL CurrentTrick[MaxPlayers]:WORD
	GLOBAL Trick:BYTE
	GLOBAL Scores[MaxPlayers]:BYTE
	
	GLOBAL AddToTrick:PROC
	GLOBAL PrintCard:PROC
	GLOBAL TrickLookup:PROC