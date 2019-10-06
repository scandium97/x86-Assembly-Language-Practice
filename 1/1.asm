;汇编源程序 
;计算并输出斐波那契数列前12个数
PAGE 60, 132

;------------------------------
;交换2个DATA, MARCO
SWAP_DATA  MACRO  DAT1, DAT2
		mov  BX,  DAT1
		mov  AX,  DAT2
		XOR  BX,  AX
		XOR  AX,  BX
		XOR  BX,  AX
		mov  DAT1, BX
		mov  DAT2, AX
		ENDM

;--------------------------------------
		.MODEL SMALL
		.STACK 64
;---------------------
		.DATA
MyLength	db		0CH
data1	dw		12 dup(0)
ten      db     0AH
zero    db   30H
;--------------------
		.CODE
MAIN	PROC FAR
		mov  ax,  @DATA
		mov  ds,  ax
		
		sub cx,cx
		mov cl,  MyLength
		mov di,  offset data1
		mov ax,  0001h
		mov dx,  0001h
		mov [di] , ax
		inc di
		inc di 
		mov[di], ax
		inc di
		inc di
		dec cl
		dec cl
	; ax = f(n),  dx = f(n-1), bx作为运算的中间寄存器，cx做循环寄存器，可以在不使用内存的情况下计算完成
	main_loop:
		add ax, dx
		mov bx, ax 
		sub bx, dx
		mov dx, bx
		mov [di], ax
		inc di
		inc di
		dec cl
		jnz main_loop

		;;输出

		mov bl,  ten
		mov cl,  MyLength
		mov di,  offset data1
	; 这是对f(n)做循环
	outputloop:
		mov ax, [di]
		mov bl, 0h

	;计算十进制表示，把低位数字的ascii字符压入堆栈，用bl寄存器记录位数
	divide_loop:
		div ten

		sub dx,dx
		mov bh, al
		mov dl, ah
		add dl, zero
		push dx 
		inc bl

		sub ax,ax
		mov al, bh
		add al,0h
		jnz divide_loop
		;;输出堆栈中的值
	stack_loop:
		pop dx
		mov ah, 02h
		int 21H
		dec bl
		jnz stack_loop
		; ','分隔
		mov dl, ','
		int 21H

		inc di
		inc di
		dec cl
		jnz outputloop

		mov ah, 4CH
		int 21H
MAIN	ENDP
;-------------------------------
		END    MAIN