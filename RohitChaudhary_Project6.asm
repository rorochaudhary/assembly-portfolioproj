TITLE Programming Assignment #6   (RohitChaudhary_Project6.asm)

; Author: Rohit Chaudhary
; Last Modified: 5/30/2020
; OSU email address: chaudroh@oregonstate.edu
; Course number/section: CS 271/400
; Project Number: 6               Due Date: 6/7/2020
; Description: test program demonstrating functionality of ReadVal and WriteVal
;	procedures by prompting user to input 10 integers that will be stored in 
;	an array, and then calculates sthe sum and average of the inputted vals. 
;	ReadVal procedure implements the macro getString (macro prompts and gets 
;	keyboard string input) and converts the numeric string in to the
;	corresponding integer value while validating for sign and size. WriteVal
;	procedure implements the macro displayString (macro prints string stored
;	at specific memory location) converts a numeric value into a string of
;	digits are are printed.

INCLUDE Irvine32.inc

minVal = -29438			; minimum possible 32bit value
maxVal = 239085			; max possible 32 bit value
ARRAYSIZE = 10					; size of array containing integers

; macros
mGetString MACRO
	; call mdisplayString to print the prompt to user?
ENDM

mDisplayString MACRO
ENDM

.data

title_str		BYTE		"PROGRAMMING ASSIGNMENT #6: Designing Low-Level"
				BYTE		"I/O procedures",0
author_str		BYTE		"Written By: Rohit Chaudhary",0
intro_str1		BYTE		"Pease provide 10 signed decmial integers.",0
intro_str2		BYTE		"Each number number needs to be small enough to "
				BYTE		"fit inside a 32-bit register. After you have "
				BYTE		"finished inputting the raw numbers I will display "
				BYTE		"list of the integers, their sum, and their "
				BYTE		"average value.",0
prompt_str		BYTE		"Please enter a signed number: ,0"
error_str		BYTE		"ERROR: You did not enter a signed number or your "
				BYTE		"number was too big.",0
.code
main PROC
; introduction procedure displays title, author, and user instructions (macro)

; loop to get 10 values from user
; loop calls ReadVal procedure 10 times to get vals (macro), convert str-> int
;	and validate
; after each ReadVal call, add the new integer to the array
; redo the loop to get new num if invalid string integer inputted

; loop to print the contents of the array
; loop calls WriteVal procedure each time, WriteVal converts int -> str 
;	and then prints each int (macro) in a comma separated line

; procedure calcSum will calculate the sum of array contents and will print
;	sum to user(macro)

; procedure calcAvg will calculate the avg of array contents and will print
;	avg to user(macro)

;---------------------------------------
introduction proc
;---------------------------------------

	ret
introduction ENDP
;---------------------------------------
ReadVal proc
;---------------------------------------

	ret
ReadVal ENDP
;---------------------------------------
WriteVal proc
;---------------------------------------

	ret
WriteVal ENDP
;---------------------------------------
calcSum proc
;---------------------------------------

	ret
calcSum ENDP
;---------------------------------------
calcAvg proc
;---------------------------------------

	ret
calcAvg ENDP

	exit	; exit to operating system
main ENDP



END main
