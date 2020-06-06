TITLE Programming Assignment #6   (RohitChaudhary_Project6.asm)

; Author: Rohit Chaudhary
; Last Modified: 5/31/2020
; OSU email address: chaudroh@oregonstate.edu
; Course number/section: CS 271/400
; Project Number: 6               Due Date: 6/7/2020
; Description: test program demonstrating functionality of ReadVal and WriteVal
;	procedures by prompting user to input 10 integers that will be stored in 
;	an array, and then calculates the sum and average of the inputted vals. 
;	ReadVal procedure implements the macro getString (macro prompts and gets 
;	keyboard string input) and converts the numeric string in to the
;	corresponding integer value while validating for sign and size. WriteVal
;	procedure implements the macro displayString (macro prints string stored
;	at specific memory location) converts a numeric value into a string of
;	digits are are printed.

INCLUDE Irvine32.inc

minVal = -2147483648			; min possible 32bit value
maxVal = 2147483647				; max possible 32bit value
ARRAYSIZE = 10					; size of array containing integers

;---------------------------------------
mDisplayString MACRO buffer:req
;
; displays contents of buffer to user by printing buffer to console.
;
; preconditions: OFFSET of buffer must be passed along with buffer when 
;	declaring the argument
;
; receives:
;		buffer = string to be printed, passed with preceding OFFSET
;
; returns: string is printed to window
;---------------------------------------
	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx
ENDM
;---------------------------------------
mGetString MACRO prompt:req, varName:req, varLen:req
;
; calls mDisplayString to display a prompt for user and subsequently read user
;	input with ReadString. user input stored in argument varName by ReadString 
;	and argument varLen placed in edx as used by ReadString.
;
; preconditions: prompt with OFFSET passed as argument, parameter varName is an 
;	array of characters, varLen is length of varLen
;
; postconditions: EAX updated with length of inputted string
;
; receives:
;		prompt = address of user prompt to be printed, passed with preceding OFFSET
;		varName = address ReadString user input array, passed with OFFSET
;		varLen = length of varLen as used by ReadString
;
; returns: array varLen updated with user input, eax contains length
;	of inputted string
;---------------------------------------
	push	ecx
	push	edx
	
	; display a prompt for input
	mDisplayString prompt

	; read using ReadString
	mov		edx, varName
	mov		ecx, varLen - 1
	call	ReadString
	pop		edx
	pop		ecx

ENDM

.data
title_str		BYTE		"PROGRAMMING ASSIGNMENT #6: Designing Low-Level "
				BYTE		"I/O procedures",10,13,0
author_str		BYTE		"Written By: Rohit Chaudhary",10,13,10,13,0
intro_str		BYTE		"Please provide 10 signed decmial integers.",10,13
				BYTE		"Each number needs to be small enough to "
				BYTE		"fit inside a 32-bit register.",10,13
				BYTE		"After you have finished inputting the raw numbers "
				BYTE		"I will display a list",10,13
				BYTE		"of the integers, their sum"
				BYTE		", and their average value.",10,13,10,13,0
prompt_str		BYTE		"Please enter a signed number: ",0
user_input_str	BYTE		12 DUP (0)
len_input		DWORD		SIZEOF user_input_str
user_val		SDWORD		?
array_nums		SDWORD		ARRAYSIZE DUP (0)
error_str		BYTE		"ERROR: You did not enter a signed number or your "
				BYTE		"number was too big.",10,13,0

.code
main PROC
; introduction procedure displays title, author, and user instructions (macro)
	push	OFFSET title_str
	push	OFFSET author_str
	push	OFFSET intro_str
	call	introduction
	
; get 10 integers from user and placed into array
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET error_str
	push	OFFSET prompt_str
	push	OFFSET user_input_str
	push	len_input
	push	OFFSET user_val
	push	minVal
	push	maxVal
	call	fillArray

; loop to print the contents of the array
; loop calls WriteVal procedure each time, WriteVal converts int -> str 
;	and then prints each int (macro) in a comma separated line

; procedure calcSum will calculate the sum of array contents and will print
;	sum to user(macro)

; procedure calcAvg will calculate the avg of array contents and will print
;	avg to user(macro)


	exit	; exit to operating system
main ENDP

