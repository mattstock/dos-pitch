    IDEAL
    DOSSEG
    MODEL small

    INCLUDE "ai.inc"
    INCLUDE "globals.inc"
    
    DATASEG

    CODESEG
    
; player index in al
PROC AiBid
    
    mov [Bid], 1
    mov [Pitcher], al
    ret
ENDP AiBid

END
    
