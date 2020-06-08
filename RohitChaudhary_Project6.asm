TITLE Programming Assignment #6   (RohitChaudhary_Project6.asm)

; Author: Rohit Chaudhary
; Last Modified: 6/7/2020
; OSU email address: chaudroh@oregonstate.edu
; Course number/section: CS 271/400
; Project Number: 6               Due Date: 6/7/2020
; Description: Test program demonstrating ReadVal and WriteVal procedures. 
;	Program prompts user to input 10 integers that will be stored in 
;	an array, and then calculates the sum and average of the inputted vals. 
;	ReadVal procedure implements the macro getString (macro prompts and gets 
;	keyboard string input) and converts the numeric string in to the
;	corresponding integer value while validating for sign and size. WriteVal
;	procedure implements the macro displayString (macro prints string stored
;	at specific memory location) and converts a numeric value into a string of
;	digits that are then printed as a comma-separated list. The sum and average
;	are printed after the list in similar fashion.

INCLUDE Irvine32.inc

MINVAL = -2147483648			; min possible 32bit value
MAXVAL = 2147483647				; max possible 32bit value
ARRAYSIZE = 10					; size of array containing integers

;---------------------------------------
mDisplayString MACRO buffer:req
;
; displays contents of buffer to user by printing buffer to console.
;
; preconditions: buffer is an OFFSET to the string in memory.
;
; postconditions: buffer is printed for user
;
; receives:
;		buffer = address of string to be printed
;
; returns: none
;---------------------------------------
	; print the string
	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx
ENDM
;---------------------------------------
mGetString MACRO prompt:req, varName:req, varLen:req, input_len:req
;
; displays prompt for user via mdisplayString. Subsequently reads user input
;	with ReadString (and its required parameters, varName and varLen), storing
;	input at memory address of varName. Resulting length of user's string input
;	stored at memory location input_len.
;
; preconditions: addresses of prompt, varName, varLen, input_len are declared
;	and passed a required arguments.
;
; postconditions: prompt printed. eax contains user input length by ReadString
;
; receives:
;		prompt = OFFSET address of user prompt to be printed
;		varName = OFFSET address ReadString user input array
;		varLen = length of varLen as used by ReadString
;		input_len = OFFSET address of length of user ReadString input
;
; returns: varName and input_len updated
;---------------------------------------
	push	ecx
	push	edx
	push	edi
	
	; display prompt for user input
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
goodbye_str			BYTE		10,13,10,13,"Thanks for playing!",10,13,0


.code
main PROC
	; display title, author, and instructions
	push	OFFSET title_str
	push	OFFSET author_str
	push	OFFSET intro_str
	call	introduction
	
	; get 10 integers from user into array
	push	OFFSET user_val_sign
	push	OFFSET actual_len_input
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET error_str
	push	OFFSET prompt_str
	push	OFFSET user_input_str
	push	max_len_input
	push	OFFSET user_val
	push	MINVAL
	push	MAXVAL
	call	fillArray

	; print the 10 integers
	push	OFFSET comma
	push	OFFSET current_array_num
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET array_str
	push	OFFSET user_output_str
	push	max_len_output
	call	displayArray

	; calculate and print the sum and average of 10 ints
	push	OFFSET user_output_str
	push	max_len_output
	push	OFFSET sum
	push	OFFSET average
	push	OFFSET array_nums
	push	ARRAYSIZE
	push	OFFSET sum_str
	push	OFFSET average_str
	call	displayStats

	; say goodbye to user
	push	OFFSET goodbye_str
	call	farewell

	exit	; exit to operating system
main ENDP

