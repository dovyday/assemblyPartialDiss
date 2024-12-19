.model small
.stack 100h
.data
tarpas db "    ", 0 ;4
in_fn db 20h dup(0)
out_fn db 20h dup(0)
inbuff db 200, 0, 200 dup (0)
HelpParamMsg db "Si programa apdoroja pop, dec, and, loop, loope, loopne, lea, lds komandas$"
in_fh dw 0
out_fh dw 0
bracket_flag db 0
d db 3
kom_and db "and "
w0 db "AL", "CL", "DL", "BL", "AH", "CH", "DH", "BH"
kom_reg db "AX", "CX", "DX", "BX", "SP", "BP", "SI", "DI"
kom_sreg db "ES", "CS", "SS", "DS"
kom_modrm db "[BX+SI] ", "[BX+SI+ ", "[BX+SI+ ", "AX      " ;7 ;10 ;10 ;2
		  db "[BX+DI] ", "[BX+DI+ ", "[BX+DI+ ", "CX      " 
		  db "[BP+SI] ", "[BP+SI+ ", "[BP+SI+ ", "DX      "
		  db "[BP+DI] ", "[BP+DI+ ", "[BP+DI+ ", "BX      "
		  db "SI      ", "[SI+    ", "[SI+    ", "SP      "
		  db "DI      ", "[DI+    ", "[DI+    ", "BP      "
		  db "        ", "[BP+    ", "[BP+    ", "SI      "
		  db "BX      ", "[BX +   ", "[BX +   ", "DI      "
col db 4 ; matrix[i][j] = matrix [i * cols + j]
outbuff db 0
buff db 200h dup (0)
skliaustas db "]"
kom_loopne db "loopne ", 0
kom_loop db "loop ", 0
kom_loope db "loope ", 0
kom_lea db "lea ", 0
kom_unknown db "unknown", 0
kom_pop db "pop ", 0
kom_dec db "dec ", 0
kom_lds db "lds ", 0
new_line db 13, 10
cs_kom db "cs:", 0
loopcount db 0
bytecount db 0
ip_value dw 0100h
reg db 0
rm db 0
mood db 0
poslinkis db 0
tarpasMazas db " ", 0
w db 3
s db 3
adrCheck db 0
kablelis db ", "
parametru_byte_count db 0
parametro_pavadinimo_ilgis db 0
ivestis db 0
.code
start:
    mov ax, @data
    mov ds, ax
    
	mov al, es:[80h] 
	mov [parametru_byte_count], al
	
	cmp [parametru_byte_count], 0
	JE ivedinejimas
	
	mov di, 81h	
	call PraleistiTarpus
	call ArPagalba
	CMP bx, 1	
	JE klaidaParametruose
	
	;mov [parametro_pavadinimo_ilgis], 0
	mov al, es:[80h]
	mov [parametru_byte_count], al
	
	call PraleistiTarpus
	mov si, offset in_fn
	call SkaitytiPav
	mov si, offset out_fn
	call skaitytiPav
	
	
openfile:
    ; Open input file
    mov ah, 3Dh        
    mov al, 0          
    lea dx, in_fn
    int 21h
    mov [in_fh], ax
	
    ; Create output file
    mov ax, 3C00h
    xor cx, cx
    mov dx, offset out_fn
    int 21h
    mov [out_fh], ax

copy:
    ; Read up to 512 (0x200) bytes
    mov ah, 3Fh        
    mov bx, [in_fh]    
    mov cx, 200h       
    lea dx, buff       
    int 21h
   
    mov cx, ax 
    mov di, cx
    jcxz exit
    
    xor si, si
    call analize

    jmp copy
klaidaParametruose:
	lea dx, HelpParamMsg
	CALL print
	JMP exit
ivedinejimas:
	lea dx, inbuff
	mov ah, 0Ah
	int 21h
	xor ax, ax
	mov bl, [inbuff + 1]
	mov bh, 0
	call IsvestiHexZodi
	mov al, [inbuff + 1]
	xor di, di
	xor si, si
	call PraleistiIvestusTarpus
	mov [ivestis], 1
	xor di, di
	mov di, si 
	xor si, si
	call convertASCII
	call analize
	
