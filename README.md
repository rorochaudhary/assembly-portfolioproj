# Computer Architecture and Assembly Language Portfolio Project
<br>Course: Computer Architecture and Assembly Language
<br>Language: MASM x86 Assembly
<br>Tools: Microsoft Visual Studio

## Introduction
This is the final project for my Computer Architecture and Assembly Language class. Written in x86 MASM via Visual Studio 2019, the program demonstrates knowledge of low-level programming in order to implement low-level I/O procedures and Macros. The course utilized procedures and knowledge from the Irvine32 library as detailed in "Assembly Language for x86 Processors" by Kip Irvine. 

## Description
The Irvine32 library provided the ReadString and WriteString procedures in order to retrieve and print information in order to focus on other topics presented while learning. This project demonstrates retrieving and displaying information by implementing the ReadVal and WriteVal procedures in order to get user numeric input in the form of a string, convert that string into an integer, perform basic calculations, and convert integers back into a printable string.

The program first gets 10 integers from the user, validates integers and stores them in an array, then displays the 10 integers along with their sum and average. Validation checks for fit of signed values within a 32-bit register and non-digit entries (aside from the allowed + and - leading signs), showing an error before asking for a new input. 

Retrieval and display of integers and strings are performed with two macros, mGetString and mDisplayString, to manage getting user string input and displaying output to user. Both macros implement the Irvine32 library provided ReadString and WriteString.

ReadVal and WriteVal conversions between str <-> int are performed by a simple algorithm implementation to take integer values and convert into an array of ASCII values, or vice versa. Use of stosb and lodsb allows for quick string manipulation. Accompanying prompts, necessary variables and arrays, registers, and any other data required to implement procedures are done through the system stack as arguments.

The test program utilized procedures FillArray, displayArray, displayStats in order to get the 10 values from user, place them in an array, calculate sum/average, and display the array and sum/average. Through these procedures ReadVal, WriteVal, and the two macros are demonstrated.

## Instructions
All files necessary to run the project on Microsoft Visual Studio are included in this repository.

### Loading the Project into Visual Studio (if already loaded, skip to next section).
1) Double-click and execute Project.sln file with Visual Studio.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step1.jpg)
2) If RohitChaudhary_Project6.asm is not alread loaded into the Solution Explorer, do so by right-clicking "Project" in the Solution Explorer -> Add -> Existing Item.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step2.jpg)
3) Navigate to the folder containing the Project and find the file titled "RohitChaudhary_Project6.asm". Click on the file and then click Add. The file should now be the only file shown belonging to Project. Double-click on the file to show code in Visual Studio.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step3.jpg)
### Running the Program
1) To Run the project, click on Debug -> Start Without Debugging or press Ctrl + F5.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step4.jpg)
2) Program will execute in another window, displaying relevant info and prompting you to input a signed number.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step5.jpg)
3) Continue to input signed numbers. Invalid ones prompt an error message and you try again.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step6.jpg)
4) Once 10 valid signed numbers are accepted, the program will display your entered values along with the sum and average.
![Screenshot](https://github.com/rorochaudhary/assembly-portfolioproj/blob/master/Screenshots/screenshot_step7.jpg)
5) The program is complete, press any key to exit.
