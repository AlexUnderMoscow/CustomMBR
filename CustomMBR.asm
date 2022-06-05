org  07c00h  ; set location counter  07c00h(Bochs) 100h
start db 090h
mov ax, 0x1000
mov ss,ax
mov sp, 0xfffe  

newPass:
        mov si, Message
        push si
;void DataInput(char* message)
        call DataInput
        add sp,2

        lea bx,[val]
        mov word [bx],0xFFFF
        mov word  [bx+2],0xFFFF  ; val = FFFF FFFF

        lea ax, [pswd]
        push ax
;void crc32gen(char* password)
        call  crc32gen
        add sp,2

        mov cx,4
        lea si, [crc3]
        lea di, [crc32input]
        cld
        repe cmpsb
        jz normalBoot
        jmp newPass
normalBoot:
        mov ax,cs
        mov ds, ax
        mov ax, 1000h
        mov ss, ax
        mov es,ax
        lea bx, [record]        ; MBR record
        mov dh, [bx+1]          ; Head 
        mov dl, 0
        mov cx, [bx+2]          ; Sector, Cylinder
        mov ah,2
        mov al,0x0F             ; sectors num
        xor bx, bx
        int  13h
        jmp 0x1000:0x0410       ;  entry point 0x1000:0x0410
        jmp $

DataInput:
        push bp
        mov bp,sp
        mov si, [bp+4]
        mov ah, 0x0E            ; BIOS function for print.

next_letter:
        lodsb
        cmp al,0
        jz pswdInput
        int 10h                 ; print letter
        jmp next_letter

pswdInput:
        mov cx, 8
        lea si,[pswd]
nextPswdLetter:
        mov ah, 0
        int 16h                 ; wait pswd
        cmp al,0x0d             ; Enter key
        jz exitDataInput
        mov [si], al
        inc si
        mov ah, 0x0E            ; BIOS function for print.
        int 10h                 ; print letter
        loop  nextPswdLetter
exitDataInput:
    pop bp
    ret


;void crc32gen(char* password)
crc32gen:
        push bp
        mov bp,sp
        mov bx, [bp+4]          ; index if pswd[]
        mov cx,8                ; 8 chars in pswd
        lea di,[val]
        lea si,[crc32input]
next_char:
        xor ax,ax               ; ax = 0
        mov al, byte [bx]       ; al = pswd[i]
        inc bx                  ; index++
        mov word  [si], 0
        mov word  [si+2], 0     ; crc = 0
        xor dx,dx               ; dx = 0
        xor ax,word [di]        ; low  val
        and ax,0xFF             ; byte
        push cx                 ; save loop counter
        mov cx,8

next_bit:
        push ax                 ; moving xor al,byte [si]
        xor al,byte  [si]       ; (byte ^ crc) & 0x01

        and al, 0x01
        jz zero

;-----------------------------------------------------
        call crcRShift1         ;crc =(crc>>1) ^ pattern
        push bx
        lea bx, [pattern]
        mov dx, [bx]
        xor dx, [si]
        mov [si], dx
        mov dx, [bx+2]
        xor dx, [si+2]
        mov [si+2], dx 
        
        pop bx
;-----------------
        jmp exit
zero:
;-----------------------------------------------------
        call crcRShift1        ;crc crc >> 1  

;-----------------
exit:     
        pop ax                  ; restore byte
        shr al,1                ; byte >> 1            
        loop next_bit

;-----------------------------------------------------
        mov dx, word  [di]      ; val = (val>>8) ^ crc
        mov dl,dh               ; Low bits >> 8
        mov dh, byte  [di+2]
        mov word  [di], dx
        mov dx, word  [di+2]
        mov dl,dh               ; Hi bits >> 8
        mov dh,0
        mov word  [di+2], dx

        xor dx, [si+2]
        mov [di+2], dx          ;Hi word val
        mov dx, [si]
        xor dx,[di]
        mov [di],dx             ; Low word val   
    
;-----------------
        pop cx                  ; restore loop couter
        loop next_char

;-----------------------------------------------------  
        neg dx                   ;crc = -1 - val
        add dx,0xFFFF
        mov [si], dx
        mov dx,[di+2]
        neg dx
        add dx, 0xFFFF
        mov [si+2],dx
;----------------
exitcrc32gen:
        pop bp
        ret

crcRShift1:
        lea si,[crc32input]
        mov dx,word [si+2]             ;crc32input(hi word)
        shr dx,1
        mov word [si+2],dx             ;crc32input(hi word)
        mov dx, word [si]              ;crc32input(lo word)
        jnc shift
        shr dx, 1
        or  dx,0x8000
        jmp save
shift:
        shr dx,1
save:                                ;crc32input(lo word)
        mov word [si],dx
        ret



Message:        db "Enter password (1-8 characters): ", 0
crc3            dw 0x259e,0xaff5   ;crc32("test1234")
crc32input      dw 0x0000, 0x0000
pswd            db 8 dup (0x00)
val             dw 0xFFFF, 0xFFFF
pattern         dw 0x8320, 0xEDB8
null            db 494-($-start) dup(0)
record          db 080h,00h,01h,00h,0A5h,0FFh,0FFh,0FFh,00h,00h,00h,00h,050h,0C3h,00h,00h
                dw 0xAA55

