.model small
.stack 100h
.data
in_fn db "com.com", 0
in_fh dw 0
buffer db 200h 
kom_loopne db "loopne $"
kom_loop db "loop $"
kom_loope db "kom_loope $"
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
loopne_print:
	lea dx, kom_loopne
	call bin_to_hex
	;grizimas i loopa
loop_print:
	lea dx, kom_loop
	call bin_to_hex
	;grizimas i loopa
loope_print:
	lea dx, kom_loope
	call bin_to_hex
	;grizimas i loopa
pop_2:
	call reg_nustatymas
pop_3:
	call sreg_nustatymas
lds_print:
	
	
	
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
	JE loope_print
	cmp al, 11100010b
	JE loop_print
pop_:
	mov al, buff[si]
	and al, 11111000b
	cmp al, 01011000b ;pop2
	JE pop_2
	
	mov al, buff[si]
	and al, 11110000b
	
	cmp al, 10000000b ;pop1 or and2 or lea
	JE
	and al, 11100000b
	cmp al, 00000000b ;pop3
	JE pop_3
and_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 00100000b ;and1 or and3
	JE
lds_:
	mov al, buff[si]
	cmp al, 11000101b
	JE lds_print
dec_:
	mov al, buff[si]
	and al, 11110000b
	cmp al, 01000000b ;dec2
	JE 
	cmp al, 11110000b ;dec1
	JE

analize ENDP
print_komanda PROC
mov ah, 09h
int 21h
RET
print_komanda ENDP

bin_to_hex PROC
	XOR dx, dx
	
	MOV dl, buff[si]
	SHR dl, 4
	CALL IsvestiHex
	
	MOV dl, bl
	AND dl, 0Fh
	CALL IsvestiHex

	RET
bin_to_hex ENDP

PROC IsvestiHex
	CMP dl, 9
	JLE sk0_9
	ADD dl, 7
	
sk0_9:
	ADD dl, 30h
	MOV ah, 02h
	INT 21h
	RET
	
IsvestiHex ENDP
reg_nustatymas PROC

RET
reg_nustatymas ENDP

;https://docs.google.com/spreadsheets/d/1Y5cNmWNW3BiRY56nrGFinnCxZqVxTG4p6QLTUfnQBHE/edit?fbclid=IwY2xjawHGhMhleHRuA2FlbQIxMAABHRUuxRuzYHLs4mkp09I1RhvuitY7f4BVIIMFb6Hee0CL-dZguzGkDmgong_aem_Y45mWeQDSrH2U-tEo-KpNg&gid=2122611062#gid=2122611062