.model small
.stack 100h
.data
in_fn db "com.com", 0
out_fn db "td2.txt", 0
in_fh dw 0
out_fh dw 0
outbuff db 200h dup(0)
buff db 200h dup (0) 
.code
start:
	mov ax, @data
	mov ds, ax
	
	mov ah, 3Dh        
    mov al, 0          
    lea dx, in_fn
    int 21h
    mov [in_fh], ax    
	
	mov ax, 3c00h
    xor cx, cx
    mov dx, offset out_fn
    int 21h
    mov [out_fh], ax
	
copy:
    mov ah, 3Fh        
    mov bx, [in_fh]    
    mov cx, 200h       
    lea dx, buff       
    int 21h
   
    mov cx, ax         
    JCXZ exit     
	
	xor si, si
    call print

	mov ax, 4000h
	lea dx, outbuff
    mov bx, [out_fh]
	mov cx, di
    int 21h

    JMP copy           
	

exit:
	mov ah, 3Eh
    mov bx, [in_fh]
    int 21h
	
    mov ah, 3Eh
    mov bx, [out_fh]
    int 21h
	
    mov ah, 4Ch
    mov al, 0
    int 21h
print PROC
	xor di, di
pradzia:
	call bin_to_hex
	inc si
	cmp si, cx 
	JL pradzia
	RET
print ENDP

bin_to_hex PROC
	XOR dx, dx
	
	MOV dl, buff[si]
	SHR dl, 4
	CALL IsvestiHex
	
	MOV dl, buff[si]
	AND dl, 0Fh
	CALL IsvestiHex
	
	MOV dl, 20h         
    MOV outbuff[di], dl
    INC di

	RET
bin_to_hex ENDP

PROC IsvestiHex
	CMP dl, 9
	JLE sk0_9
	ADD dl, 7
	
sk0_9:
	ADD dl, 30h
	mov outbuff[di], dl
	inc di
	RET
	
IsvestiHex ENDP

end start