;---------------------------------------
introduction proc
;
; displays program title, information, and user instructions by printing to
;	console. utilizes mDisplayString macro to print.
;
; preconditions: strings containing title, author, and instructions are 
;	prepared for display.
; 
; postconditions: relevant strings are printed to console
;
; receives: 
;		[ebp+16] @title_str
;		[ebp+12] @author_str
;		[ebp+8] @intro_str
;
; returns: none
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; print title, author, instructions
	mDisplayString	[ebp+16]
	mDisplayString	[ebp+12]
	mDisplayString	[ebp+8]

	; clear the stack
	pop		ebp
	ret		12
introduction ENDP
;---------------------------------------
fillArray proc
;
; repeats ReadVal procedure ARRAYSIZE times, taking the resulting number from 
;	ReadVal and adding it to an array
;
; preconditions: array of ARRAYSIZE is declared, preconditions for ReadVal are
;	met. procedure requires parameters for both the array and for ReadVal, as
;	ReadVal will use fillArray parameters to as its own arguments.
; 
; postconditions: array is filled, user_val is updated with last inputted num
;
; receives: 
;		[ebp+40]	OFFSET array_nums = array receiving nums
;		[ebp+36]	ARRAYSIZE = size of array_nums
;		[ebp+32]	@error_str	= error msg to display
;		[ebp+28]	@prompt_str = string asking user to input a value
;		[ebp+24]	@user_input_str = str to receive user input
;		[ebp+20]	len_input = size of user_input_str
;		[ebp+16]	@user_val = address of variable to be updated with converted num
;		[ebp+12]	minVal = minimum acceptable input value
;		[ebp+8]		maxVal = maximum acceptable input value
;
; returns: updated array
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; prepare loop
	mov		edi, [ebp+40]			; array_nums
	mov		esi, [ebp+16]			; current int to go into array
	mov		ecx, [ebp+36]			; ARRAYSIZE

; LOOP GETTING STUCK AFTER ENTERING 1ST DIGIT. EITHER PROBLEM WITH READVAL 
; OR HERE WITH FILLARRAY. something to do with stack?
Fill:
	; save relevant values before ReadVal
	push	ecx
	push	edi
	push	esi

	; items needed to call ReadVal
	push	[ebp+32]				; OFFSET error_str
	push	[ebp+28]				; OFFSET prompt_str
	push	[ebp+24]				; OFFSET user_input_str
	push	[ebp+20]				; len_input
	push	[ebp+16]				; OFFSET user_val
	push	[ebp+12]				; minVal
	push	[ebp+8]					; maxVal
	call	ReadVal

	; restore values
	pop		esi
	pop		edi
	pop		ecx

	; add the new integer to the array
	mov		eax, [esi]
	mov		[edi], eax
	add		edi, 4

	; next num
	loop	Fill

	; clear the stack
	pop		ebp
	ret		36
fillArray ENDP
;---------------------------------------
ReadVal proc
;
; gets string of digits from user (using mGetString macro) and converts the
;	inputted string to a signed int value. validation performed to make sure
;	minVal <= user_val <= maxVal. this implies that ReadVal can accept and 
;	validate signed integers.
;
; preconditions: string is prepared to prompt user for input, variable declared
;	for inputted variable to be stored.
;
; postconditions: prompt string is printed
;
; receives:
;		[ebp+32] @error_str	= error msg to display
;		[ebp+28] @prompt_str = string asking user to input a value
;		[ebp+24] @user_input_str = str to receive user input
;		[ebp+20] len_input = size of user_input_str
;		[ebp+16] @user_val = address of variable to be updated with converted num
;		[ebp+12] minVal = minimum acceptable input value
;		[ebp+8] maxVal = maximum acceptable input value
;		[ebp-4] x = holds intermediate conversions
;		[ebp-8] temp = holds local ascii_val
;
; returns: user_val updated with converted signed int
;---------------------------------------

	; set up the stack frame
	push	ebp
	mov		ebp, esp
	sub		esp, 8			; create local var

GetNumber:
	; prompt the user
	mGetString	[ebp+28], [ebp+24], [ebp+20]
	; eax contains length of inputted string
	; NOT ALLOWED TO PASS VALS BY REGISTERS, need new param for mGetString
	; param will be passed to store length of string

	; time to convert input str -> int
	cld
	mov		esi, [ebp+24]			; user input is going to be accessed
	mov		ecx, eax				; loop initalizer = size of input
	mov		DWORD PTR [ebp-4], 0	; initialize x
	mov		edx, 1
	push	edx

