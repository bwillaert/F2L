/*
 * Project name:  Frequency to light converter
     Frequency set via potmeter = ADC input
     Audio input amolified = input to comparator
     Comparator slicing level set by DAC
     Count comparator output interrupts.
     
 * Copyright:
     (c) BW, 2018.
     
 * Configuration:
     MCU:             PIC16F1824
     Oscillator:      Internal, 32.0000 MHz
     
 * Conversion:
     ADC value 0...1024 = number of pulses in 256 ms
     Frequency = (1/256) * 1024 = 4 kHz
     V = 5/4096 * F[Hz]  --> 1000 Hz = 1.25V


 */
//======================================================================
//
// constant values
//
#define RS_OUTPUT

// I/O pins
#define LED1                LATA.LATA5            // LED1 OUT     pin 2 = RA5
#define LED2                LATA.LATA4            // LED2 OUT     pin 3 = RA4
#define LED3                LATC.LATC5            // LED3 OUT     pin 5 = RC5
#define LED4                LATC.LATC4            // LED4 OUT     pin 6 = RC4 = RS TX
#define LED_SOUND           LATC.LATC3            // LED_SOUND    pin 7 = RC3
#define MODE_EQUAL          PORTA.RA3             // IN   mode switch pin 4

/*
  FV1   = p13 = AN0 = potmeter1
  FV2   = p12 = AN1 = potmeter2
  FV3   = p11 = AN2 = potmeter3
  FV4   = p10 = AN4 = potmeter4
  
  AUDIO_IN = p9 = C12IN1-
*/


// The 2 sensor signals are connected to CMP1 - inputs 1 and 2
// C12IN1-               RC1 p9

// C1OUT                 RA2 p11
// RS232 TX pin          RC4 p6
// RS232 RX pin          RC5 p5

#define SAMPLE_TIME_MS     128             // Pulse count interval
#define SAMPLE_TOLERANCE   20              // Difference between pulse count and potmeter value

#define TRUE 1
#define FALSE 0

#define OFF 0
#define ON  1

#define IN 1
#define OUT 0

// Line termination characters
#define LINE_NONE  0
#define LINE_CR    1
#define LINE_CR_LF 2


static unsigned int   pulse_count;
static unsigned int   potmeter1;
static unsigned int   potmeter2;
static unsigned int   potmeter3;
static unsigned int   potmeter4;

const char STR_WELCOME[] = "Start measuring";

//======================================================================
//
//  ISR
//  Count comparator1 output pulses
//
//
void interrupt(void)
{
     // Comparator output interrupt
     if (PIR2.C1IF)
     {
        pulse_count++;
        // Reset interrupt flag
        PIR2.C1IF = 0;
      }
}


unsigned int absvalue(unsigned int a, unsigned int b)
{
    if (a > b)
    {
      return (a-b);
    }
    else
    {
      return (b-a);
    }

}


//======================================================================
// Send a single character over RS232
//
void sendchar( char c)
{
#ifdef RS_OUTPUT
      while (!UART1_Tx_Idle())
      {
         Delay_us(100);
      }
      UART1_Write(c);

#endif
}

//======================================================================
// Send a 16 bit number over RS232
//
void sendhex (unsigned long hexnumber, unsigned char cr )
{
#ifdef RS_OUTPUT
      int nibble = 0;
      const char hexnr[]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

      for (nibble = 0; nibble < 6; nibble++)
      {
          sendchar(hexnr[(hexnumber&0xF00000)>>20]);
          hexnumber<<=4;
      }
      if (cr == LINE_CR_LF )
      {
       sendchar('\r');
       sendchar('\n');
      }
      else if (cr == LINE_CR)
      {
        sendchar('\r');
      }

#endif
}
//======================================================================
// Send a string over RS232
//
void sendstring (char* string, unsigned char cr)
{
#ifdef RS_OUTPUT
      int i = 0;
      char c;
      while (c=string[i++])
      {
              sendchar(c);
      }


      if (cr == LINE_CR_LF )
      {
       sendchar('\r');
       sendchar('\n');
      }
      else if (cr == LINE_CR)
      {
        sendchar('\r');
      }
#endif
}


