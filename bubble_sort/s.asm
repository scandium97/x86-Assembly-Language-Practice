;;
;;冒泡排序的汇编小程序
;;
page 60,132
;---------------------
;marco 
;-------------------
;用于交换内存中2个整型数据的MACRO,使用位运算
SWAP_DAT MACRO   DATA1,  DATA2
		mov  ax, DATA1
		mov  dx, DATA2
		xor  ax,  dx
		xor  dx,  ax
		xor  ax,  dx
		mov  DATA1, ax
		mov  DATA2, dx
	ENDM
;-----------------------------
		.MODEL SMALL
		.STACK 64

;-----------------------
		.DATA
array dw  00ffH, 00efh, 0320h, 0098h, 0077h,  0124h, 0123h, 0074h,  0089h,0144H

myLength = ($-array)/2
count_i dw (?)
myflag  db  00h
ten      db     0AH
zero    db   30H
CR  	EQU   0DH
LF		EQU   0AH
SPACE 		EQU   10H
;----------------------

		.CODE
MAIN PROC
	mov ax,  @DATA
	mov ds, ax
	;------
	call DISPLAY


	mov cx, myLength
outloop:
	;记录外循环循环变量
	mov count_i , cx

	mov cx, myLength
	dec cx
	mov si , offset array
	;BL 做标致变量
	mov bl, myflag
	;;内循环开始
innerloop:
	mov ax, [si]
	cmp ax, [si+2]
	jc no_swap
	SWAP_DAT [si], [si+2]
	inc bl
no_swap:
	inc si
	inc si
	dec cx
	jnz innerloop
	;;如果一次交换都没有发生，就直接结束所有循环
	cmp bl, 00h
	je sort_over

	mov cx, count_i
	dec cx
	jnz outloop

sort_over:
	call DISPLAY
	;------
	mov ah, 4CH
	int 21h
MAIN ENDP
;--------------------
;DISPLAY PROC 输出整数类型的数据所用的函数，不太涉及内存
DISPLAY PROC
		;;输出

		mov bl,  ten
		mov cl,  myLength
		mov di,  offset array
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
	;;判断是不是数组中最后一个数，不是要加','分隔
		cmp cl, 01h 
		jz no_comma
		; ','分隔
		mov dl, ','
		int 21H
	no_comma:
		inc di
		inc di
		dec cl
		jnz outputloop


		mov ah , 02h 
		mov dl , CR
		int 21h
		mov dl, LF
		int 21H
		ret
DISPLAY ENDP
; entry of program
		END MAIN