IterateInput:
	mov		eax, 0					; clear reg for next num to process
	lodsb							; load [user input] into eax

	; check to see if leading -/+ sign given
	mov		ebx, 45		; ASCII - = 45
	cmp		eax, ebx
	je		NegativeNum
	mov		ebx, 43		; ASCII + = 43
	cmp		eax, ebx
	je		NextNum
	jmp		Check		; no leading sign, move on

NegativeNum:
	mov		edx, -1
	push	edx
	jmp		NextNum

Check:
	; validate that ascii between 48-57
	mov		DWORD PTR [ebp-8], eax
	push	eax
	call	validateASCII
	jz		Error
	mov		eax, DWORD PTR [ebp-8]

Conversion:
	; conversion: x = 10 * x + (user_input[i] - 48)
	mov		ebx, 48
	sub		eax, ebx
	push	eax
	mov		eax, DWORD PTR [ebp-4]
	mov		ebx, 10
	mul		ebx
	mov		DWORD PTR [ebp-4], eax
	pop		eax
	add		eax, DWORD PTR [ebp-4]
	mov		DWORD PTR [ebp-4], eax
NextNum:
	loop	IterateInput

; if input was negative num, restore negative state
	pop		edx
	mov		ebx, edx
	imul	ebx

UpdateVal:
	; done, move converted result to user_val
	mov		edi, [ebp+16]
	mov		[edi], eax

	; validate the int to be within range
	push	eax
	push	[ebp+12]
	push	[ebp+8]
	call	ValidateInt
	jz		Error

	; done with str -> int conversion
	; int found to also be within range
	jmp		DoneConverting

Error:
	mDisplayString [ebp+32]
	jmp		GetNumber

DoneConverting:
	; clear the stack
	mov		esp, ebp
	pop		ebp
	ret		28
ReadVal ENDP
;---------------------------------------
validateASCII proc
;
; takes ascii value and determines whether value is a digit, meaning between
;	ascii values 48 - 57. sets ZF if not a digit, clears ZF it is a digit
;
; preconditions: decimal ascii value to validate is passed as parameter
;
; postconditions: ZF is changed accordingly
;
; receives:
;		[ebp+8] ascii_val = value to validate
;
; returns: updates ZF accordingly
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; if 48 <= ascii_val <= 57, set flag
	mov		eax, [ebp+8]
	mov		ebx, 48
	cmp		eax, ebx
	jl		InvalidASCII
	mov		ebx, 57
	cmp		eax, ebx
	jg		InvalidASCII
	or		eax, 1				; valid digit, clear ZF and finish
	jmp		Done

InvalidASCII:
	test	eax, 0

Done:
	; clear the stack frame
	pop		ebp
	ret		4
	
validateASCII ENDP
;---------------------------------------
validateInt proc
;
; takes integer value and determines whether value is between valid, meaning
;	minVal <= int_val <= maxVal. Zero flag is set if value is not valid, cleared
;	otherwise.
;
; preconditions: valid integer value to test, minVal < maxVal
;
; postconditions: ZF is changed accordingly
;
; receives:
;		[ebp+16] int_val = value to validate
;		[ebp+12] minVal = minimum acceptable input value
;		[ebp+8] maxVal = maximum acceptable input value
;
; returns: updates ZF accordingly
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; validate int to be within range
	mov		eax, [ebp+16]
	mov		ebx, [ebp+12]
	cmp		eax, ebx
	jl		InvalidInt
	mov		ebx, [ebp+8]
	cmp		eax, ebx
	jg		InvalidInt
	or		eax, 1
	jmp		ValIntDone			; valid int, clear ZF and finish

InvalidInt:
	test	eax, 0

ValIntDone:
	; clear the stack frame
	pop		ebp
	ret		4
	
validateInt ENDP
;---------------------------------------
WriteVal proc
;
;
;
; preconditions:
;
; postconditions:
;
; receives:
;
; returns:
;---------------------------------------

; clear the stack
	pop		ebp
	ret
WriteVal ENDP
;---------------------------------------
calcSum proc
;
;
;
; preconditions:
;
; postconditions:
;
; receives:
;
; returns:
;---------------------------------------

; clear the stack
	pop		ebp
	ret
calcSum ENDP
;---------------------------------------
calcAvg proc
;
;
;
; preconditions:
;
; postconditions:
;
; receives:
;
; returns:
;---------------------------------------

; clear the stack
	pop		ebp
	ret
calcAvg ENDP
END main
