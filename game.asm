.model small
.stack 100h
.386
.data
    maze            db 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,10
                    db 219,250,250,250,250,250,250,250,250,250,250,219,250,250,250,250,250,250,250,250,250,250,219,10
                    db 219,64,219,219,219,250,219,219,219,219,250,219,250,219,219,219,219,250,219,219,219,64,219,10
                    db 219,250,219,219,219,250,219,219,219,219,250,219,250,219,219,219,219,250,219,219,219,250,219,10
                    db 219,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,219,10
                    db 219,250,219,219,219,250,219,250,219,219,219,219,219,219,219,250,219,250,219,219,219,250,219,10
                    db 219,250,250,250,250,250,219,250,250,250,250,219,250,250,250,250,219,250,250,250,250,250,219,10
                    db 219,219,219,219,219,250,219,219,219,219,32,219,32,219,219,219,219,250,219,219,219,219,219,10
                    db 32,32,32,32,219,250,219,32,32,32,32,32,32,32,32,32,219,250,219,32,32,32,32,10
                    db 219,219,219,219,219,250,219,32,219,219,219,32,219,219,219,32,219,250,219,219,219,219,219,10
                    db 32,32,32,32,32,250,219,32,219,38,38,32,38,38,219,32,219,250,32,32,32,32,32,10
                    db 219,219,219,219,219,250,219,32,219,219,219,32,219,219,219,32,219,250,219,219,219,219,219,10
                    db 32,32,32,32,219,250,219,32,32,32,32,32,32,32,32,32,219,250,219,32,32,32,32,10
                    db 32,32,32,32,219,250,219,32,219,219,219,219,219,219,219,32,219,250,219,32,32,32,32,10
                    db 219,219,219,219,219,250,219,32,219,219,219,219,219,219,219,32,219,250,219,219,219,219,219,10
                    db 219,250,250,250,250,250,250,250,250,250,250,219,250,250,250,250,250,250,250,250,250,250,219,10
                    db 219,250,219,219,219,250,219,219,219,219,250,219,250,219,219,219,219,250,219,219,219,250,219,10
                    db 219,64,250,250,219,250,250,250,250,250,250,32,250,250,250,250,250,250,219,250,250,64,219,10
                    db 219,219,219,250,219,250,219,250,219,219,219,219,219,219,219,250,219,250,219,250,219,219,219,10
                    db 219,250,250,250,250,250,219,250,250,250,250,219,250,250,250,250,219,250,250,250,250,250,219,10
                    db 219,250,219,219,219,219,219,219,219,219,250,219,250,219,219,219,219,219,219,219,219,250,219,10
                    db 219,250,219,219,219,219,219,219,219,219,250,219,250,219,219,219,219,219,219,219,219,250,219,10
                    db 219,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,250,219,10
                    db 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,10
    ; X - 219, * - 250, C - 67, M - 38, @ - 64
    ;

    TIMER_INT       equ 1CH                                 ; 1CH is now a synonym to TIMER_INT
    TIMER_INT_ADDR  dd (?)

    pacman_row      db 17
    pacman_col      db 11

    pacman          db 60, 0
    background_char db 32
    wall_char       db 219
    dot_char        db 250

    key             db 0, 0
    store_msg       db "Score: $"
    score           dw 48
    active_key      db 0

    current_dir     db 0fh
    dir_right       db 0fh
    dir_down        db 0eh
    dir_left        db 0dh
    dir_up          db 0ch

    timer_count     db 0

