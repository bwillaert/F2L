
_interrupt:
	CLRF       PCLATH+0
	CLRF       STATUS+0

;F2L.c,84 :: 		void interrupt(void)
;F2L.c,87 :: 		if (PIR2.C1IF)
	BTFSS      PIR2+0, 5
	GOTO       L_interrupt0
;F2L.c,89 :: 		pulse_count++;
	INCF       F2L_pulse_count+0, 1
	BTFSC      STATUS+0, 2
	INCF       F2L_pulse_count+1, 1
;F2L.c,91 :: 		PIR2.C1IF = 0;
	BCF        PIR2+0, 5
;F2L.c,92 :: 		}
L_interrupt0:
;F2L.c,93 :: 		}
L_end_interrupt:
L__interrupt41:
	RETFIE     %s
; end of _interrupt

_absvalue:

;F2L.c,96 :: 		unsigned int absvalue(unsigned int a, unsigned int b)
;F2L.c,98 :: 		if (a > b)
	MOVF       FARG_absvalue_a+1, 0
	SUBWF      FARG_absvalue_b+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__absvalue43
	MOVF       FARG_absvalue_a+0, 0
	SUBWF      FARG_absvalue_b+0, 0
L__absvalue43:
	BTFSC      STATUS+0, 0
	GOTO       L_absvalue1
;F2L.c,100 :: 		return (a-b);
	MOVF       FARG_absvalue_b+0, 0
	SUBWF      FARG_absvalue_a+0, 0
	MOVWF      R0
	MOVF       FARG_absvalue_b+1, 0
	SUBWFB     FARG_absvalue_a+1, 0
	MOVWF      R1
	GOTO       L_end_absvalue
;F2L.c,101 :: 		}
L_absvalue1:
;F2L.c,104 :: 		return (b-a);
	MOVF       FARG_absvalue_a+0, 0
	SUBWF      FARG_absvalue_b+0, 0
	MOVWF      R0
	MOVF       FARG_absvalue_a+1, 0
	SUBWFB     FARG_absvalue_b+1, 0
	MOVWF      R1
;F2L.c,107 :: 		}
L_end_absvalue:
	RETURN
; end of _absvalue

_sendchar:

;F2L.c,113 :: 		void sendchar( char c)
;F2L.c,116 :: 		while (!UART1_Tx_Idle())
L_sendchar3:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_sendchar4
;F2L.c,118 :: 		Delay_us(100);
	MOVLW      2
	MOVWF      R12
	MOVLW      8
	MOVWF      R13
L_sendchar5:
	DECFSZ     R13, 1
	GOTO       L_sendchar5
	DECFSZ     R12, 1
	GOTO       L_sendchar5
	NOP
;F2L.c,119 :: 		}
	GOTO       L_sendchar3
L_sendchar4:
;F2L.c,120 :: 		UART1_Write(c);
	MOVF       FARG_sendchar_c+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;F2L.c,123 :: 		}
L_end_sendchar:
	RETURN
; end of _sendchar

_sendhex:

;F2L.c,128 :: 		void sendhex (unsigned long hexnumber, unsigned char cr )
;F2L.c,131 :: 		int nibble = 0;
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
;F2L.c,134 :: 		for (nibble = 0; nibble < 6; nibble++)
	CLRF       sendhex_nibble_L0+0
	CLRF       sendhex_nibble_L0+1
L_sendhex6:
	MOVLW      128
	XORWF      sendhex_nibble_L0+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sendhex46
	MOVLW      6
	SUBWF      sendhex_nibble_L0+0, 0
L__sendhex46:
	BTFSC      STATUS+0, 0
	GOTO       L_sendhex7
;F2L.c,136 :: 		sendchar(hexnr[(hexnumber&0xF00000)>>20]);
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+0, 0
	MOVWF      R5
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+1, 0
	MOVWF      R6
	MOVLW      240
	ANDWF      FARG_sendhex_hexnumber+2, 0
	MOVWF      R7
	MOVLW      0
	ANDWF      FARG_sendhex_hexnumber+3, 0
	MOVWF      R8
	MOVLW      20
	MOVWF      R4
	MOVF       R5, 0
	MOVWF      R0
	MOVF       R6, 0
	MOVWF      R1
	MOVF       R7, 0
	MOVWF      R2
	MOVF       R8, 0
	MOVWF      R3
	MOVF       R4, 0
