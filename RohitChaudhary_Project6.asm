TITLE Programming Assignment #6   (RohitChaudhary_Project6.asm)

; Author: Rohit Chaudhary
; Last Modified: 6/6/2020
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
mGetString MACRO prompt:req, varName:req, varLen:req, input_len:req
;
; calls mDisplayString to display a prompt for user and subsequently read user
;	input with ReadString. user input stored in argument varName by ReadString 
;	and argument varLen placed in edx as used by ReadString. length of users
;	input from ReadString (EAX) stored in input_len
;
; preconditions: prompt with OFFSET passed as argument, parameter varName is an 
;	array of characters, varLen is length of varLen
;
; postconditions: varName and input_len updated
;
; receives:
;		prompt = address of user prompt to be printed, passed with preceding OFFSET
;		varName = address ReadString user input array, passed with OFFSET
;		varLen = length of varLen as used by ReadString
;		input_len = length (bytes) if user input after ReadString, from EAX, passed with OFFSET
;
; returns: array varLen updated with user input, eax contains length
;	of inputted string
;---------------------------------------
	push	ecx
	push	edx
	push	edi
	
	; display a prompt for input
	mDisplayString prompt

	; read using ReadString
	mov		edi, input_len
	mov		edx, varName
	mov		ecx, varLen - 1
	call	ReadString
	mov		[edi], eax

	pop		edi
	pop		edx
	pop		ecx

ENDM

.data
title_str			BYTE		"PROGRAMMING ASSIGNMENT #6: Designing Low-Level "
					BYTE		"I/O procedures",10,13,0
author_str			BYTE		"Written By: Rohit Chaudhary",10,13,10,13,0
intro_str			BYTE		"Please provide 10 signed decmial integers.",10,13
					BYTE		"Each number needs to be small enough to "
					BYTE		"fit inside a 32-bit register.",10,13
					BYTE		"After you have finished inputting the raw numbers "
					BYTE		"I will display a list",10,13
					BYTE		"of the integers, their sum"
					BYTE		", and their average value.",10,13,10,13,0
prompt_str			BYTE		"Please enter a signed number: ",0
user_input_str		BYTE		12 DUP (0)
max_len_input		DWORD		SIZEOF user_input_str
actual_len_input	DWORD		?
user_val			SDWORD		?
user_val_sign		SDWORD		?
array_nums			SDWORD		ARRAYSIZE DUP (0)
error_str			BYTE		"ERROR: You did not enter a signed number or your "
					BYTE		"number was too big.",10,13,0
user_output_str		BYTE		12 DUP (0)
max_len_output		DWORD		SIZEOF user_output_str
current_array_num	SDWORD		?
array_str			BYTE		10,13,"You entered the following numbers: ",10,13,0
comma				BYTE		", ",0
sum_str				BYTE		10,13,"The sum of these numbers is: ",0
average_str			BYTE		10,13,"The rounded average is: ",0
sum					SDWORD		?
average				SDWORD		?
goodbye_str			BYTE		"Thanks for playing!",0


.code
main PROC
; introduction procedure displays title, author, and user instructions (macro)
	push	OFFSET title_str
	push	OFFSET author_str
	push	OFFSET intro_str
	call	introduction
	
; get 10 integers from user and placed into array
	push	OFFSET user_val_sign
	push	OFFSET actual_len_input
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET error_str
	push	OFFSET prompt_str
	push	OFFSET user_input_str
	push	max_len_input
	push	OFFSET user_val
	push	minVal
	push	maxVal
	call	fillArray

; displayArray will loop through array and print array
	push	OFFSET comma
	push	OFFSET current_array_num
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET array_str
	push	OFFSET user_output_str
	push	max_len_output
	call	displayArray

