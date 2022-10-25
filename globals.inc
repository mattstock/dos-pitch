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

	GLOBAL CardVals:BYTE
	GLOBAL Bid:BYTE
	GLOBAL Pitcher:BYTE
	GLOBAL Players[HandSize*MaxPlayers]:WORD
	GLOBAL BidMsg:BYTE
	GLOBAL PlayMsg:BYTE
	GLOBAL Separator[20]:BYTE
	GLOBAL TrickMsg:BYTE
	GLOBAL Trump:BYTE
	GLOBAL TrickCards:BYTE
	GLOBAL Deck:BYTE
	GLOBAL NumPlayers:BYTE
	GLOBAL CurrentTrick:WORD
	GLOBAL Trick:BYTE
	GLOBAL Scores[MaxPlayers]:BYTE
	GLOBAL HighPlayer:BYTE
	GLOBAL HighCard:BYTE
	GLOBAL LowPlayer:BYTE
	GLOBAL TrickPlayer:BYTE
	GLOBAL LowCard:BYTE
	GLOBAL JackPlayer:BYTE
	GLOBAL CurrentPlayer:BYTE
	GLOBAL Game[MaxPlayers]:BYTE
	
	GLOBAL AddToTrick:PROC
	GLOBAL PrintCard:PROC
	GLOBAL TrickLookup:PROC