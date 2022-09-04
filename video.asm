    IDEAL
    MODEL small
    STACK 200h

    INCLUDE "video.inc"
    
    VideoRam EQU 0b800h
    
    DATASEG
    
    CODESEG
    
    PROC VideoInit
    mov bx, VideoRam ; video memory
    mov es, bx

    ; TGA mode
    mov ax, 9
    int 10h
    ret
    ENDP VideoInit

END
