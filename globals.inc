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
    
	DATASEG

	GLOBAL Bid:BYTE
	GLOBAL Pitcher:BYTE
	GLOBAL TopDiscard:WORD
	GLOBAL TrickPtr:WORD
	GLOBAL Players:WORD
	GLOBAL Trump:BYTE