L__sendhex47:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex48
	LSRF       R3, 1
	RRF        R2, 1
	RRF        R1, 1
	RRF        R0, 1
	ADDLW      255
	GOTO       L__sendhex47
L__sendhex48:
	MOVLW      sendhex_hexnr_L0+0
	ADDWF      R0, 0
	MOVWF      FSR0L
	MOVLW      hi_addr(sendhex_hexnr_L0+0)
	ADDWFC     R1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,137 :: 		hexnumber<<=4;
	MOVLW      4
	MOVWF      R0
	MOVF       R0, 0
L__sendhex49:
	BTFSC      STATUS+0, 2
	GOTO       L__sendhex50
	LSLF       FARG_sendhex_hexnumber+0, 1
	RLF        FARG_sendhex_hexnumber+1, 1
	RLF        FARG_sendhex_hexnumber+2, 1
	RLF        FARG_sendhex_hexnumber+3, 1
	ADDLW      255
	GOTO       L__sendhex49
L__sendhex50:
;F2L.c,134 :: 		for (nibble = 0; nibble < 6; nibble++)
	INCF       sendhex_nibble_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       sendhex_nibble_L0+1, 1
;F2L.c,138 :: 		}
	GOTO       L_sendhex6
L_sendhex7:
;F2L.c,139 :: 		if (cr == LINE_CR_LF )
	MOVF       FARG_sendhex_cr+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_sendhex9
;F2L.c,141 :: 		sendchar('\r');
	MOVLW      13
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,142 :: 		sendchar('\n');
	MOVLW      10
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,143 :: 		}
	GOTO       L_sendhex10
L_sendhex9:
;F2L.c,144 :: 		else if (cr == LINE_CR)
	MOVF       FARG_sendhex_cr+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_sendhex11
;F2L.c,146 :: 		sendchar('\r');
	MOVLW      13
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,147 :: 		}
L_sendhex11:
L_sendhex10:
;F2L.c,150 :: 		}
L_end_sendhex:
	RETURN
; end of _sendhex

_sendstring:

;F2L.c,154 :: 		void sendstring (char* string, unsigned char cr)
;F2L.c,157 :: 		int i = 0;
	CLRF       sendstring_i_L0+0
	CLRF       sendstring_i_L0+1
;F2L.c,159 :: 		while (c=string[i++])
L_sendstring12:
	MOVF       sendstring_i_L0+0, 0
	MOVWF      R0
	MOVF       sendstring_i_L0+1, 0
	MOVWF      R1
	INCF       sendstring_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       sendstring_i_L0+1, 1
	MOVF       R0, 0
	ADDWF      FARG_sendstring_string+0, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     FARG_sendstring_string+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      R0
	MOVF       R0, 0
	MOVWF      sendstring_c_L0+0
	MOVF       R0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_sendstring13
;F2L.c,161 :: 		sendchar(c);
	MOVF       sendstring_c_L0+0, 0
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,162 :: 		}
	GOTO       L_sendstring12
L_sendstring13:
;F2L.c,165 :: 		if (cr == LINE_CR_LF )
	MOVF       FARG_sendstring_cr+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_sendstring14
;F2L.c,167 :: 		sendchar('\r');
	MOVLW      13
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,168 :: 		sendchar('\n');
	MOVLW      10
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,169 :: 		}
	GOTO       L_sendstring15
L_sendstring14:
;F2L.c,170 :: 		else if (cr == LINE_CR)
	MOVF       FARG_sendstring_cr+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_sendstring16
;F2L.c,172 :: 		sendchar('\r');
	MOVLW      13
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,173 :: 		}
L_sendstring16:
L_sendstring15:
;F2L.c,175 :: 		}
L_end_sendstring:
	RETURN
; end of _sendstring

_main:

