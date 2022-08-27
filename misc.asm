    DOSSEG
    .MODEL small

    .DATA

    HexDigits DB '0123456789ABCDEF'
    Result DB 3 DUP(?)
    
    .CODE

    ; al = byte to print
    ;
    ; destroys di, ax, bx, cx, dx
    PUBLIC PrintHexByte
    PROC PrintHexByte

    mov BYTE PTR [Result+2], '$'  ; terminate string
    mov di, OFFSET Result+1
    std
    xor bh, bh
    mov cl, 4

    mov bl, al
    and bl, 0fh
    mov ah, [HexDigits+bx]
    mov bl, al
    xchg ah, al
    stosb                       ; write the value to result string

    shr bl, cl                  ; shift the 2nd nibble
    mov al, [HexDigits+bx]      ; index to character
    stosb                       ; write the value to result string
    mov dx, OFFSET Result
    mov ah, 9
    int 21h
    ret
    ENDP PrintHexByte
    
;;; AX is the hex number to be printed
    PUBLIC PrintHex
    PROC PrintHex
    push ax
    push bx
    push cx
    push dx
    push di
    push ax
    xchg ah,al
    call PrintHexByte
    pop ax
    call PrintHexByte
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    ENDP PrintHex
END