exit:
    ; Close input file
    mov ah, 3Eh
    mov bx, [in_fh]
    int 21h
    
    ; Close output file
    mov ah, 3Eh
    mov bx, [out_fh]
    int 21h
    
    mov ah, 4Ch
    mov al, 0
    int 21h


analize PROC
loop_:
    cmp si, di
    JGE back 
	call cs_print
    mov al, buff[si]
    cmp al, 11100010b ; loop opcode
    je loop_print
	cmp al, 11100000b ; loopne opcode
    je loopne_print_temp;
	cmp al, 11100001b ; loope opcode
    je loope_print_temp
	cmp al, 10001111b ;pop1
	JE pop1_temp
	cmp al, 10001101b ;lea
	je lea_temp
	cmp al, 11000101b ;lds
	je lds_temp
	
	and al, 11111000b
	cmp al, 01001000b ;dec2 tik reg
	JE dec2_temp
	cmp al, 01011000b
	JE pop2_temp
	mov al, buff[si]
	and al, 11100111b
	cmp al, 00000111b
	JE pop3_temp
	
	mov al, buff[si]
	and al, 11111110b
	cmp al, 11111110b
	JE dec1_temp ;
	cmp al, 00100100b
	JE and3_temp
	
	and al, 11111100b
	cmp al, 00100000b
	JE and1_temp
	cmp al, 10000000b
	JE and2_temp
	
    jmp unknownKom1
back:
    ret
loopne_print_temp:
	JMP loopne_print
loope_print_temp:
	JMP loope_print
lea_temp:
	JMP lea_
lds_temp:
	JMP lds_
dec2_temp:
	JMP dec2
pop2_temp:
	JMP pop2
pop3_temp:
	JMP pop3
dec1_temp:
	JMP dec1
and1_temp:
	JMP and1
and3_temp:
	JMP and3
and2_temp:
	JMP and2
loop_print:             ;pilnai done
	add [ip_value], 2h
	call IsvestiHexBaita
	inc si
	call IsvestiHexBaita
	call isvestiTarpa
    lea dx, kom_loop
    mov cx, 5
    call print_komanda
    call IsvestiHexBaita 
    call printNew
	inc si
    jmp loop_
pop1_temp:
	JMP pop1
loopne_print:
	add [ip_value], 2h		;pilnai done
	call IsvestiHexBaita
	inc si 
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_loopne
	mov cx, 7
	call print_komanda
	call IsvestiHexBaita
	call printNew
	inc si
	jmp loop_
loope_print: 				;pilnai done
	add [ip_value], 2h
	call IsvestiHexBaita
	inc si
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_loope
	mov cx, 6
	call print_komanda
	call IsvestiHexBaita
	call printNew
	inc si
	jmp loop_
pop1:
	inc si
	call rm_nustatymas
	call mod_nustatymas
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	
	mov cx, 4
	lea dx, kom_pop
	call print_komanda
	
	call modrm_print
	call isvedimasPoslinkioZ
	

	call printNew
	call nunulinimas
	inc si
	jmp loop_
lea_:
	inc si  ;modrm
	call rm_nustatymas
	call mod_nustatymas
	call ipPridejimas
	call naudojamu_baitu_isvedimas ;modrm
	
	mov cx, 4
	lea dx, kom_lea
	call print_komanda
	
	call adresavimo_reg_nustatymas
	mov cx, 1
	lea dx, tarpasMazas
	call print_komanda
	call modrm_print
	call isvedimasPoslinkioZ
	call nunulinimas
	call printNew
	inc si
	jmp loop_
lds_:
	inc si
	call rm_nustatymas
	call mod_nustatymas
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	mov cx, 4
	lea dx, kom_lds
	call print_komanda
	call adresavimo_reg_nustatymas
	call isvestiKableli
	call modrm_print
	call isvedimasPoslinkioZ
	call nunulinimas
	call printNew
	inc si
	jmp loop_
dec2:				;pilnai done
	inc [ip_value]
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_dec
	mov cx, 4
	call print_komanda
	call reg_nustatymas
	call printNew
	inc si
	jmp loop_