;F2L.c,182 :: 		void main()
;F2L.c,186 :: 		OSCCON= 0xF0;
	MOVLW      240
	MOVWF      OSCCON+0
;F2L.c,190 :: 		TRISA.TRISA0 = IN;  // PIN 13 = AN0  = potmeter1
	BSF        TRISA+0, 0
;F2L.c,191 :: 		PORTA.RA0 = 1;
	BSF        PORTA+0, 0
;F2L.c,192 :: 		TRISA.TRISA1 = IN;  // PIN 12 = AN1  = potmeter2
	BSF        TRISA+0, 1
;F2L.c,193 :: 		PORTA.RA1 = 1;
	BSF        PORTA+0, 1
;F2L.c,194 :: 		TRISA.TRISA2 = OUT /*IN*/;  // PIN 11 = AN2  = potmeter3 = COMP1 OUT    xxxxxxxxxxx
	BCF        TRISA+0, 2
;F2L.c,195 :: 		PORTA.RA2 = 1;
	BSF        PORTA+0, 2
;F2L.c,196 :: 		TRISA.TRISA3 = IN;  // PIN 4 = MODE switch
	BSF        TRISA+0, 3
;F2L.c,197 :: 		PORTA.RA2 = 1;
	BSF        PORTA+0, 2
;F2L.c,198 :: 		TRISA.TRISA4 = OUT; // PIN 3 = LED2
	BCF        TRISA+0, 4
;F2L.c,199 :: 		PORTA.RA4 = 1;
	BSF        PORTA+0, 4
;F2L.c,200 :: 		TRISA.TRISA5 = OUT; // PIN 2 = LED1
	BCF        TRISA+0, 5
;F2L.c,201 :: 		PORTA.RA5 = 1;
	BSF        PORTA+0, 5
;F2L.c,204 :: 		TRISC.TRISC0 = IN;  // PIN 10 = AN4 = potmeter4
	BSF        TRISC+0, 0
;F2L.c,205 :: 		PORTC.RC0 = 1;
	BSF        PORTC+0, 0
;F2L.c,206 :: 		TRISC.TRISC1 = IN;  // PIN 9 = audio in = C12IN1-
	BSF        TRISC+0, 1
;F2L.c,207 :: 		PORTC.RC1 = 1;
	BSF        PORTC+0, 1
;F2L.c,208 :: 		TRISC.TRISC2 = IN;  // PIN 8 = NA = C12IN2-
	BSF        TRISC+0, 2
;F2L.c,209 :: 		PORTC.RC2 = 1;
	BSF        PORTC+0, 2
;F2L.c,210 :: 		TRISC.TRISC3 = OUT; // PIN 7 = NA
	BCF        TRISC+0, 3
;F2L.c,211 :: 		PORTC.RC3 = 1;
	BSF        PORTC+0, 3
;F2L.c,212 :: 		TRISC.TRISC4 = OUT; // PIN 6 = LED4
	BCF        TRISC+0, 4
;F2L.c,213 :: 		PORTC.RC4 = 1;
	BSF        PORTC+0, 4
;F2L.c,214 :: 		TRISC.TRISC5 = OUT; // PIN 5 = LED3
	BCF        TRISC+0, 5
;F2L.c,215 :: 		PORTC.RC5 = 1;
	BSF        PORTC+0, 5
;F2L.c,218 :: 		ANSELA.ANSA0 = 1;     // potmeter1
	BSF        ANSELA+0, 0
;F2L.c,219 :: 		ANSELA.ANSA1 = 1;     // potmeter2
	BSF        ANSELA+0, 1
;F2L.c,221 :: 		ANSELC.ANSC0 = 1;     // potmeter4
	BSF        ANSELC+0, 0
;F2L.c,222 :: 		ANSELC.ANSC1 = 1;     //  RC1 = C12IN1-
	BSF        ANSELC+0, 1
;F2L.c,225 :: 		CM1CON0.C1POL = 0;             // comp output polarity is not inverted
	BCF        CM1CON0+0, 4
;F2L.c,226 :: 		CM1CON0.C1OE = 0;              // comp output disabled   xxxxxxxxxx
	BCF        CM1CON0+0, 5
