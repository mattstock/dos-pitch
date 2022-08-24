    .MODEL small
    .DATA
    lfsr DW 49f2h
    
    .CODE
    
    ; PRNG
    PUBLIC RandInit
RandInit PROC
    mov ax, 2c00h
    int 21h
    mov lfsr, dx
    ret
    ENDP
    
    PUBLIC Rand
Rand PROC
    mov ax, lfsr
    and ax, 1h
    shr lfsr,1 ; lsb
    cmp ax, 0
    jz done
    mov ax, lfsr
    xor ax, 0d400h
    mov lfsr, ax
done:
    mov ax, lfsr
    ret
    ENDP
    END