;---------------------------------------
introduction proc
;
; displays program title, information, and user instructions by printing to
;	console via macro mdisplayString
;
; preconditions: strings containing title, author, and instructions are 
;	prepared.
; 
; postconditions: relevant strings are printed to console
;
; receives: 
;			[ebp+16]	@title_str
;			[ebp+12]	@author_str
;			[ebp+8]		@intro_str
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
; fills array with ARRAYSIZE amount of nums, utilizing ReadVal to retrieve user
;	input.
;
; preconditions: array of ARRAYSIZE is declared, preconditions for ReadVal are
;	met. changes registers eax, ecx, edi, edi.
; 
; postconditions: user_val is updated with most recent user inputted integer
;
; receives: 
;			[ebp+48]	@val_sign = sign of user's input value
;			[ebp+44]	@user_len_input = length of user's input in bytes
;			[ebp+40]	@array = array to hold user inputted integers
;			[ebp+36]	ARRAYSIZE = size of array
;			[ebp+32]	@error_str	= error msg to display
;			[ebp+28]	@prompt_str = string asking user to input a value
;			[ebp+24]	@user_input_str = string array to receive user input
;			[ebp+20]	max_len_input = size of user_input_str
;			[ebp+16]	@user_val = variable to be updated with converted num
;			[ebp+12]	MINVAL = minimum acceptable input value
;			[ebp+8]		MAXVAL = maximum acceptable input value
;
; returns: updated array
;---------------------------------------
	; set up the stack frame
	push		ebp
	mov		ebp, esp

	; prepare loop
	mov		edi, [ebp+40]			; array
	mov		esi, [ebp+16]			; current inputted int
	mov		ecx, [ebp+36]			; ARRAYSIZE

Fill:
	; save relevant values before ReadVal
	push	ecx
	push	edi
	push	esi

	; prepare arguments for ReadVal
	push	[ebp+48]				; OFFSET user_val_sign
	push	[ebp+44]				; OFFSET actual_len_input
	push	[ebp+32]				; OFFSET error_str
	push	[ebp+28]				; OFFSET prompt_str
	push	[ebp+24]				; OFFSET user_input_str
	push	[ebp+20]				; max_len_input
	push	[ebp+16]				; OFFSET user_val
	push	[ebp+12]				; MINVAL
	push	[ebp+8]					; MAXVAL
	call	ReadVal

	; restore values
	pop		esi
	pop		edi
	pop		ecx

	; add the new integer to array
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
; gets string integer input from user via macro mGetString. calls validation procedures
;	for sign and integer input. the converts inputted string in to numeric 
;	signed integers, validated for size (MINVAL <= input <= MAXVAL). conversion
;	of string input to integer per string processing techniques demostrated by 
;	Professor Paulson in Lecture #22.
;
; preconditions: variables for sign, input length, string array, user_val 
;	declared to implement validation and retrieving input. prompt and error
;	strings declared for prompting user to input and when input is erroneous.
;
; postconditions: changes registers eax, ebx, ecx, edx, edi, esi
;
; receives:
;			[ebp+40]	@user_val_sign = sign (1/-1) of user's input value
;			[ebp+36]	@actual_len_input = length (bytes) of user input string
;			[ebp+32]	@error_str	= error msg to display
;			[ebp+28]	@prompt_str = string asking user to input a value
;			[ebp+24]	@user_input_str = string array to receive user input
;			[ebp+20]	max_len_input = size of user_input_str
;			[ebp+16]	@user_val = variable to be updated with converted num
;			[ebp+12]	MINVAL = minimum acceptable input value
;			[ebp+8]		MAXVAL = maximum acceptable input value
;			[ebp-4]		local x = holds intermediate conversions
;			[ebp-8]		local temp = holds local ascii_val
;
; returns: user_val updated with converted signed int. user_val_sign updated
;	with sign of user input. error_str displayed if validation failed. 
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp
	sub		esp, 8					; local vars

GetNumber:
	; get user num
	mGetString	[ebp+28], [ebp+24], [ebp+20], [ebp+36]

	; convert input str -> int
	cld
	mov		edi, [ebp+36]
	mov		ecx, [edi]				; loop counter = length of user input
	mov		esi, [ebp+24]			; user input is going to be accessed
	mov		DWORD PTR [ebp-4], 0	; initialize local x
	mov		edx, 1			
	
	; get the sign of user's integer
	push	edi
	mov		edi, [ebp+40]
	mov		[edi], edx
	pop		edi
	push	edx						; determines sign of final integer