;F2L.c,227 :: 		CM1CON0.C1SP = 1;              // high speed
	BSF        CM1CON0+0, 2
;F2L.c,228 :: 		CM1CON0.C1ON = 1;              // comp is enabled
	BSF        CM1CON0+0, 7
;F2L.c,229 :: 		CM1CON0.C1HYS = 1;             // hysteresis enabled
	BSF        CM1CON0+0, 1
;F2L.c,230 :: 		CM1CON0.C1SYNC = 0;            // comp output synchronous with timer 1
	BCF        CM1CON0+0, 0
;F2L.c,231 :: 		CM1CON1.C1NCH0 = 1;            // C1IN1-
	BSF        CM1CON1+0, 0
;F2L.c,232 :: 		CM1CON1.C1NCH1 = 0;            // C1IN1-
	BCF        CM1CON1+0, 1
;F2L.c,233 :: 		CM1CON1.C1PCH0 = 1;            // DAC reference
	BSF        CM1CON1+0, 4
;F2L.c,234 :: 		CM1CON1.C1PCH1 = 0;            // DAC reference
	BCF        CM1CON1+0, 5
;F2L.c,237 :: 		DACCON0.DACEN = 1;             // DAC enable
	BSF        DACCON0+0, 7
;F2L.c,238 :: 		DACCON0.DACLPS = 0;            // Negative reference
	BCF        DACCON0+0, 6
;F2L.c,239 :: 		DACCON0.DACOE = 0;             // DAC output enable
	BCF        DACCON0+0, 5
;F2L.c,240 :: 		DACCON0.DACPSS0 = 0;           // VDD
	BCF        DACCON0+0, 2
;F2L.c,241 :: 		DACCON0.DACPSS1 = 0;           // VDD
	BCF        DACCON0+0, 3
;F2L.c,242 :: 		DACCON0.DACNSS = 0;            // GND
	BCF        DACCON0+0, 0
;F2L.c,243 :: 		DACCON1 = 16;                  // 5V / 32 * 16 = 2.5V
	MOVLW      16
	MOVWF      DACCON1+0
;F2L.c,246 :: 		ADCON0.ADON = 1;            //  ADC on
	BSF        ADCON0+0, 0
;F2L.c,247 :: 		ADCON1.ADFM = 1;            // right justified
	BSF        ADCON1+0, 7
;F2L.c,248 :: 		ADCON1.ADCS0 = 0;           // Fosc / 64
	BCF        ADCON1+0, 4
;F2L.c,249 :: 		ADCON1.ADCS1 = 1;           // Fosc / 64
	BSF        ADCON1+0, 5
;F2L.c,250 :: 		ADCON1.ADCS2 = 1;           // Fosc / 64
	BSF        ADCON1+0, 6
;F2L.c,251 :: 		ADCON1.ADNREF = 0;          // Vref- = VSS
	BCF        ADCON1+0, 2
;F2L.c,252 :: 		ADCON1.ADPREF0 = 0;         // Vref+ = VDD
	BCF        ADCON1+0, 0
;F2L.c,253 :: 		ADCON1.ADPREF1 = 0;         // Vref+ = VDD
	BCF        ADCON1+0, 1
;F2L.c,258 :: 		CM1CON1.C1INTP = 1; // rising edge
	BSF        CM1CON1+0, 7
;F2L.c,259 :: 		CM1CON1.C1INTN = 0; // falling edge
	BCF        CM1CON1+0, 6
;F2L.c,260 :: 		PIE2.C1IE = 0; // comparator interrupt
	BCF        PIE2+0, 5
;F2L.c,262 :: 		INTCON.PEIE = 1;
	BSF        INTCON+0, 6
;F2L.c,263 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;F2L.c,267 :: 		APFCON0.RXDTSEL = 0;         // RX = pin 5 RC5
	BCF        APFCON0+0, 7
;F2L.c,269 :: 		APFCON0.TXCKSEL = 0;        // pin 6 = RC4
	BCF        APFCON0+0, 2
