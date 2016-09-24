////Part c Rotate the dial dependong on the voltage  

// Motor is connected to J1
// ADEC to J2

//Using this the dial will rotate 1.8 degrees for 
//for 2 consecutive values of conversion

//This is done as the input value can range from 0 to 255
// and motor rotates 1.8 degree in each tick making 200 ticks for
// complete circle and hence 255 ticks are not feasible

// Memory locations used
// 8700 - Channel used for ADC conversion
// 8701 - Storage for Converted Value

MAIN:	   MVI A,8B	// Configure input-output ports
	   OUT 43
	   MVI A,00	// Channel 00
	   STA 8700
	   MVI E,00
	   CALL CONVERT	//reads the DC and store in 8701 location
	   CALL DISPLAY	//diaplay the converted value on the LED
	   CALL DIAL	//rotate the dial according to the value
	   HLT

CONVERT: LDA 8700
	   MOV B,A	
	   OUT 40	// Set the channel
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

DISPLAY: LDA 8701	
	   STA 8FF1
	   CALL 044C
	   RET

DIAL:	   MVI A,80
	   OUT 03		// Configure the port for J1 pin
	   MVI A,88
	   OUT 00
	   MOV C,A	
	   LDA 8701	
	   RRC		// Division of convereted value by two
	   CMA
	   MOV D,A
	   CMA
	   ANI 80
	   ADD D
	   CMA
	   MOV B,A
	   ORI 00
	   JZ OVER
	   MOV A,C

DIAL_LOOP:	   OUT 00
	   CALL DELAY_DIAL
	   RRC
	   DCR B
	   JNZ DIAL_LOOP

OVER:	   HLT

DELAY_DIAL:PUSH PSW
	   PUSH B
	   LXI H,0515

DELAY_DIALLOOP:	   DCX H
	   MOV A,H
	   ORA L
	   JNZ DELAY_DIALLOOP
	   POP B
	   POP PSW
	   RET