pop2:				;turbut pilnai done
	inc [ip_value]
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_pop
	mov cx, 4
	call print_komanda
	call reg_nustatymas
	call printNew
	inc si
	jmp loop_
pop3:                  ;pilnai done
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_pop
	mov cx, 4
	call print_komanda
	call sreg_nustatymas
	call printNew
	inc si
	jmp loop_
dec1:
	call nunulinimas
	call w_nustatymas
	inc si
	call rm_nustatymas
	call mod_nustatymas
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	mov cx, 4
	lea dx, kom_dec
	call print_komanda
	call modrm_print
	call isvedimasPoslinkioZ
	call printNew
	call nunulinimas
	inc si
	jmp loop_
and1:	
	call nunulinimas
	call w_nustatymas
	call d_nustatymas
	inc si
	call rm_nustatymas
	call mod_nustatymas
	cmp [d], 1
	JE kitasAtvejis
	
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	mov cx, 4
	lea dx, kom_and
	call print_komanda
	
	call modrm_print
	call isvedimasPoslinkioZ
	call isvestiKableli

	call adresavimo_reg_nustatymas
	
	
	call printNew
	call nunulinimas
	inc si
	jmp loop_
kitasAtvejis:
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	mov cx, 4
	lea dx, kom_and
	call print_komanda
	
	call adresavimo_reg_nustatymas
	call isvestiKableli
	call modrm_print
	call isvedimasPoslinkioZ
	
	call printNew
	call nunulinimas
	inc si
	jmp loop_
and3:
	call w_nustatymas
	inc si
	cmp [w], 0
	JE othercase
	
	call ipPridejimas
	dec si
	call IsvestiHexBaita
	inc si
	call IsvestiHexBaita
	inc si 
	call IsvestiHexBaita
	mov cx, 4
	lea dx, tarpas
	call print_komanda

	lea dx, kom_and
	call print_komanda
	
	mov cx, 2
	lea dx, kom_reg
	call print_komanda
	call isvestiKableli
	
	call IsvestiHexBaita
	dec si
	call IsvestiHexBaita
	inc si
	call printNew
	inc si 
	jmp loop_
othercase:
	call ipPridejimas
	call naudojamu_baitu_isvedimas
	mov cx, 4
	lea dx, kom_and
	call print_komanda
	
	mov cx, 2
	lea dx, w0
	call print_komanda
	
	inc si
	call IsvestiHexBaita
	inc si 
	call IsvestiHexBaita
	inc si 	
	call printNew
	jmp loop_
	
and2:
	call s_nustatymas
	call w_nustatymas
	inc si
	call adresavimoCheck
	cmp [adrCheck], 00100000b
	JNE unknownKomPOP
	call mod_nustatymas
	call rm_nustatymas
	call ipPridejimas
	call naudojamu_baitu_isvedimas   ;gal dar tinka
	mov cx, 4
	lea dx, kom_and
	call print_komanda
	call modrm_print
	call isvestiKableli
	inc si 
	call IsvestiHexBaita
	cmp [w], 0
	JE next
	inc si 
	call IsvestiHexBaita
next:
	call printNew
	inc si 
	JMP loop_
	
unknownKom1:
	JMP unknownKom
unknownKomPOP:
	dec si
	JMP unknownKom
unknownKom:	
	add [ip_value], 1h
	call IsvestiHexBaita
	call isvestiTarpa
	lea dx, kom_unknown
	mov cx, 7
	call print_komanda
	call printNew
	inc si
	JMP loop_

analize ENDP
ipPridejimas PROC
	inc word ptr [ip_value]
	inc word ptr [ip_value]
	cmp [poslinkis], 0
	JE toliau
	inc word ptr [ip_value] ;nes jau minimaliai vienas poslinkio
	cmp [poslinkis], 1
	JE toliau 
	inc word ptr [ip_value]
toliau:
	RET
ipPridejimas ENDP

IsvestiHexBaita PROC
    xor dx, dx

    mov dl, buff[si]
    shr dl, 4
    call IsvestiHex
    
    mov dl, buff[si]
    and dl, 0Fh
    call IsvestiHex
    ret
