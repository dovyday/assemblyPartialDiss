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
pop_1:
	call mod_nustatymas
	mov al, buff[si]
	and al, 00111000b
	cmp al, 00110000b
	JNE ;kazkur
	call r/m_nustatymas
	;poslinkis
pop_2:
	call reg_nustatymas
	;viskas
pop_3:
	call sreg_nustatymas
	;viskas
lds_1:
	call mod_nustatymas
	call reg_nustatymas
	call r/m_nustatymas
	;poslinkis 
lea_1:
	call mod_nustatymas
	call reg_nustatymas
	call r/m_nustatymas
	;poslinkis 
and_1:
	call d_nustatymas
	call w_nustatymas
	call mod_nustatymas
	call reg_nustatymas
	call r/m_nustatymas
	;poslinkis 
and_2:

and_3:

dec_1:

dec_2:

	
	
	
exit:
    mov ah, 4Ch
    mov al, 0
    int 21h
	
analize_pirmo_baito PROC
;base case, kad griztu i loopa
loop_:
	mov al, buff[si]
	cmp al, 11100000b
	JE loopne_print
	cmp al, 11100001b
	JE loope_print
	cmp al, 11100010b
	JE loop_print    ;done, tik poslinkis
pop_:
	mov al, buff[si]
	and al, 11111000b
	cmp al, 01011000b ;pop2 done tik reg nustatymas
	JE pop_2
	
	mov al, buff[si]
	cmp al, 10001111b ;pop1
	JE pop_1 ;done tik mod ir rm
	 
	and al, 11100111b
	cmp al, 00000111b ;pop3 done tik sreg
	JE pop_3
and_:
	mov al, buff[si]
	and al, 11111100b

	cmp al, 00100000b ;and 1 done tik dw mod reg rm ir poslinkis
	JE and_1		

	cmp al, 10000000b ;and 2 done ,tik sw mod r/m poslinkis betarpiai operandai
	JE and_2
	
	and al, 11111110b
	cmp al, 00100100b; and 3 done, tik w betoperandas, betarpis operandas2 jei w =1
	JE and_3
lds_:
	mov al, buff[si]
	cmp al, 11000101b ;done, tik mod reg r/m
	JE lds_1
lea_:
	cmp al, 10001101b ;done tik mod reg r/m 
dec_:
	and al, 11111110b
	cmp al, 11111110b ;dec1 done tik w mod 001 r/m poslinkis
	JE dec_1
	
	and al, 11111000b
	cmp al, 11110000b ;dec2 done, tik 
	JE dec_2

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
	mov al, buff[si]
	and al, 0000111b
	cmp al, 0000000b
	;kazkas
	cmp al, 0000001b
	;kazkas
	cmp al, 0000010b
	;kazkas
	cmp al, 0000011b
	;kazkas
	cmp al, 0000100b
	;kazkas
	cmp al, 0000101b
	;kazkas
	cmp al, 0000110b
	;kazkas
	cmp al, 0000111b
	;kazkas
	
	;opk reg	
	RET
reg_nustatymas ENDP

sreg_nustatymas PROC
;opk sreg opk
	mov al, buff[si]
	and al, 00011000b
	cmp al, 00000000b
	;kazkas
	cmp al, 00001000b
	;kazkas
	cmp al, 00010000b
	;kazkas
	cmp al, 00011000b
	;kazkas	

	RET
sreg_nustatymas ENDP

mod_nustatymas PROC
	mov al, buff[si + 1]
	and al, 11100000b
	cmp al, 01000000b
	;kazkas
	cmp al, 00000000b
	;kazkas
	cmp al, 10000000b
	;kazkas
	cmp al, 11000000b
	;kazkas
;mod adresavimo baitas

RET
mod_nustatymas ENDP

d_nustatymas PROC
	mov al, buff[si]
	and al, 00000010b
	cmp al, 00000000b
	;kazkas
	cmp al, 00000010b
	;kazkas	
	RET
d_nustatymas ENDP

	
w_nustatymas PROC
	mov al, buff[si]
	and al, 00000001b
	cmp al, 00000000b
	;kazkas
	cmp al, 00000001b
	;kazkas
	RET
w_nustatymas ENDP
r/m_nustatymas PROC
	mov al, buff[si]
	and al, 00000111b
	cmp al, 00000000b
	;kazkue
	cmp al, 00000001b
	;kazkur
	cmp al, 00000010b
	;kazkur
	cmp al, 00000011b
	;kazkur
	cmp al, 00000100b
	;kazkur
	cmp al, 00000101b
	;kakzur
	cmp al, 00000110b
	;kazkur
	cmp al, 00000111b
	;kazkur
r/m_nustatymas ENDP
sw_nustatymas PROC
	mov al, buff[si]
	and al, 00000011b
	cmp al, 00000001b
	;kazkas
	cmp al, 00000011b
	;kazkas
	RET
sw_nustatymas ENDP
;https://docs.google.com/spreadsheets/d/1Y5cNmWNW3BiRY56nrGFinnCxZqVxTG4p6QLTUfnQBHE/edit?fbclid=IwY2xjawHGhMhleHRuA2FlbQIxMAABHRUuxRuzYHLs4mkp09I1RhvuitY7f4BVIIMFb6Hee0CL-dZguzGkDmgong_aem_Y45mWeQDSrH2U-tEo-KpNg&gid=2122611062#gid=2122611062