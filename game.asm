.model small
.stack 100h
.386
.data
    maze   db 88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,10
           db 88,42,42,42,42,42,42,42,42,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,64,88,88,88,42,88,88,88,88,42,88,42,88,88,88,88,42,88,88,88,64,88,10
           db 88,42,88,88,88,42,88,88,88,88,42,88,42,88,88,88,88,42,88,88,88,42,88,10
           db 88,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,88,88,88,42,88,42,88,88,88,88,88,88,88,42,88,42,88,88,88,42,88,10
           db 88,42,42,42,42,42,88,42,42,42,42,88,42,42,42,42,88,42,42,42,42,42,88,10
           db 88,88,88,88,88,42,88,88,88,88,32,88,32,88,88,88,88,42,88,88,88,88,88,10
           db 88,88,88,88,88,42,88,32,32,32,32,32,32,32,32,32,88,42,88,88,88,88,88,10
           db 88,88,88,88,88,42,88,32,88,88,88,32,88,88,88,32,88,42,88,88,88,88,88,10
           db 32,32,32,32,32,42,88,32,88,77,77,32,77,77,88,32,88,42,32,32,32,32,32,10
           db 88,88,88,88,88,42,88,32,88,88,88,32,88,88,88,32,88,42,88,88,88,88,88,10
           db 88,88,88,88,88,42,88,32,32,32,32,32,32,32,32,32,88,42,88,88,88,88,88,10
           db 88,88,88,88,88,42,88,32,88,88,88,88,88,88,88,32,88,42,88,88,88,88,88,10
           db 88,88,88,88,88,42,88,32,88,88,88,88,88,88,88,32,88,42,88,88,88,88,88,10
           db 88,42,42,42,42,42,42,42,42,42,42,88,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,42,88,88,88,42,88,88,88,88,42,88,42,88,88,88,88,42,88,88,88,42,88,10
           db 88,64,42,42,88,42,42,42,42,42,42,67,42,42,42,42,42,42,88,42,42,64,88,10
           db 88,88,88,42,88,42,88,42,88,88,88,88,88,88,88,42,88,42,88,42,88,88,88,10
           db 88,42,42,42,42,42,88,42,42,42,42,88,42,42,42,42,88,42,42,42,42,42,88,10
           db 88,42,88,88,88,88,88,88,88,88,42,88,42,88,88,88,88,88,88,88,88,42,88,10
           db 88,42,88,88,88,88,88,88,88,88,42,88,42,88,88,88,88,88,88,88,88,42,88,10
           db 88,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,88,10
           db 88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,10
    ; X - 88, * - 42, C - 67, M - 77, @ - 64
    ;

    pacman db 'C', 0
    pacman_row db 18
    pacman_col db 11
    background_char db ' '
    wall_char db 88
    key db 0, 0
.code
main proc
    ; -- This allows for the use of variables in the code segment -- ;
                 mov  ax, @data          ; load the first address of data to ax
                 mov  ds, ax             ; load this address to DATA SEGMENT register

    ; -- Displaying the maze as a table -- ;
                 mov  si, offset maze    ; load the address offset of maze to SOURCE INDEX reg
                 mov  cx, 25*23          ; number of elements in the maze - load this into cx, as this is an argument for display_loop
    display_loop:
                 mov  ah, 02h            ; write character to standard output interrupt service
                 mov  dl, [si]           ; move the character at si address to dl
                 cmp  dl, 35             ; compare dl with character that doesn't exist, wtf
                 jne  print_char
                 mov  dl, '|'            ; ?
    print_char:  
                 int  21h                ; Write character to standard output interrupt! Not move cursor.
                 inc  si
                 loop display_loop

    ; Game loop
    game_loop:
                ; Wait for key press
                mov  ah, 08h             ; return character from stdin WITHOUT ECHO!
                int  21h
                mov  [key], al           ; character read is written on al

                ; Handle arrow key input
                mov  al, [key]           ; first compare then move, redundant here
                cmp  al, 0
                je   game_loop           ; jump if no input

                ; Move PacMan based on arrow key input - basically compare input to input char
                cmp  al, 27  ; ESC key
                je   end_program
                cmp  al, 72  ; Up arrow
                je   move_up
                cmp  al, 80  ; Down arrow
                je   move_down
                cmp  al, 75  ; Left arrow
                je   move_left
                cmp  al, 77  ; Right arrow
                je   move_right

    move_up:
                push cx
                mov ah, 0Ah
                mov al, [background_char]
                mov bh, 0
                mov cx, 1
                int 10h
                pop cx

                mov ch, [pacman_row]
                mov cl, [pacman_col]

                dec  [pacman_row]
                jmp  update_position

    move_down:
                push cx
                mov ah, 0Ah
                mov al, [background_char]
                mov bh, 0
                mov cx, 1
                int 10h
                pop cx

                inc  [pacman_row]
                jmp  update_position

    move_left:
                push cx
                mov ah, 0Ah
                mov al, [background_char]
                mov bh, 0
                mov cx, 1
                int 10h
                pop cx
                
                dec  [pacman_col]
                jmp  update_position

    move_right:
                push cx
                mov ah, 0Ah
                mov al, [background_char]
                mov bh, 0
                mov cx, 1
                int 10h
                pop cx

                inc  [pacman_col]
                jmp  update_position

    update_position:
                ; Display PacMan at the new position

                ; Mov offset of maze to si
                ; Calculate offset
                ; Add this offset to si
                ; See what's at si
                ; Problem: si is a word, and we have 1 byte values
                ; (pacman_row and pacman_col)
                ; TODO: bit shift the pacman_row and pacman_col
                ; so they are 16 bit (1 word values)
                ; then, we can operate on si

                ; (pacman_row * 24) + pacman_col = position
                push ax
                push cx
                push bx
                mov  si, offset maze       ; load the start address
                mov  cx, si

                mov  dh, [pacman_row]      ; move Y to dh
                mov  dl, [pacman_col]      ; move X to dl

                mov bx, [pacman_row]

                0b00001111 <-
                0b0000000000001111 <-

                mov ax, 24
                mul bx
                add ax, dl

                add cl, al ; we have character offset in al

                cmp cl, [wall_char] 

                mov  ah, 02h               ; move cursor position interrupt service
                int  10h

                mov  ah, 0Ah               ; write character only at cursor position
                mov  al, [pacman]          ; pacman char
                mov  bh, 0                 ; page 0
                mov  cx, 1                 ; 1 char
                int  10h

                ; Continue the game loop
                jmp  game_loop                

    end_program:
                ; End program

                ; TODO: Clear screen
                mov  ah, 4Ch               ; exit - terminate with return code
                mov  al, 0
                int  21h
    
main endp
end main
