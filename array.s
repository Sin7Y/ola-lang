	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 14, 0
	.globl	_processArray                   ## -- Begin function processArray
	.p2align	4, 0x90
_processArray:                          ## @processArray
	.cfi_startproc
## %bb.0:                               ## %entry
	testq	%rsi, %rsi
	je	LBB0_3
## %bb.1:                               ## %loop.preheader
	xorl	%eax, %eax
	.p2align	4, 0x90
LBB0_2:                                 ## %loop
                                        ## =>This Inner Loop Header: Depth=1
	incq	%rax
	cmpq	%rsi, %rax
	jb	LBB0_2
LBB0_3:                                 ## %exit
	retq
	.cfi_endproc
                                        ## -- End function
.subsections_via_symbols