;F2L.c,272 :: 		UART1_Init(9600);
	BSF        BAUDCON+0, 3
	MOVLW      64
	MOVWF      SPBRG+0
	MOVLW      3
	MOVWF      SPBRG+1
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;F2L.c,278 :: 		LED1 = ON;
	BSF        LATA+0, 5
;F2L.c,279 :: 		LED2 = ON;
	BSF        LATA+0, 4
;F2L.c,280 :: 		LED3 = ON;
	BSF        LATC+0, 5
;F2L.c,281 :: 		LED4 = ON;
	BSF        LATC+0, 4
;F2L.c,282 :: 		Delay_ms(500);
	MOVLW      21
	MOVWF      R11
	MOVLW      75
	MOVWF      R12
	MOVLW      190
	MOVWF      R13
L_main17:
	DECFSZ     R13, 1
	GOTO       L_main17
	DECFSZ     R12, 1
	GOTO       L_main17
	DECFSZ     R11, 1
	GOTO       L_main17
	NOP
;F2L.c,283 :: 		LED1 = OFF;
	BCF        LATA+0, 5
;F2L.c,284 :: 		LED2 = OFF;
	BCF        LATA+0, 4
;F2L.c,285 :: 		LED3 = OFF;
	BCF        LATC+0, 5
;F2L.c,286 :: 		LED4 = OFF;
	BCF        LATC+0, 4
;F2L.c,291 :: 		sendstring(STR_WELCOME, LINE_CR_LF);
	MOVLW      _STR_WELCOME+0
	MOVWF      FARG_sendstring_string+0
	MOVLW      hi_addr(_STR_WELCOME+0)
	MOVWF      FARG_sendstring_string+1
	MOVLW      2
	MOVWF      FARG_sendstring_cr+0
	CALL       _sendstring+0
;F2L.c,298 :: 		while(1)
L_main18:
;F2L.c,301 :: 		pulse_count = 0;
	CLRF       F2L_pulse_count+0
	CLRF       F2L_pulse_count+1
;F2L.c,304 :: 		PIE2.C1IE = 1;
	BSF        PIE2+0, 5
;F2L.c,305 :: 		Delay_ms(SAMPLE_TIME_MS);
	MOVLW      6
	MOVWF      R11
	MOVLW      50
	MOVWF      R12
	MOVLW      217
	MOVWF      R13
L_main20:
	DECFSZ     R13, 1
	GOTO       L_main20
	DECFSZ     R12, 1
	GOTO       L_main20
	DECFSZ     R11, 1
	GOTO       L_main20
;F2L.c,306 :: 		PIE2.C1IE = 0;
	BCF        PIE2+0, 5
;F2L.c,309 :: 		if (pulse_count > 1024)
	MOVF       F2L_pulse_count+1, 0
	SUBLW      4
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	MOVF       F2L_pulse_count+0, 0
	SUBLW      0
L__main53:
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;F2L.c,311 :: 		pulse_count = 1024;
	MOVLW      0
	MOVWF      F2L_pulse_count+0
	MOVLW      4
	MOVWF      F2L_pulse_count+1
;F2L.c,312 :: 		}
L_main21:
;F2L.c,315 :: 		potmeter1 = ADC_Read(0);
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0, 0
	MOVWF      F2L_potmeter1+0
	MOVF       R1, 0
	MOVWF      F2L_potmeter1+1
;F2L.c,316 :: 		potmeter2 = ADC_Read(1);
	MOVLW      1
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0, 0
	MOVWF      F2L_potmeter2+0
	MOVF       R1, 0
	MOVWF      F2L_potmeter2+1
;F2L.c,318 :: 		potmeter4 = ADC_Read(4);
	MOVLW      4
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0, 0
	MOVWF      F2L_potmeter4+0
	MOVF       R1, 0
	MOVWF      F2L_potmeter4+1
;F2L.c,320 :: 		sendhex (potmeter1, LINE_NONE);
	MOVF       F2L_potmeter1+0, 0
	MOVWF      FARG_sendhex_hexnumber+0
	MOVF       F2L_potmeter1+1, 0
	MOVWF      FARG_sendhex_hexnumber+1
	CLRF       FARG_sendhex_hexnumber+2
	CLRF       FARG_sendhex_hexnumber+3
	CLRF       FARG_sendhex_cr+0
	CALL       _sendhex+0