//===================================
//
// main idle loop
//
void main()
{

    // oscillator
    OSCCON= 0xF0;

    // GPIO init
    // PORT A
    TRISA.TRISA0 = IN;  // PIN 13 = AN0  = potmeter1
    PORTA.RA0 = 1;
    TRISA.TRISA1 = IN;  // PIN 12 = AN1  = potmeter2
    PORTA.RA1 = 1;
    TRISA.TRISA2 = IN;  // PIN 11 = AN2  = potmeter3 = COMP1 OUT    xxxxxxxxxxx
    PORTA.RA2 = 1;
    TRISA.TRISA3 = IN;  // PIN 4 = MODE switch
    PORTA.RA2 = 1;
    TRISA.TRISA4 = OUT; // PIN 3 = LED2
    PORTA.RA4 = 1;
    TRISA.TRISA5 = OUT; // PIN 2 = LED1
    PORTA.RA5 = 1;

    // PORT C
    TRISC.TRISC0 = IN;  // PIN 10 = AN4 = potmeter4
    PORTC.RC0 = 1;
    TRISC.TRISC1 = IN;  // PIN 9 = audio in = C12IN1-
    PORTC.RC1 = 1;
    TRISC.TRISC2 = IN;  // PIN 8 = NA = C12IN2-
    PORTC.RC2 = 1;
    TRISC.TRISC3 = OUT; // PIN 7 = LED_SOUND
    PORTC.RC3 = 1;
    TRISC.TRISC4 = OUT; // PIN 6 = LED4
    PORTC.RC4 = 1;
    TRISC.TRISC5 = OUT; // PIN 5 = LED3
    PORTC.RC5 = 1;

    // Analog input pins
    ANSELA.ANSA0 = 1;     // potmeter1
    ANSELA.ANSA1 = 1;     // potmeter2
    ANSELA.ANSA2 = 1;     // potmeter3 - COMP1 out  xxxxxxxxxxxxxx
    ANSELC.ANSC0 = 1;     // potmeter4
    ANSELC.ANSC1 = 1;     //  RC1 = C12IN1-

    // Comparator 1 init
    CM1CON0.C1POL = 0;             // comp output polarity is not inverted
    CM1CON0.C1OE = 0;              // comp output disabled   xxxxxxxxxx
    CM1CON0.C1SP = 1;              // high speed
    CM1CON0.C1ON = 1;              // comp is enabled
    CM1CON0.C1HYS = 1;             // hysteresis enabled
    CM1CON0.C1SYNC = 0;            // comp output synchronous with timer 1
    CM1CON1.C1NCH0 = 1;            // C1IN1-
    CM1CON1.C1NCH1 = 0;            // C1IN1-
    CM1CON1.C1PCH0 = 1;            // DAC reference
    CM1CON1.C1PCH1 = 0;            // DAC reference

    // DAC comparator reference
    DACCON0.DACEN = 1;             // DAC enable
    DACCON0.DACLPS = 0;            // Negative reference
    DACCON0.DACOE = 0;             // DAC output enable
    DACCON0.DACPSS0 = 0;           // VDD
    DACCON0.DACPSS1 = 0;           // VDD
    DACCON0.DACNSS = 0;            // GND
    DACCON1 = 2;                  // 5V / 32 * 2 = 0.3V

    // ADC input
    ADCON0.ADON = 1;            //  ADC on
    ADCON1.ADFM = 1;            // right justified
    ADCON1.ADCS0 = 0;           // Fosc / 64
    ADCON1.ADCS1 = 1;           // Fosc / 64
    ADCON1.ADCS2 = 1;           // Fosc / 64
    ADCON1.ADNREF = 0;          // Vref- = VSS
    ADCON1.ADPREF0 = 0;         // Vref+ = VDD
    ADCON1.ADPREF1 = 0;         // Vref+ = VDD

    // Startup values

    // Enable comparator1 interrupt
    CM1CON1.C1INTP = 1; // rising edge
    CM1CON1.C1INTN = 0; // falling edge
    PIE2.C1IE = 0; // comparator interrupt

    INTCON.PEIE = 1;
    INTCON.GIE = 1;

#ifdef RS_OUTPUT
    // RX pin on RC5
    APFCON0.RXDTSEL = 0;         // RX = pin 5 RC5
    // TX pin on RC4
    APFCON0.TXCKSEL = 0;        // pin 6 = RC4

    // Initialize UART
    UART1_Init(9600);

#endif


     // LEDs blink at startup
     LED1 = ON;
     LED2 = ON;
     LED3 = ON;
     LED4 = ON;
     LED_SOUND = ON;
     Delay_ms(500);
     LED1 = OFF;
     LED2 = OFF;
     LED3 = OFF;
     LED4 = OFF;
     LED_SOUND = OFF;


#ifdef RS_OUTPUT
    // Logo
    sendstring(STR_WELCOME, LINE_CR_LF);
#endif

     // Init ADC with default values
     // ADC_Init();

     // Main idle loop
     while(1)
     {
         // Init pulse count
         pulse_count = 0;

         // Enable comparator interrupt and count pulses
         // There is a slight error in the number of ms:
         // While counting ms, there are interrupts that count for a number of CPU cycles
         PIE2.C1IE = 1;
         Delay_ms(SAMPLE_TIME_MS);
         PIE2.C1IE = 0;

         // We have a resulting pulse count
         if (pulse_count > 1024)
         {
            pulse_count = 1024;
         }
         
         // Set confidence LED  = sound signal presence
         if (pulse_count)
         {
            LED_SOUND = ON;
         }
         else
         {
            LED_SOUND = OFF;
         }
         
         // Compare it with the potmeter values
         potmeter1 = ADC_Read(0);
         potmeter2 = ADC_Read(1);
         potmeter3 = ADC_Read(2);   //xxxxxxxxxx
         potmeter4 = ADC_Read(4);
         
         sendhex (potmeter1, LINE_NONE);
         sendchar(',');
         sendchar(' ');
         sendhex (pulse_count, LINE_CR_LF);

         if (MODE_EQUAL)
         {
           if ( absvalue(pulse_count, potmeter1) < SAMPLE_TOLERANCE)
           {
              LED1 = ON;
           }
           else
           {
              LED1 = OFF;
           }
           if ( absvalue(pulse_count, potmeter2) < SAMPLE_TOLERANCE)
           {
              LED2 = ON;
           }
           else
           {
              LED2 = OFF;
           }
           if ( absvalue(pulse_count, potmeter3) < SAMPLE_TOLERANCE)
           {
              LED3 = ON;
           }
           else
           {
              LED3 = OFF;
           }
           if ( absvalue(pulse_count, potmeter4) < SAMPLE_TOLERANCE)
           {
              LED4 = ON;
           }
           else
           {
              LED4 = OFF;
           }
         }
         else    // Mode greater than
         {
           if ( pulse_count > potmeter1 )
           {
              LED1 = ON;
           }
           else
           {
              LED1 = OFF;
           }
           if ( pulse_count > potmeter2 )
           {
              LED2 = ON;
           }
           else
           {
              LED2 = OFF;
           }
           if ( pulse_count > potmeter3 )
           {
              LED3 = ON;
           }
           else
           {
              LED3 = OFF;
           }
           if ( pulse_count > potmeter4 )
           {
              LED4 = ON;
           }
           else
           {
              LED4 = OFF;
           }

         }

     }  // while(1)

} //~!