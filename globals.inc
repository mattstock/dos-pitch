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
	GLOBAL PlayerMsg:BYTE
	GLOBAL BidMsg:BYTE
	GLOBAL PlayMsg:BYTE
	GLOBAL Trump:BYTE
	GLOBAL TrickCards:BYTE
	GLOBAL Deck:BYTE
	
	GLOBAL AddToTrick:PROC
	GLOBAL PrintCard:PROC
	