;F2L.c,321 :: 		sendchar(',');
	MOVLW      44
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,322 :: 		sendchar(' ');
	MOVLW      32
	MOVWF      FARG_sendchar_c+0
	CALL       _sendchar+0
;F2L.c,323 :: 		sendhex (pulse_count, LINE_CR_LF);
	MOVF       F2L_pulse_count+0, 0
	MOVWF      FARG_sendhex_hexnumber+0
	MOVF       F2L_pulse_count+1, 0
	MOVWF      FARG_sendhex_hexnumber+1
	CLRF       FARG_sendhex_hexnumber+2
	CLRF       FARG_sendhex_hexnumber+3
	MOVLW      2
	MOVWF      FARG_sendhex_cr+0
	CALL       _sendhex+0
;F2L.c,325 :: 		if (MODE_EQUAL)
	BTFSS      PORTA+0, 3
	GOTO       L_main22
;F2L.c,327 :: 		if ( absvalue(pulse_count, potmeter1) < SAMPLE_TOLERANCE)
	MOVF       F2L_pulse_count+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       F2L_pulse_count+1, 0
	MOVWF      FARG_absvalue_a+1
	MOVF       F2L_potmeter1+0, 0
	MOVWF      FARG_absvalue_b+0
	MOVF       F2L_potmeter1+1, 0
	MOVWF      FARG_absvalue_b+1
	CALL       _absvalue+0
	MOVLW      0
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main54
	MOVLW      20
	SUBWF      R0, 0
L__main54:
	BTFSC      STATUS+0, 0
	GOTO       L_main23
;F2L.c,329 :: 		LED1 = ON;
	BSF        LATA+0, 5
;F2L.c,330 :: 		}
	GOTO       L_main24
L_main23:
;F2L.c,333 :: 		LED1 = OFF;
	BCF        LATA+0, 5
;F2L.c,334 :: 		}
L_main24:
;F2L.c,335 :: 		if ( absvalue(pulse_count, potmeter2) < SAMPLE_TOLERANCE)
	MOVF       F2L_pulse_count+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       F2L_pulse_count+1, 0
	MOVWF      FARG_absvalue_a+1
	MOVF       F2L_potmeter2+0, 0
	MOVWF      FARG_absvalue_b+0
	MOVF       F2L_potmeter2+1, 0
	MOVWF      FARG_absvalue_b+1
	CALL       _absvalue+0
	MOVLW      0
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main55
	MOVLW      20
	SUBWF      R0, 0
L__main55:
	BTFSC      STATUS+0, 0
	GOTO       L_main25
;F2L.c,337 :: 		LED2 = ON;
	BSF        LATA+0, 4
;F2L.c,338 :: 		}
	GOTO       L_main26
L_main25:
;F2L.c,341 :: 		LED2 = OFF;
	BCF        LATA+0, 4
;F2L.c,342 :: 		}
L_main26:
;F2L.c,343 :: 		if ( absvalue(pulse_count, potmeter3) < SAMPLE_TOLERANCE)
	MOVF       F2L_pulse_count+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       F2L_pulse_count+1, 0
	MOVWF      FARG_absvalue_a+1
	MOVF       F2L_potmeter3+0, 0
	MOVWF      FARG_absvalue_b+0
	MOVF       F2L_potmeter3+1, 0
	MOVWF      FARG_absvalue_b+1
	CALL       _absvalue+0
	MOVLW      0
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main56
	MOVLW      20
	SUBWF      R0, 0
L__main56:
	BTFSC      STATUS+0, 0
	GOTO       L_main27
;F2L.c,345 :: 		LED3 = ON;
	BSF        LATC+0, 5
;F2L.c,346 :: 		}
	GOTO       L_main28
L_main27:
;F2L.c,349 :: 		LED3 = OFF;
	BCF        LATC+0, 5