IsvestiHexBaita ENDP

IsvestiHex PROC
    cmp dl, 9
    jle sk0_9
    add dl, 7
    
sk0_9:
    add dl, 30h
    mov byte ptr [outbuff], dl
    call print_byte_to_file
	;mov byte ptr [outbuff], 0
    ret
IsvestiHex ENDP

print_komanda PROC
    mov ah,40h
    mov bx,[out_fh]
	call ivestiesPatikra
    int 21h
    ret
print_komanda ENDP

printNew PROC
    lea dx, new_line
    mov cx, 2
    mov ax, 4000h
    mov bx, [out_fh]
	call ivestiesPatikra
    int 21h
    ret
printNew ENDP

print_byte_to_file PROC
	push bx
    mov ah, 40h
	lea dx, outbuff
	mov cx, 1
    mov bx, [out_fh]
	call ivestiesPatikra
    int 21h
	pop bx
    ret
print_byte_to_file ENDP


IsvestiHexZodi PROC 
	XOR dx, dx

	MOV dl, bh
	SHR dl, 4
	CALL IsvestiHex
	
	MOV dl, bh
	AND dl, 0Fh
	CALL IsvestiHex
	
	MOV dl, bl
	SHR dl, 4
	CALL IsvestiHex
	
	MOV dl, bl
	AND dl, 0Fh
	CALL IsvestiHex

	RET
	
IsvestiHexZodi ENDP

isvestiTarpa PROC
	mov ah, 40h
	lea dx, tarpas
	mov cx, 4
	mov bx, [out_fh]
	call ivestiesPatikra
	int 21h
	
	RET
isvestiTarpa ENDP
cs_print PROC
	lea dx, cs_kom
	mov cx, 3
	call print_komanda
	mov bx, [ip_value]
	call IsvestiHexZodi
	call isvestiTarpa
	RET
cs_print ENDP

reg_nustatymas PROC
	push di
	xor di, di
	mov al, buff[si]
	and al, 0000111b
	cmp al, 0000000b ;ax
	JE print_reg
	add di, 2
	cmp al, 0000001b ;cx
	JE print_reg
	add di, 2
	cmp al, 0000010b ;dx
	JE print_reg
	add di, 2
	cmp al, 0000011b ;bx
	JE print_reg
	add di, 2
	cmp al, 0000100b ;sp
	JE print_reg
	add di, 2
	cmp al, 0000101b ;bp
	JE print_reg
	add di, 2
	cmp al, 0000110b ;si
	JE print_reg
	add di, 2
	cmp al, 0000111b ;di
	JE print_reg
	JMP getback
print_reg:
	lea dx, kom_reg[di]
	mov cx, 2
	call print_komanda
getback:
	pop di
	RET
reg_nustatymas ENDP
adresavimo_reg_nustatymas PROC
	push di
	xor di, di
	mov al, buff[si]
	and al, 00111000b
	cmp al, 0000000b ;ax
	JE isprintint
	add di, 2
	cmp al, 00001000b ;cx
	JE isprintint
	add di, 2
	cmp al, 00010000b ;dx
	JE isprintint
	add di, 2
	cmp al, 00011000b ;bx
	JE isprintint
	add di, 2
	cmp al, 00100000b ;sp
	JE isprintint
	add di, 2
	cmp al, 00101000b ;bp
	JE isprintint
	add di, 2
	cmp al, 00110000b ;si
	JE isprintint
	add di, 2
	cmp al, 00111000b ;di
	JE isprintint
isprintint:
	cmp [w], 0
	JE pusbaitis
	lea dx, kom_reg[di]
	JMP baitasvis
pusbaitis:
	lea dx, w0[di]
baitasvis:
	mov cx, 2
	call print_komanda
	pop di
	RET
adresavimo_reg_nustatymas ENDP