; display stats will display both the sum and average of the 10 nums
	push	OFFSET user_output_str
	push	max_len_output
	push	OFFSET sum
	push	OFFSET average
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET sum_str
	push	OFFSET average_str
	call	displayStats

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
;		[ebp+48]	OFFSET user_val_sign = sign of user's input value
;		[ebp+44]	OFFSET acutal_len_input = length of user's input in bytes
;		[ebp+40]	OFFSET array_nums = array receiving nums
;		[ebp+36]	ARRAYSIZE = size of array_nums
;		[ebp+32]	@error_str	= error msg to display
;		[ebp+28]	@prompt_str = string asking user to input a value
;		[ebp+24]	@user_input_str = str to receive user input
;		[ebp+20]	max_len_input = size of user_input_str
;		[ebp+16]	@user_val = address of variable to be updated with converted num
;		[ebp+12]	minVal = minimum acceptable input value
;		[ebp+8]		maxVal = maximum acceptable input value
;
; returns: updated array
;---------------------------------------
	; set up the stack frame
	push		ebp
	mov		ebp, esp

	; prepare loop
	mov		edi, [ebp+40]			; array_nums
	mov		esi, [ebp+16]			; current int to go into array
	mov		ecx, [ebp+36]			; ARRAYSIZE

Fill:
	; save relevant values before ReadVal
	push	ecx
	push	edi
	push	esi

	; items needed to call ReadVal
	push	[ebp+48]				; OFFSET user_val_sign
	push	[ebp+44]				; OFFSET actual_len_input
	push	[ebp+32]				; OFFSET error_str
	push	[ebp+28]				; OFFSET prompt_str
	push	[ebp+24]				; OFFSET user_input_str
	push	[ebp+20]				; max_len_input
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
	ret		44
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
;		[ebp+40] @user_val_sign = sign (1/-1) of user's input value
;		[ebp+36] @actual_len_input = length (bytes) of user input string
;		[ebp+32] @error_str	= error msg to display
;		[ebp+28] @prompt_str = string asking user to input a value
;		[ebp+24] @user_input_str = str to receive user input
;		[ebp+20] max_len_input = size of user_input_str
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
	sub		esp, 8					; create local var

GetNumber:
	; prompt the user
	mGetString	[ebp+28], [ebp+24], [ebp+20], [ebp+36]

	; time to convert input str -> int
	cld
	mov		edi, [ebp+36]
	mov		ecx, [edi]				; loop counter = length of user input
	mov		esi, [ebp+24]			; user input is going to be accessed
	mov		DWORD PTR [ebp-4], 0	; initialize x
	mov		edx, 1			
	
	; update user_val_sign
	push	edi
	mov		edi, [ebp+40]
	mov		[edi], edx
	pop		edi
	push	edx

IterateInput:
	mov		eax, 0					; clear reg for next num to process
	lodsb							; load [user input] into eax

	; check to see if leading -/+ sign given
	mov		ebx, 45					; ASCII - = 45
	cmp		eax, ebx
	je		NegativeNum
	mov		ebx, 43					; ASCII + = 43
	cmp		eax, ebx
	je		NextNum
	jmp		Check					; no leading sign, move on

NegativeNum:
	mov		edx, -1
	; update user_val_sign
	push	edi
	mov		edi, [ebp+40]
	mov		[edi], edx
	pop		edi
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

UpdateVal:
	; done, move converted result to user_val
	mov		edi, [ebp+16]
	mov		[edi], eax

	; validate the int to be within range
	push	[ebp+40]				;@user_val_sign
	push	[ebp+16]				;@user_val
	push	[ebp+12]				;minVal
	push	[ebp+8]					;maxVal
	call	ValidateInt
	jz		Error

	; add the appropriate sign to user_val
	; if input was negative num, restore negative state
	pop		edx
	mov		eax, [edi]
	mov		ebx, edx
	imul	ebx
	mov		[edi], eax				; done, move converted result back to user_val

	; done with str -> int conversion, int also validated
	jmp		DoneConverting

Error:
	mDisplayString [ebp+32]
	jmp		GetNumber