;F2L.c,350 :: 		}
L_main28:
;F2L.c,351 :: 		if ( absvalue(pulse_count, potmeter4) < SAMPLE_TOLERANCE)
	MOVF       F2L_pulse_count+0, 0
	MOVWF      FARG_absvalue_a+0
	MOVF       F2L_pulse_count+1, 0
	MOVWF      FARG_absvalue_a+1
	MOVF       F2L_potmeter4+0, 0
	MOVWF      FARG_absvalue_b+0
	MOVF       F2L_potmeter4+1, 0
	MOVWF      FARG_absvalue_b+1
	CALL       _absvalue+0
	MOVLW      0
	SUBWF      R1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main57
	MOVLW      20
	SUBWF      R0, 0
L__main57:
	BTFSC      STATUS+0, 0
	GOTO       L_main29
;F2L.c,353 :: 		LED4 = ON;
	BSF        LATC+0, 4
;F2L.c,354 :: 		}
	GOTO       L_main30
L_main29:
;F2L.c,357 :: 		LED4 = OFF;
	BCF        LATC+0, 4
;F2L.c,358 :: 		}
L_main30:
;F2L.c,359 :: 		}
	GOTO       L_main31
L_main22:
;F2L.c,362 :: 		if ( pulse_count > potmeter1 )
	MOVF       F2L_pulse_count+1, 0
	SUBWF      F2L_potmeter1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main58
	MOVF       F2L_pulse_count+0, 0
	SUBWF      F2L_potmeter1+0, 0
L__main58:
	BTFSC      STATUS+0, 0
	GOTO       L_main32
;F2L.c,364 :: 		LED1 = ON;
	BSF        LATA+0, 5
;F2L.c,365 :: 		}
	GOTO       L_main33
L_main32:
;F2L.c,368 :: 		LED1 = OFF;
	BCF        LATA+0, 5
;F2L.c,369 :: 		}
L_main33:
;F2L.c,370 :: 		if ( pulse_count > potmeter2 )
	MOVF       F2L_pulse_count+1, 0
	SUBWF      F2L_potmeter2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main59
	MOVF       F2L_pulse_count+0, 0
	SUBWF      F2L_potmeter2+0, 0
L__main59:
	BTFSC      STATUS+0, 0
	GOTO       L_main34
;F2L.c,372 :: 		LED2 = ON;
	BSF        LATA+0, 4
;F2L.c,373 :: 		}
	GOTO       L_main35
L_main34:
;F2L.c,376 :: 		LED2 = OFF;
	BCF        LATA+0, 4
;F2L.c,377 :: 		}
L_main35:
;F2L.c,378 :: 		if ( pulse_count > potmeter3 )
	MOVF       F2L_pulse_count+1, 0
	SUBWF      F2L_potmeter3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main60
	MOVF       F2L_pulse_count+0, 0
	SUBWF      F2L_potmeter3+0, 0
L__main60:
	BTFSC      STATUS+0, 0
	GOTO       L_main36
;F2L.c,380 :: 		LED3 = ON;
	BSF        LATC+0, 5
;F2L.c,381 :: 		}
	GOTO       L_main37
L_main36:
;F2L.c,384 :: 		LED3 = OFF;
	BCF        LATC+0, 5
;F2L.c,385 :: 		}
L_main37:
;F2L.c,386 :: 		if ( pulse_count > potmeter4 )
	MOVF       F2L_pulse_count+1, 0
	SUBWF      F2L_potmeter4+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main61
	MOVF       F2L_pulse_count+0, 0
	SUBWF      F2L_potmeter4+0, 0
L__main61:
	BTFSC      STATUS+0, 0
	GOTO       L_main38
;F2L.c,388 :: 		LED4 = ON;
	BSF        LATC+0, 4
;F2L.c,389 :: 		}
	GOTO       L_main39
L_main38:
;F2L.c,392 :: 		LED4 = OFF;
	BCF        LATC+0, 4
;F2L.c,393 :: 		}
L_main39:
;F2L.c,395 :: 		}
L_main31:
;F2L.c,397 :: 		}  // while(1)
	GOTO       L_main18
;F2L.c,399 :: 		} //~!
L_end_main:
	GOTO       $+0
; end of _main
