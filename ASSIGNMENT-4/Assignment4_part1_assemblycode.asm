//Part a. Get the digital value from the ADC and display on the MPS 85-3 board

//Memory locations used 
// 8700 - store the channel used for ADC conversion 
// 8701 - Store the converted value from the ADC
 

MAIN:	MVI A,8B		
	OUT 43				//Intial configuration of the input output ports
	MVI A,00			//Channel 00 of ADC used for conversion
	STA 8700
	MVI E,00
	CALL CONVERT			//Convert function reads the DC value and 
					//store the converted value in 8701 location
	CALL DISPLAY			//Display the value of location 8701 on the LED
	JMP MAIN			

CONVERT:	LDA 8700
	MOV B,A				
	OUT 40 				//Set the channel
	MVI A,20			//Start conversion 
	ORA B
	OUT 40
	NOP
	NOP
	MVI A,00	
	ORA B
	OUT 40
WAIT1:	IN 42
	ANI 01
	JNZ WAIT1			//Waiting for EOC to low
WAIT2:	IN 42
	ANI 01
	JZ WAIT2			//Waiting for EOC to high
	MVI A,40			//Reading converted value
	ORA B
	OUT 40
	NOP
	IN 41
	STA 8701
	RET

DISPLAY:LDA 8701			//Display the converted value on the LED
	STA 8FF1
	CALL 044C
	RET