;;这是一个走迷宫的交互界面，
;;使用wasd控制方向，输入q即可退出界面
;;
page 60,132
;---------------------
;marco 

;-----------------------------
		.MODEL SMALL
		.STACK 64

;-----------------------
		.DATA
posrow dw 01h
poscol dw 01h

mystring  db '*****************','$'
		db   '*@*** ***      **','$'
		db   '* ***      *** **','$'
		db   '* *** **** ******','$'
		db   '* *** **** **   *','$'
		db   '*     ****    * *','$'
		db   '*****************','$'

myWidth EQU 17
realWidth EQU 18
myHeight EQU  7
destrow EQU  4
destcol EQU  15

operator db (?)

cursorrow db 9
cursorcol db 30

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
	call ClearScr
gameloop:
	call DrawMaze
	call GetKeyboard
	;;键盘输入Q代表退出
	cmp operator, 'Q'
	je EXIT
	;; 
	call UPDATE_POS
	jmp gameloop
	;------
EXIT:
	mov ah, 4CH
	int 21h
MAIN ENDP
;----------------------
;;绘制迷宫
DrawMaze PROC
		;每次绘图之前重置光标的位置
		mov cursorrow,9 
		mov  ah, 02h
		mov  bh,  00h
		mov  dl, cursorcol
		mov  dh, cursorrow
		int  10h
		;做初始化
		mov si, offset mystring
		mov cx, myHeight
	draw_maze_str:
		mov ah, 09h
		mov dx, si
		int 21h
		;设置字符串的内存位置
		mov bx, realWidth
		add si, bx
		;修改光标起始位置, row_number + 1
		mov dl,cursorcol
		mov dh,cursorrow
		inc dh
		mov cursorrow, dh
		mov ah, 02h
		mov bh, 00h 
		int 10h
		; 循环结尾
		dec cx
		jnz draw_maze_str
	ret
DrawMaze ENDP
;-----------------------
;;根据按键修改位置
UPDATE_POS PROC
		;初始化，找到@的位置
		mov si, offset mystring
		mov bx, realWidth
		mov ax, 0h 
		mov ax, posrow
		mul bx
		add ax, poscol
		add si, ax
		;;此时si应该指着@
		mov al, operator
		cmp al, 'W'
		je case_up
		cmp al, 'S'
		je  case_down
		cmp al, 'D'
		je case_right
		cmp al, 'A'
		je case_left
		jmp UPDATE_OVER
	case_up:
		mov al, [si] - realWidth
		cmp al, '*'
		jz UPDATE_OVER
		mov ax, posrow
		dec ax 
		mov posrow, ax
		jmp UPDATE_OVER
	case_down:
		mov al, [si] + realWidth
		cmp al, '*'
		jz UPDATE_OVER
		mov ax, posrow
		inc ax 
		mov posrow, ax
		jmp UPDATE_OVER
	case_right:
		mov al, [si] + 1
		cmp al, '*'
		jz UPDATE_OVER
		mov ax, poscol
		inc ax
		mov poscol, ax
		jmp UPDATE_OVER
	case_left:
		mov al, [si] - 1
		cmp al, '*'
		jz UPDATE_OVER
		mov ax, poscol
		dec ax
		mov poscol, ax
		jmp UPDATE_OVER
UPDATE_OVER:
		;先把原位置@改了
		mov cl, ' '
		mov [si], cl
		;需要重新把@写到新位置上
		mov si, offset mystring
		mov bx, realWidth
		mov ax, 0h 
		mov ax, posrow
		mul bx
		add ax, poscol
		add si, ax
		mov cl, '@'
		mov [si], cl
		mov operator , '?'
		ret
UPDATE_POS ENDP
;----------------------
;获取键盘上的按键，必须是wasdq中的一个，大小写无所谓
GetKeyboard PROC
	wait_again:
		mov ah, 01
		int 16h
		jz wait_again

		mov ah, 0 
		int 16h
		cmp al, 'Q'
		je  case_q
		cmp al, 'q'
		je case_q
		cmp al, 'W'
		je case_w
		cmp al, 'w'
		je case_w
		cmp al, 'S'
		je  case_s
		cmp al, 's'
		je case_s
		cmp al, 'D'
		je case_d
		cmp al, 'd'
		je case_d
		cmp al, 'A'
		je case_a
		cmp al, 'a'
		je case_a
		;;不是上述字母，就再等待输入
		jmp wait_again
	case_q:
		mov operator, 'Q'
		jmp over
	case_w:
		mov operator, 'W'
		jmp over
	case_a:
		mov operator, 'A'
		jmp over
	case_s:
		mov operator, 'S'
		jmp over
	case_d:
		mov operator, 'D'
		jmp over
	over:
		ret
GetKeyboard ENDP
;----------------------

;---------------------------
;用于清除屏幕
ClearScr PROC
		mov  ah,  06
		mov  al,  00
		mov  bh,  07
		mov  ch, 00
		mov  cl, 00
		mov  dx, 184FH
		int 10H
		ret
ClearScr ENDP
;----------------------------
;;将光标移动到特定位置
SetCursor PROC
		mov  ah, 02h
		mov  bh,  00h
		mov  dx,  0b17h
		int 10h
		ret
SetCursor ENDP
;-----------------------------

;---------------------------

; entry of 
		END MAIN
