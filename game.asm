.model small
.stack 100h
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
    pacman_row db 17
    pacman_col db 11*23
    key db 0, 0
.code
main proc
                 mov  ax, @data
                 mov  ds, ax

    ; Displaying the maze as a table
                 mov  si, offset maze
                 mov  cx, 24*23          ; number of elements in the maze
    display_loop:
                 mov  ah, 02h
                 mov  dl, [si]
                 cmp  dl, 35
                 jne  print_char
                 mov  dl, '|'
    print_char:  
                 int  21h
                 inc  si
                 loop display_loop

    ; Placing PacMan in the middle of the maze
                 mov  cl, [pacman_col]
                 mov  dl, [pacman_row]
                 mov  ah, 02h
                 lea  dx, pacman
                 int  10h

    ; Game loop
    game_loop:
                ; Wait for key press
                mov  ah, 01h
                int  21h
                mov  [key], al

                ; Handle arrow key input
                mov  al, [key]
                cmp  al, 0
                je   game_loop

                ; Clear PacMan from the current position
                mov  cl, [pacman_row]
                mov  dl, [pacman_col]
                mov  ah, 02h
                int  10h

                ; Move PacMan based on arrow key input
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
                dec  [pacman_row]
                jmp  update_position

    move_down:
                inc  [pacman_row]
                jmp  update_position

    move_left:
                dec  [pacman_col]
                jmp  update_position

    move_right:
                inc  [pacman_col]
                jmp  update_position

    update_position:
                ; Display PacMan at the new position
                mov  cl, [pacman_row]
                mov  dl, [pacman_col]
                mov  ah, 02h
                lea  dx, pacman
                int  10h

                ; Continue the game loop
                jmp  game_loop

    end_program:
                ; End program
                mov  ah, 4Ch
                int  21h
    
main endp
end main
