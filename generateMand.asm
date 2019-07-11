%define MAX_ITER 256

	section .data
double_one:	dq	1.0
double_two:	dq	2.0
double_four:	dq	4.0

	section .text

	global generateMand

generateMand:
	push rbp
	mov rbp, rsp
	;mov [rbp+16], rdi 						; int *pixels
	;mov [rbp+24], rsi 						; int N
	;mov [rbp+32], rdx 						; int xMouse
	;mov [rbp+40], rcx 						; int yMouse
	;mov [rbp+48], r8							; double *x_S
	;mov [rbp+56], r9							; double *y_S
	;movsd [rbp+64], xmm0					; double zoom

	sub rsp, 16
	movdqa [rsp], xmm7
	sub rsp, 16
	movdqa [rsp], xmm8
	sub rsp, 16
	movdqa [rsp], xmm9
	sub rsp, 16
	movdqa [rsp], xmm10

					; FUNCTION START

	cvtsi2sd xmm10, rsi						;convert int N to double
	movsd xmm9, [double_four]
	divsd xmm9, xmm10							;in L xmm9 4.0/N
	movddup xmm9, xmm9						;in H&L xmm9 4.0/N
	movddup xmm8, [double_two]		;in H&L xmm8 2.0

	movsd xmm7, [double_one]
	divsd xmm7, xmm0
	movddup xmm7, xmm7						;in H&L xmm7 1.0/zoom

	movhpd xmm0, [r9]
	movlpd xmm0, [r8]							;in xmm0 y_S:x_S

	cvtsi2sd xmm1, rcx
	movddup xmm1, xmm1
	cvtsi2sd xmm1, rdx						;in xmm1 yMouse:xMouse float

	mulpd xmm1, xmm9							;in xmm1 yMouse*4.0/N:
	subpd xmm1, xmm8							;in xmm1 yMouse*4.0/N-2.0:
	mulpd xmm1, xmm7							;in xmm1 (yMouse*4.0/N-2.0)/zoom:

	addpd xmm0, xmm1							;new y_S:x_S
	movsd [r8], xmm0							;update x_S in memory
	movdqa xmm2, xmm0
	unpckhpd xmm2, xmm2
	movsd [r9], xmm2							;update y_S in memory

	mov r8, rsi										;r8 = y_row
																														; xmm0 y_S:x_S MUST BE SAVED
loop_row:
	cvtsi2sd xmm1, r8
	mulsd xmm1, xmm9
	subsd xmm1, xmm8
	mulsd xmm1, xmm7
	movdqa xmm3, xmm0
	unpckhpd xmm3, xmm3
	addsd xmm1, xmm3
	shufpd xmm1, xmm1, 1					;in H xmm1 c_im

	mov r9, rsi										;r9 = x_col
loop_col:
	cvtsi2sd xmm1, r9
	mulsd xmm1, xmm9
	subsd xmm1, xmm8
	mulsd xmm1, xmm7
	addsd xmm1, xmm0							;in L xmm1 c_re
																														; xmm1 c_im:c_re MUST BE SAVED
	xorpd xmm2, xmm2							;in xmm2 complex y:x				; xmm2 y:x MUST BE SAVED
	xor rcx, rcx									;in rcx iteration
loop_mand:
	movdqa xmm3, xmm2							;copy of y:x in xmm3
	mulpd xmm3, xmm3
	haddpd xmm3, xmm3
	ucomisd xmm3, [double_four]
	ja end_loop_mand							;condition x^2+y^2<4
																														; complex multiplication
	movddup xmm4, xmm2						;in xmm4 x:x
	mulpd xmm4, xmm2							;in xmm4 xy:x^2
	movdqa xmm3, xmm2							;in xmm3 copy of xmm2
	unpckhpd xmm3, xmm3						;in xmm3 y:y
	shufpd xmm2, xmm2, 1					;in xmm2 x:y
	mulpd xmm3, xmm2							;in xmm3 yx:y^2
	addsubpd xmm4, xmm3						;in xmm4 (xy+yx):(x^2-y^2)
	movdqa xmm2, xmm4
	addpd xmm2, xmm1							;update y:x in xmm2
	inc rcx
	cmp rcx, MAX_ITER
	jb loop_mand

end_loop_mand:
	mov rax, r8
	mul rsi
	lea rax, [rax+r9]
	mov dword [rdi+4*rax], 0xFF000000
	;or [rdi+4*rax], cl
	;or [rdi+4*rax+1], cl
	or [rdi+4*rax+2], cl

	dec r9
	jnz loop_col									;end of loop_col

	dec r8
	jnz loop_row									;end of loop_row

end:

	movdqa  xmm10, [rsp]
	add rsp, 16
	movdqa xmm9, [rsp]
	add rsp, 16
	movdqa xmm8, [rsp]
	add rsp, 16
	movdqa xmm7, [rsp]

	mov rsp, rbp
	pop rbp
	ret