DoneConverting:
	; clear the stack
	mov		esp, ebp
	pop		ebp
	ret		36
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
;		[ebp+20] @user_val_sign = OFFSET sign (1/-1) of user_val
;		[ebp+16] @user_val = OFFSET of value to validate
;		[ebp+12] minVal = minimum acceptable input value
;		[ebp+8] maxVal = maximum acceptable input value
;
; returns: updates ZF accordingly
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	
	; bring in user_val_sign into edx (has to be done through stacks/args of fillArray, ReadVal, validateInt)
	; if user_val_sign = -1:
		; if (unsigned)user_val > (unsigned)minVal
			; invalid
	; elif:       --> user_val is positive
		;if (unsigned)user_val > (unsigned)maxVal
			; invalid
	; else:
		; valid

	push	esi
	mov		esi, [ebp+16]				; bring in user_val
	mov		eax, [esi]

	; bring in user_val_sign
	push	esi
	mov		esi, [ebp+20]
	mov		edx, [esi]
	pop		esi

	; determine whether user_val is negative or positive
	mov		ebx, -1
	cmp		edx, ebx
	je		Negative
	jmp		Positive

Negative:
	mov		ebx, [ebp+12]
	cmp		eax, ebx
	ja		InvalidInt
	jmp		ValidInt

Positive:
	mov		ebx, [ebp+8]
	cmp		eax, ebx
	ja		InvalidInt
	jmp		ValidInt

ValidInt:
	or		eax, 1
	jmp		ValIntDone			; valid int, clear ZF and finish

InvalidInt:
	test	eax, 0

ValIntDone:
	pop		esi
	; clear the stack frame
	pop		ebp
	ret		16
	
validateInt ENDP
;---------------------------------------
displayArray proc
;
; takes array of ARRAYSIZE nums and prints array to console, using the WriteVal
;	procedure to convert each integer into a printable string and display. 
;	displayArray utilizes macro mdisplayString to print header title, and
;	commas between items.
;
; preconditions: array_nums is ready to be printed, array_str contains a header
;	title, arguments needed for WriteVal are prepared, all items are pushed onto
;	stack
;
; postconditions: section title is printed, items of array_nums are printed with
;	comma separations
;
; receives:
;			[ebp+32]	@ comma
;			[ebp+28]	@ current_array_num
;			[ebp+24]	@ array_nums
;			[ebp+20]	ARRAYSIZE
;			[ebp+16]	@ array_str
;			[ebp+12]	@ user_output_str
;			[ebp+8]		max_len_output
;
; returns: none
;---------------------------------------
	; set up the stack
	push	ebp
	mov		ebp, esp

	; display the header
	mdisplayString [ebp+16]

	; prepare loop to go to thru array
	mov		ecx, [ebp+20]
	mov		esi, [ebp+24]

ReadArray:
	; get the array item to write
	mov		eax, [esi]
	push	edi
	mov		edi, [ebp+28]
	mov		[edi], eax
	pop		edi

	; prepare args for WriteVal
	push	[ebp+28]
	push	[ebp+12]
	push	[ebp+8]
	call	WriteVal

	; no comma after last item
	cmp		ecx, 1
	je		NextItem
	mdisplayString [ebp+32]

NextItem:
	; point to next array item
	add		esi, 4
	loop	ReadArray
		
	; clear the stack
	pop		ebp
	ret		28
displayArray ENDP
;---------------------------------------
WriteVal proc
;
; takes integer int_to_display, converts each digit in int_to_display to its
;	respective ASCII value, and stores the ASCII value in output_str. calls
;	mdisplayString to print the converted result to the console
;
; preconditions: int_to_display is an integer to be converted, output_str is a
;	string array capable of storing converted ASCII values.
;		
; postconditions: mdisplayString prints output_str to console.
;
; receives: 
;			[ebp+16] @int_to_display
;			[ebp+12] @output_str
;			[ebp+8] @len_output_str
;			[ebp-4] local var counter = counts length of @int_to_display
;
; returns: none
;---------------------------------------
	; set up stack frame
	push	ebp
	mov		ebp, esp
	sub		esp, 4

; conversion pseudocode:
; cld -> still moving from the beginning of the array
; point to the beginning of the array, output_str
; bring in int_to_display
	; @int_to_display / 10
	; remainder (edx) = lowest place value digit
	; take remainder and add 48 -> this is the ASCII value
	; push ASCII onto stack
	; increment counter
	; loop and do again
	; when eax = 0, no more divisons, int is done converting