IterateInput:
	mov		eax, 0					; clear register for next num
	lodsb							

	; check to see if leading -/+ sign given
	mov		ebx, 45					; ASCII - = 45
	cmp		eax, ebx
	je		NegativeNum
	mov		ebx, 43					; ASCII + = 43
	cmp		eax, ebx
	je		NextNum
	jmp		Check					; not negative sign, move on

NegativeNum:
	; update sign to reflect negative input
	mov		edx, -1
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
	; conversion str -> int: x = 10 * x + (user_input[i] - 48)
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
	push	[ebp+40]
	push	[ebp+16]
	push	[ebp+12]
	push	[ebp+8]
	call	ValidateInt
	jz		Error

	; restore approriate sign of integer
	pop		edx
	mov		eax, [edi]
	mov		ebx, edx
	imul	ebx
	mov		[edi], eax

	; conversion and validation complete
	jmp		DoneConverting

Error:
	mDisplayString [ebp+32]
	jmp		GetNumber					; get a new num from user

DoneConverting:
	; clear the stack
	mov		esp, ebp
	pop		ebp
	ret		36
ReadVal ENDP
;---------------------------------------
validateASCII proc
;
; Takes ascii value and determines whether value is a digit, meaning between
;	ASCII values 48 - 57. sets ZF if not a digit, clears ZF it is a digit.
;
; preconditions: decimal ASCII value to validate is a parameter
;
; postconditions: uses registers eax, ebx
;
; receives:
;			[ebp+8]		ascii_val = value to validate
;
; returns: updates ZF accordingly (0 = valid, 1 = invalid)
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; if 48 <= ascii_val <= 57, valid
	mov		eax, [ebp+8]
	mov		ebx, 48
	cmp		eax, ebx
	jl		InvalidASCII
	mov		ebx, 57
	cmp		eax, ebx
	jg		InvalidASCII
	or		eax, 1					; valid, clear flag
	jmp		Done

InvalidASCII:
	test	eax, 0					; invalid, set flag

Done:
	; clear the stack frame
	pop		ebp
	ret		4
	
validateASCII ENDP
;---------------------------------------
validateInt proc
;
; takes signed integer value and determines whether value is valid, meaning
;	MINVAL <= int_val <= MAXVAL. Sets ZF if invalid, clears ZF if valid.
;
; preconditions: sign of value, value to test, MINVAL, MAXVAL are passed as
;	arguments.
;
; postconditions: uses registers eax, ebx, edx, esi
;
; receives:
;			[ebp+20]	@user_val_sign = OFFSET sign (1/-1) of user_val
;			[ebp+16]	@int_to_validate = OFFSET of value to validate
;			[ebp+12]	MINVAL = minimum acceptable input value
;			[ebp+8]		MAXVAL = maximum acceptable input value
;
; returns: updates ZF accordingly (0 = valid, 1 = invalid)
;---------------------------------------
	; set up the stack frame
	push	ebp
	mov		ebp, esp

	; get value to validate
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
	or		eax, 1				; valid int, clear ZF
	jmp		ValIntDone

InvalidInt:
	test	eax, 0				; invalid int, set ZF

ValIntDone:
	pop		esi
	; clear the stack frame
	pop		ebp
	ret		16
	