sreg_nustatymas PROC
	push di
	xor di, di
	mov al, buff[si]
	and al, 00011000b
	cmp al, 00000000b ;ES
	JE print_sreg
	add di, 2
	cmp al, 00001000b ;cs
	JE print_sreg
	add di, 2
	cmp al, 00010000b ;SS
	JE print_sreg
	add di, 2
	cmp al, 00011000b ;DS
	JE print_sreg
	JMP getbacknow
print_sreg:
	lea dx, kom_sreg[di]
	mov cx, 2
	call print_komanda
getbacknow:
	pop di
	RET
sreg_nustatymas ENDP
rm_nustatymas PROC
	mov al, buff[si] ;rm pirmas
	and al, 00000111b
	cmp al, 00000000b 
	JE backoff
	inc[rm]
	cmp al, 00000001b
	JE backoff
	inc [rm]
	cmp al, 00000010b
	JE backoff
	inc [rm]
	cmp al, 00000011b
	JE backoff
	inc [rm]
	cmp al, 00000100b
	JE backoff
	inc [rm]
	cmp al, 00000101b
	JE backoff
	inc [rm]
	cmp al, 00000110b
	JE backoff
	inc [rm]
	cmp al, 00000111b
	JE backoff
backoff:
	RET
rm_nustatymas ENDP
mod_nustatymas PROC
	mov al, buff[si]
	and al, 11000000b
	mov [poslinkis], 0
	
	cmp al, 00000000b
	JE backnow
	
	mov [poslinkis], 1
	inc [mood]
	cmp al, 01000000b
	JE backnow
	
	mov [poslinkis], 2
	inc [mood]
	cmp al, 10000000b
	JE backnow
	
	mov [poslinkis], 0
	inc [mood]
backnow:
	RET
mod_nustatymas ENDP

modrm_print PROC
	
	xor ax, ax
	xor bx, bx
	cmp [mood], 3
    jne not_register_mode

    
    cmp [w], 0
    je print_byte_reg
    cmp [w], 3
    je print_word_reg
    jmp doprint  

print_byte_reg:
    mov bl, [rm]
	mov bh, 0
    shl bx, 1            
    mov cx, 2
    lea dx, w0[bx]
    jmp doprint

print_word_reg:
    mov bl, [rm]
	mov bh, 0
    shl bx, 1            
    mov cx, 2
    lea dx, kom_reg[bx]
    jmp doprint

not_register_mode:
    mov al, [rm]
    mov bl, [col]
    mul bl                  
    add al, [mood]
    mov ah, 0
    mov bx, ax
    shl bx, 3               
    lea dx, kom_modrm[bx]
    mov cx, 8
	
	mov al, kom_modrm[bx + 7]
    cmp al, ']'
	JE bracketskip
	cmp [poslinkis], 0
    je bracketskip
    mov [bracket_flag], 1
    jmp doprint
set_bracket_flag:
    mov [bracket_flag], 0

doprint:
    call print_komanda
    ret
bracketskip:
	call print_komanda
	ret
modrm_print ENDP
conditional_print_bracket PROC
    cmp [bracket_flag], 1
    jne skip_bracket
    mov cx, 1
    lea dx, skliaustas
    call print_komanda
skip_bracket:
    ret
conditional_print_bracket ENDP
naudojamu_baitu_isvedimas PROC
	dec si 
	call IsvestiHexBaita ;opk
	inc si
	call IsvestiHexBaita ;modrm
	
	cmp [poslinkis], 0
	JE pabaiga
	
	inc si
	call IsvestiHexBaita ;minimaliai vienas baitas poslinkio
	cmp [poslinkis], 2
	JE isvedimasAntras
	JMP sumazinimas
isvedimasAntras:
	inc si ;antras poslinkis
	call IsvestiHexBaita
	dec si
sumazinimas:
	dec si
pabaiga:
	call isvestiTarpa
	RET
naudojamu_baitu_isvedimas ENDP
isvedimasPoslinkioZ PROC
	cmp [poslinkis], 0
	JE now
	cmp [poslinkis], 2
	JE numazinimas
	JMP vienas
numazinimas:
	inc si
	mov bl, buff[si]
	inc si
	mov bh, buff[si]
	call IsvestiHexZodi
	mov [bracket_flag], 1
	call conditional_print_bracket
	ret
