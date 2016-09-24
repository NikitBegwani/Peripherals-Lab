//// Part 2 + the bonus

///Motor - J1 port
///ADC - J2 port

// the RPM of the motor is controlled by the DC volatge
// the number of ticks or number of 1.8 degree rotations 
// if displayed on the LED
// RPM can be noted by manually checking the time and calculating
// the rotaitions and then divind by the time noted.

// Memory locations used
// 8700 - Channel of ADC used for conversion
// 8701 - Converted Value
// 8702 - Display memory location
// 8703 - No. of ticks(Higher 8 bits)
// 8704 - No. of ticks(Lower 8 bits)

MAIN:	   
	   MVI A,00	// Channel 00 used for conversion
	   STA 8700
	   MVI A,00
	   STA 8703
	   CALL STEPPER
	   JMP MAIN

CONVERT:	   MVI A,8B	
	   OUT 43
	   LDA 8700
	   MOV B,A	
	   OUT 40	
	   MVI A,20	// Start
	   ORA B
	   OUT 40
	   MVI A,00
	   ORA B
	   OUT 40

WAIT1:	   IN 42
	   ANI 01
	   JNZ WAIT1	// Waiting for EOC to low

WAIT2:	   IN 42
	   ANI 01
	   JZ WAIT2	// Waiting for EOC to high
	   MVI A,40	// Reading converted value
	   ORA B
	   OUT 40
	   IN 41
	   STA 8701
	   RET

DISPLAY:	   PUSH PSW	//All the register values are stores 
	   PUSH B			//in stack
	   PUSH D
	   PUSH H
	   LDA 8701
	   STA 8FF1
	   CALL 044C
	   LDA 8703
	   STA 8FF0		//display - Number of ticks 
	   LDA 8704
	   STA 8FEF
	   CALL 0440
	   POP H
	   POP D
	   POP B
	   POP PSW
	   RET

STEPPER:	   MVI A,80	// configure All o/p ports
	   OUT 03
	   MVI C,88	// C- Stores the magnet configuration
	   MVI D,04	// Defines the refresh rate of the stepper 

LOOP:	   CALL CONVERT //get the value of conversion
	   CALL DISPLAY	//display the digital value
	   MOV A,C		
	   OUT 00
	   CALL DELAY	//delay 
	   RRC
	   MOV C,A
	   LDA 8703	// Updating # of ticks
	   MOV H,A
	   LDA 8704
	   MOV L,A
	   INX H
	   MOV A,L
	   STA 8704
	   MOV A,H
	   STA 8703	// End of updation
	   RET

DELAY:	   PUSH PSW
	   LXI H,4000	// Get the divident
	   LDA 8701	// Get the divisor
	   ORI 00
	   JZ NO_DIV	//special case of zero input
	   MOV C,A
	   LXI D,0000	// Quotient = 0

BACK:	   MOV A,L
	   SUB C	// Subtract divisor
	   MOV L,A	// Save partial result
	   JNC SKIP	// if CY 1 jump
	   DCR H	// Subtract borrow of previous subtraction

SKIP:	   INX D	// Increment quotient
	   MOV A,H
	   CPI 00	// Check if dividend < divisor
	   JNZ BACK	// if no repeat
	   MOV A,L
	   CMP C
	   JNC BACK	// HL stores remainder and DE stores quotient
	   XCHG
	   JMP DIV

NO_DIV:	   LXI H,7000

DIV:	   DCX H
	   MOV A,H
	   ORA L
	   JNZ DIV
	   POP PSW
	   RET