validateInt ENDP
;---------------------------------------
displayArray proc
;
; takes array of ARRAYSIZE nums and prints array to console via WriteVal.
;	Converts each integer into a string before printing value via macro
;	mdisplayString. Also prints header title and commas via mdisplayString.
;
; preconditions: array contains ARRAYSIZE printable integers, header string and
;	commas available to print, arguments needed for WriteVal, string array to 
;	contain output string, are all arguments
;
; postconditions: uses registers eax, ecx, edi, esi
;
; receives:
;			[ebp+32]	@comma = for displaying comma separate items
;			[ebp+28]	@current_array_num = contains single int of current int
;			[ebp+24]	@array = array of integer to print
;			[ebp+20]	ARRAYSIZE = size of array
;			[ebp+16]	@array_str = header
;			[ebp+12]	@user_output_str = contains string form of int
;			[ebp+8]		max_len_output = size of @user_output_str
;
; returns: prints array section header, prints comma-separated items of array
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
	; get the array int to write
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
; Converts int_to_display to string of it's respective ASCII values which is 
;	stored in output_str. prints string form of integer in output_str via 
;	mdisplayString.
;
; preconditions: int_to_display is signed integer, and output_str is a
;	string array of appropriate length passed as arguments.
;		
; postconditions: uses registers eax, ebx, ecx, edx, edi, esi
;
; receives: 
;			[ebp+16]	@int_to_display = signed int to be converted/printed
;			[ebp+12]	@output_str = string array conaining converted int string
;			[ebp+8]		@len_output_str = length of output_str
;			[ebp-4]		local counter = contains length of int_to_display
;
; returns: output_str printed and contains string representation of integer
;---------------------------------------
	; set up stack frame
	push	ebp
	mov		ebp, esp
	sub		esp, 4

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

ClearArray:
	mov		eax, 0
	cld
	stosb							; zeroes out string array
	loop	ClearArray

	; re-prepare items for conversion
	pop		eax
	mov		edi, [ebp+12]

	; check sign of the num, need a leading "-"
	mov		eax, [esi]
	cmp		eax, 0
	jge		Convert					; num is positive

NegativeNum:
	push	eax
	mov		eax, 45					; ASCII 45 = "-"
	cld
	stosb
	pop		eax

	; make num positive, convert digits only
	mov		ebx, -1
	imul	ebx

Convert:
	xor		edx, edx
	mov		ebx, 10
	div		ebx						; remainder in edx = value to convert

Ascii:
	add		edx, 48
	push	edx
	mov		ecx, DWORD PTR [ebp-4]
	inc		ecx
	mov		DWORD PTR [ebp-4], ecx
	cmp		eax, 0
	je		PrepareOutput			; when repeated divisions = 0, print num
	jmp		Convert					; still digits left to convert

PrepareOutput:
	mov		ecx, DWORD PTR [ebp-4]

Output:
	pop		eax
	cld
	stosb
	loop	Output

	; num is ready to print
	mDisplayString [ebp+12]

	; restore calling procedure registers
	pop		edi
	pop		eax
	pop		esi
	pop		ecx
	
	; clear the stack
	mov		esp, ebp				; local var counter
	pop		ebp
	ret		12
WriteVal ENDP
;---------------------------------------
displayStats proc
;
; iterates over array of signed integers, calculating total sum and average
;	(average rounded down) of the array. headers are printed via mdisplayString
;	and resulting values are printed via WriteVal.
;
; preconditions: array of ARRAYSIZE signed integers, variables for sum and 
;	average, appropriate header strings, are passed as arguments. arguments for
;	WriteVal also passed as arguments.
;
; postconditions: uses registers eax, ebx, ecx, edx, edi, esi
;
; receives:
;			[ebp+36]	@user_output_str = string array for value to be printed
;			[ebp+32]	max_len_output = length of @user_output_str
;			[ebp+28]	@sum = variable containing sum of array
;			[ebp+24]	@average = variable containing average of array
;			[ebp+20]	@array = array from which sum and average are calculated
;			[ebp+16]	ARRAYSIZE = size of @array
;			[ebp+12]	@sum_str = header for sum
;			[ebp+8]		@average_str = header for average
;
; returns: headers for sum and average are printed. sum and average values
;	of array are calculated and appropriate variables updated. sum and average
;	values are printed.
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
;---------------------------------------
farewell proc
;
; displays goodbye message to user via macro mdisplayString.
;
; preconditions: goodbye string declared and passed as argument.
;
; postconditions: postconditions of mdisplayString apply.
;
; receives:
;			[ebp+8] @goodbye_str
;
; returns: string is printed to user
;---------------------------------------
	; set up the stack
	push	ebp
	mov		ebp, esp

	; display the string
	mdisplayString [ebp+8]

	; clear the stack
	pop		ebp
	ret
farewell ENDP
END main