; new loop with ecx = counter
	; pop value off stack (1st pop is 1st digit/+/-)
	; add value to location of array pointer (starting at beginning)
	; loop with counter
	
	; when loop is done, call mdisplayString [output_str]

	; store procedures from calling proc
	push	ecx
	push	esi
	push	eax
	push	edi

	; prepare items for conversion
	mov		edi, [ebp+12]
	mov		esi, [ebp+16]
	mov		eax, [esi]
	mov		DWORD PTR [ebp-4], 0
	mov		ecx, [ebp+8]
	push	eax


CLearArray:
	mov		eax, 0
	cld
	stosb
	loop	CLearArray

	; reprepare items for conversion
	pop		eax
	mov		edi, [ebp+12]

	; check the sign of the num, if negative add negative sign to array first
	mov		eax, [esi]
	cmp		eax, 0
	jge		Convert
	; otherwise, num is negative

NegativeNum:
	push	eax
	mov		eax, 45				; ASCII 45 is "-"
	cld
	stosb
	pop		eax

	; make num positive and convert
	mov		ebx, -1
	imul	ebx

Convert:
	; if eax < 10, then no division, num directly converted
	;cmp		eax, 10
	;jb		Ascii
	xor		edx, edx
	mov		ebx, 10
	div		ebx					; remainder = value to convert
Ascii:
	add		edx, 48
	push	edx
	mov		ecx, DWORD PTR [ebp-4]
	inc		ecx
	mov		DWORD PTR [ebp-4], ecx
	cmp		eax, 0
	je		PrepareOutput
	jmp		Convert

PrepareOutput:
	mov		ecx, DWORD PTR [ebp-4]
Output:
	pop		eax
	cld
	stosb
	loop	Output

	; done, now print the value
	mDisplayString [ebp+12]

	; restore calling procedure registers
	pop		edi
	pop		eax
	pop		esi
	pop		ecx
	
	; clear the stack
	mov		esp, ebp			; get rid of local var
	pop		ebp
	ret		12
WriteVal ENDP
;---------------------------------------
displayStats proc
;
; iterates over array of nums and calculates the sum and the average (rounding 
;	down) of the array. displayStats will the print the two values to the user
;	using WriteVal while also displaying headers with macro mdisplayString
;
; preconditions: variables to contain sum and average, array of values, size of 
;	array passed, string headers for the sum and average are all passed as 
;	arguments on stack
;
; postconditions: appropriate values and headers are displayed
;
; receives:
;			[ebp+36]	OFFSET user_output_str
;			[ebp+32]	max_len_output
;			[ebp+28]	OFFSET sum
;			[ebp+24]	OFFSET average
;			[ebp+20]	OFFSET array_nums
;			[ebp+16]	ARRAYSIZE
;			[ebp+12]	OFFSET sum_str
;			[ebp+8]		OFFSET average_str
;
; returns: none
;---------------------------------------
	; prepare the stack
	push	ebp
	mov		ebp, esp

	; display sum header
	mdisplayString [ebp+12]

	; prepare values for summation
	mov		esi, [ebp+20]				; array
	mov		edi, [ebp+28]				; start with sum, will also use avg
	mov		eax, 0
	mov		ebx, [ebp+16]
	mov		ecx, [ebp+16]

Calculate:
	mov		eax, [edi]
	add		eax, [esi]
	mov		[edi], eax					; update sum
	add		esi, 4
	cdq
	idiv	ebx
	push	edi
	mov		edi, [ebp+24]
	mov		[edi], eax					; update average
	pop		edi
	loop	Calculate

	; display the sum
	push	[ebp+28]
	push	[ebp+36]
	push	[ebp+32]
	call	WriteVal

	; display average header
	mdisplayString [ebp+8]

	; display the average
	push	[ebp+24]
	push	[ebp+36]
	push	[ebp+32]
	call	WriteVal

	; clear the stack
	pop		ebp
	ret		32																   
displayStats ENDP

END main
