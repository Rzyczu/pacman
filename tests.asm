.model small
.stack 100h
.386
.data
    maze   db 88,88,88,88,88,88,108,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,10
           db 88,42,42,42,42,42,42,42,108,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,42,42,42,42,42,42,108,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,42,42,42,42,42,42,10,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,42,42,42,42,42,42,106,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,42,42,42,42,42,42,107,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10

    pacman_row db 0
    pacman_col db 0
    message_equal db "Equal", "$"
    message_nequal db "Not equal", "$"

.code
main proc
           mov ax, @data
           mov ds, ax
           mov si, offset maze
           ; (pacman_row * 6?) + pacman_col = position
           ; -- This works! -- ;
           ;mov cl, 6
           ;add [pacman_col], cl
           ;mov cl, [pacman_col]             ; has to be lower byte!
           ;add si, cx
           ;mov bl, [si]
           ;cmp bl, 108

           mov cl, 8                         ; we want to get 106 Y: 8 X: 4
           add [pacman_col], cl
           mov cl, 4
           add [pacman_row], cl

           mov al, [pacman_row]
           mov cl, 24
           mul cl
           add al, [pacman_col]
           add si, ax
           mov bl, [si]
           cmp bl, 106
           ; -- WORKS!!!! -- ;

           ;add si, 6
           ;mov bl, [si]
           ;cmp bl, 108

           je print_equal
           jne print_nequal

print_equal:
           mov ah, 09h                  ; write string
           mov dx, offset message_equal
           int 21h
           jmp end_program

print_nequal:
           mov ah, 09h
           mov dx, offset message_nequal
           int 21h
           jmp end_program

end_program:
            ; End program

            ; TODO: Clear screen
            mov  ah, 4Ch               ; exit - terminate with return code
            mov  al, 0
            int  21h

main endp
end main