now:
	mov [bracket_flag], 0
	RET
vienas:
	inc si
	call IsvestiHexBaita
	mov [bracket_flag], 1
	call conditional_print_bracket
	ret
isvedimasPoslinkioZ ENDP
nunulinimas PROC
	mov [rm], 0
	mov [mood], 0
	mov [w], 3
	mov [d], 3
	mov [s], 3
	mov [poslinkis], 0
	RET
nunulinimas ENDP
w_nustatymas PROC
	mov al, buff[si]
	and al, 00000001b
	mov [w], 0
	cmp al, 00000000b
	JE returnas
	mov [w], 3
	cmp al, 00000001b
	JE returnas
returnas:
	RET
w_nustatymas ENDP
d_nustatymas PROC
	mov al, buff[si]
	mov [d], 0
	and al, 00000010b
	cmp al, 00000000b
	JE atgal
	cmp al, 00000010b
	JE kitas
kitas:
	mov [d], 1
atgal:
	ret
d_nustatymas ENDP

s_nustatymas PROC
	mov al, buff[si]
	and al, 00000010b
	mov [s], 0
	cmp al, 00000000b
	JE returnnow
	mov [s], 1
returnnow:
	ret
s_nustatymas ENDP

adresavimoCheck PROC
	mov al, buff[si]
	and al, 00111000b
	mov [adrCheck], al 
	ret
adresavimoCheck ENDP
isvestiKableli PROC
	mov cx, 2
	mov bx, [out_fh]
	call ivestiesPatikra
	mov ah, 40h
	lea dx, kablelis
	int 21h
	RET
isvestiKableli ENDP

isvestiSkliausta PROC
	mov cx, 1
	lea dx, skliaustas
	mov ah, 40h
	mov bx, [out_fh]
	call ivestiesPatikra
	int 21h

	RET
isvestiSkliausta ENDP
PROC ArPagalba
	MOV ax, es:[di]							
	CMP al, 2Fh									
	JNE nePagalba						
	CMP ah, 3Fh									
	JNE nePagalba
	MOV bx, 1								
	RET
	
nePagalba:
	RET
	
ArPagalba ENDP
PROC PraleistiTarpus
praleistiTarpus:	
	MOV al, es:[di]							
	dec [parametru_byte_count]
	CMP al, 20h									
	JE padidintiDI
	RET

padidintiDI:
	INC di
	JMP praleistiTarpus
	
PraleistiTarpus ENDP

PROC SkaitytiPav
skaitytiPav:	
	MOV al, es:[di]								
	INC di
	inc [parametro_pavadinimo_ilgis]
	dec [parametru_byte_count]
	CMP al, 13									
	JE skaitPavPab
	CMP al, 20h									
	JE skaitPavPab
	
	MOV [si], al								
	INC si
	JMP skaitytiPav
	
skaitPavPab:
    mov byte ptr [si], 0    
	RET
SkaitytiPav ENDP

print PROC
    mov ah, 09h
    int 21h
    RET
print ENDP

PraleistiIvestusTarpus PROC
startas:
	cmp al, 0  	;buff countas
	JE grizimas
	cmp inbuff[di], 32 ;tarpas
	JE tarpelis
	cmp inbuff[di], 13
	JE tarpelis
	mov bl, inbuff[di]
	mov buff[si], bl
	inc si
	dec al 
	inc di
tarpelis:
	dec al
	inc di
	JMP startas
grizimas:
	RET
PraleistiIvestusTarpus ENDP
ivestiesPatikra PROC
	cmp [ivestis], 1
	JE ekranas
	JMP sugrizimas
ekranas:
	mov bx, 1
sugrizimas:
	RET
ivestiesPatikra ENDP
convertASCII PROC
loopas:
    cmp di, si
    JE galas
    mov al, buff[si]
    cmp al, 40h
	JL mazesnis
	JMP didesnis
mazesnis:
	sub buff[si], 30h
	inc si 
	JMP loopas
didesnis:
	sub buff[si], 37h
	inc si 
	JMP loopas
galas:
    xor si, si
    RET
convertASCII ENDP

end start
