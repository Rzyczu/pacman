; pac.asm
.model small
.stack 100h
.data
msg db "DODO", 0Dh, 0Ah, '$'

.code
main proc
; print msg

    mov ax, @data
    mov ds, ax
    mov dx, offset msg
    mov ah, 9
    int 21h

; exit program
    mov ax, 4C00h
    int 21h
main endp
end main