.model small
.stack 100h
.data
in_fn db "com.com", 0
in_fh dw 0
buffer db 200h 
kom_loopne db "loopne$"
.code
	mov ax, @data
	mov ds, ax
	
	mov ah, 3Dh        ;failo atidarymas
    mov al, 0          
    lea dx, in_fn
    int 21h
	
    mov [in_fd], ax    
	
copy:
    mov ah, 3Fh        
    mov bx, [in_fd]    
    mov cx, 200h       
    lea dx, buff       
    int 21h
   
    mov cx, ax         
    JCXZ exit     
         
	xor si, si
    call analize_pirmo_baito       

    JMP copy           
	
exit:
    mov ah, 4Ch
    mov al, 0
    int 21h
	
analize_pirmo_baito PROC
loop_:
	mov al, buff[si]
	cmp al, 11100000b
	JE loopne_print
	cmp al, 11100001b
	JE ;loope
	cmp al, 11100010b
	JE ;loop
pop_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 01010000b ;pop2
	JE
	cmp al, 10000000b ;pop1 or and2 or lea
	JE
	and al, 11100000b
	cmp al, 00000000b ;pop3
and_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 00100000b ;and1 or and3
	JE
lds_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 11000000b
	JE
dec_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 01000000b ;dec2
	JE 
	cmp al, 11110000b ;dec1
	JE

analize ENDP
print_komanda PROC


RET
print_komanda ENDP