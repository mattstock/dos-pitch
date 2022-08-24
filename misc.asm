    DOSSEG
    .MODEL small


    .CODE

;;; AX is the hex number to be printed
    PUBLIC PrintHex
    
PrintHex PROC NEAR
    mov cl, 16
loop2:
    sub cl, 4
    mov dx, ax
    shr dx, cl
    and dl, 0fh
    push ax
    mov ah, 2
    cmp dl, 9h
    jg alpha
    add dl, '0'
    jmp p1
alpha:
    sub dl, 10
    add dl, 'A'
p1:     
    int 21h
    pop ax
    cmp cl, 0
    jnz loop2
    push ax
    mov ah, 2
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h
    pop ax
    ret
    ENDP PrintHex
END
