    IDEAL
    DOSSEG
    MODEL small

    INCLUDE "misc.inc"
    
    DATASEG

    HexDigits DB '0123456789ABCDEF'
    Result DB 3 DUP(?)
    
    CODESEG

    ; al = byte to print
    PROC PrintHexByte

    push ax
    push bx
    push cx
    push dx
    push es
    push di
    mov bx, @data
    mov es, bx
    
    mov [Result+2], '$'  ; terminate string
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
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    ENDP PrintHexByte
    
;;; AX is the hex number to be printed
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

    PROC PrintDecByte
    push dx
    push cx
    push ax
    mov ah, 0
    mov dx, 0
hund:   
    cmp al, 100
    jb tens
    add dx, 100h
    sub al, 100
    jmp hund
tens:
    cmp al, 10
    jb ones
    add dx, 10h
    sub al, 10
    jmp tens
ones:
    add ax, dx
    ; bcd value in ax
    call PrintHex
    pop ax
    pop cx
    pop dx
    ret
    ENDP

    PROC PrintCrLf
    push ax
    push dx
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret
    ENDP PrintCrLf

    ; Reset to text mode and return to DOS
    PROC CleanExit
;    mov ax, 3
;    int 10h
    mov ah, 4ch
    int 21h
    ENDP CleanExit
END
