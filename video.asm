    IDEAL
    MODEL small
    STACK 200h

    VideoRam EQU 0b800h
    
    DATASEG
    
    CODESEG
    
ProgramStart:   
    mov	bx, @data
    mov	ds, bx

    mov bx, VideoRam ; video memory
    mov es, bx

    ; TGA mode
    mov ax, 9
    int 10h

    ; location
    mov di, 500
    ; 4bpp
    mov al, 0f0h
    stosb 
    
    ; wait for a key
    mov ah, 1
    int 21h

    ; 80 column color mode
    mov ax, 3
    int 10h
    
    ; quit to DOS
    mov ah,4ch
    int 21h
    END ProgramStart

CGAtest:        
    ; cga graphics
    mov ax, 4
    int 10h

    ; color palelle
    mov ah, 11
    mov bh, 00 ; background
    mov bl, 01 ; set to blue
    int 10h

    mov ah, 11
    mov bh, 01 ; foreground
    mov bl, 0  ; green/red/yellow
    int 10h

    mov al, 02 ; red
    mov ah, 12 ; write dot
    mov dx, 64h ; vert
    mov cx, 9eh ; hori
    int 10h
    END CGATest 
    