.code
main proc

    ; Initialize timer interrupt handler
                            ;push ax
                            ;push dx
                            mov  ah, 35h
                            mov  al, TIMER_INT
                            int  21h                        ; Now we have an address of this interrupt handler in bx
                                                            ; since IVT starts at 0x00, bx, an offset, has a definitive address to 1CH handler
                            cli
                            mov  word ptr [TIMER_INT_ADDR], bx ; move address of 1Ch to TIMER_INT_ADDR | Point the 1Ch IP to the TIMER_INT_ADDR.
                            mov  ax, es
                            mov  word ptr TIMER_INT_ADDR[2], ax ; move code segment of the 1Ch int to the addr+2bytes (each entry in IVT is 2 words wide)
                            mov  ax, seg handle_timer           ; new code segment for the interrupt
                            mov  ds, ax
                            mov  dx, offset handle_timer
                            mov  ah, 25h
                            mov  al, TIMER_INT
                            int  21h 
                            sti                             ; Ok now we set new address of the 1Ch interrupt handler. Effectively,
                                                            ; it should be DS(handle_timer):DX(offset of handle_timer), so whenever 
                                                            ; 1CH is called, it goes to handle_timer
                            xor  ax, ax
                            xor  bx, bx
                            xor  dx, dx
                            mov  ax, 0
                            int  10h
                            
                            ;pop  dx
                            ;pop  ax
    ; -- This allows for the use of variables in the code segment -- ;
                            mov  ax, @data                  ; load the first address of data to ax
                            mov  ds, ax                     ; load this address to DATA SEGMENT register

    ; -- Displaying the maze as a table -- ;
                            mov  si, offset maze            ; load the address offset of maze to SOURCE INDEX reg
                            mov  cx, 25*23                  ; number of elements in the maze - load this into cx, as this is an argument for display_loop
    display_loop:           
                            mov  ah, 02h                    ; write character to standard output interrupt service
                            mov  dl, [si]                   ; move the character at si address to dl
                            jne  print_char
   
    print_char:             
                            int  21h                        ; Write character to standard output interrupt! Not move cursor.
                            inc  si
                            loop display_loop

    ; Initialize score position
                            mov  ah, 02h                    ; Set cursor position interrupt service
                            mov  bh, 0                      ; Page number
                            mov  dx, 25                     ; X-coordinate
                            int  10h

    ; TODO: not working
    ; ; Display the score value
    ;                         mov  ah, 09h                    ; display string interrupt service
    ;                         lea  dx, [store_msg]            ; load effective address of store_msg to dx
    ;                         int  21h                        ; Display the stored message

    ;                         mov  ah, 09h                    ; display string interrupt service
    ;                         lea  dx, [score]                ; load effective address of score to dx
    ;                         int  21h                        ; Display the score
                            
    ; Initialize PacMan position
                            mov  ah, 02h                    ; Set cursor position interrupt service
                            mov  bh, 0                      ; Page number
                            mov  dh, [pacman_row]           ; Y-coordinate
                            mov  dl, [pacman_col]           ; X-coordinate
                            int  10h
                    
    ; Display PacMan at the starting position
                            mov  ah, 0Ah                    ; Write character only at cursor position
                            mov  al, [pacman]               ; PacMan character
                            mov  bh, 0                      ; Page 0
                            mov  cx, 1                      ; 1 char
                            int  10h

    ; Game loop
    game_loop:              
    ; Wait for key press
                            mov  ah, 08h                    ; return character from stdin WITHOUT ECHO!
                            int  21h
                            mov  [key], al                  ; character read is written on al
                            ;push bx
                            ;cmp [timer_count], 7
                            ;je  end_program
                            ;pop bx

    ; Handle arrow key input
                            mov  al, [key]                  ; first compare then move, redundant here
                            cmp  al, 0
                            je   game_loop                  ; jump if no input

    ; Move PacMan based on arrow key input - basically compare input to input char
                            cmp  al, 27                     ; ESC key
                            je   end_program
                            cmp  al, 72                     ; Up arrow
                            je   move_up
                            cmp  al, 80                     ; Down arrow
                            je   move_down
                            cmp  al, 75                     ; Left arrow
                            je   move_left
                            cmp  al, 77                     ; Right arrow
                            je   move_right

    clear_previous_position:
                            push cx
                            mov  ah, 0Ah
                            mov  al, [background_char]
                            mov  bh, 0
                            mov  cx, 1
                            int  10h
                            pop  cx
                            ret

    move_up:                
                            call clear_previous_position
                            pop cx

                            mov  ch, [pacman_row]
                            mov  cl, [pacman_col]

                            dec  [pacman_row]
                            jmp  update_position

    move_down:              
                            call clear_previous_position

                            mov  ch, [pacman_row]
                            mov  cl, [pacman_col]

                            inc  [pacman_row]
                            jmp  update_position

    move_left:              
                            call clear_previous_position

                            mov  ch, [pacman_row]
                            mov  cl, [pacman_col]
    
                            dec  [pacman_col]
                            jmp  update_position

    move_right:             
                            call clear_previous_position

                            mov  ch, [pacman_row]
                            mov  cl, [pacman_col]

                            inc  [pacman_col]
                            jmp  update_position

    handle_timer:           
                            ; TODO: 1. Zwieksz zmienna o 1
                            ;       2. Wroc tam gdzie sie bylo
                            ;       Albo
                            ;       1. Zwieksz zmienna o 1
                            ;       2. Popatrz, czy zmienna == x, bo tyle bedziemy miec*55ms interwalu (odmierzanego czasu)
                            cli
                            inc [timer_count]
                            sti
                            iret

    update_position:        
    ; Display PacMan at the new position
    ; (pacman_row * 24) + pacman_col = position
                            push ax                         ; push ax cx bx on stack
                            push cx
                            push bx
                            mov  ax, 0
                            mov  bx, 0
                            mov  cx, 0

                            mov  si, offset maze            ; load the start address of the maze in source index

                            mov  dh, [pacman_row]           ; move Y to dh
                            mov  dl, [pacman_col]           ; move X to dl

                            mov  al, [pacman_row]           ; move row into lower byte of ax
                            mov  bl, 24                     ; move number of rows into bl
                            mul  bl                         ; 24 * pacman_row
                            add  al, [pacman_col]           ; (24 * pacman_row) + pacman_col
                            add  si, ax                     ; add offset to maze offset in memory
                            mov  al, [si]                   ; copy character at that offset to al
                            cmp  al, [wall_char]            ; compare char (at offset) in al with wall_char

                            pop  bx
                            pop  cx
                            pop  ax
                            je   reset_pos                  ; pos is in cx, we have to reset the position

                            mov  ah, 02h                    ; move cursor position interrupt service
                            int  10h

                            mov  ah, 0Ah                    ; write character only at cursor position
                            mov  al, [pacman]               ; pacman char
                            mov  bh, 0                      ; page 0
                            mov  cx, 1                      ; 1 char
                            int  10h

                            cmp  al, [dot_char]             ; assuming 250 is the dot character

    ; Continue the game loop
                            jmp  game_loop
    
    reset_pos:              
                            mov  [pacman_row], ch
                            mov  [pacman_col], cl

                            push cx
                            push bx
                            mov  ah, 0Ah
                            mov  al, [pacman]
                            xor  bx, bx
                            mov  bh, 0
                            mov  cx, 1
                            int  10h
                            pop  bx
                            pop  cx
                    
                            jmp  game_loop

    end_program:            
    ; End program
                            mov  ax, 0
                            int  10h
                            mov  ah, 4Ch                    ; exit - terminate with return code
                            mov  al, 0
                            int  21h
    
main endp
end main
