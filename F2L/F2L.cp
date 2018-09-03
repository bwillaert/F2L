#line 1 "C:/Users/b/Documents/GitHub/MD/F2L/F2L.c"
#line 70 "C:/Users/b/Documents/GitHub/MD/F2L/F2L.c"
static unsigned int pulse_count;
static unsigned int potmeter1;
static unsigned int potmeter2;
static unsigned int potmeter3;
static unsigned int potmeter4;

const char STR_WELCOME[] = "Start measuring";







void interrupt(void)
{

 if (PIR2.C1IF)
 {
 pulse_count++;

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





void sendchar( char c)
{

 while (!UART1_Tx_Idle())
 {
 Delay_us(100);
 }
 UART1_Write(c);


}




void sendhex (unsigned long hexnumber, unsigned char cr )
{

 int nibble = 0;
 const char hexnr[]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

 for (nibble = 0; nibble < 6; nibble++)
 {
 sendchar(hexnr[(hexnumber&0xF00000)>>20]);
 hexnumber<<=4;
 }
 if (cr ==  2  )
 {
 sendchar('\r');
 sendchar('\n');
 }
 else if (cr ==  1 )
 {
 sendchar('\r');
 }


}



void sendstring (char* string, unsigned char cr)
{

 int i = 0;
 char c;
 while (c=string[i++])
 {
 sendchar(c);
 }


 if (cr ==  2  )
 {
 sendchar('\r');
 sendchar('\n');
 }
 else if (cr ==  1 )
 {
 sendchar('\r');
 }

}






void main()
{


 OSCCON= 0xF0;



 TRISA.TRISA0 =  1 ;
 PORTA.RA0 = 1;
 TRISA.TRISA1 =  1 ;
 PORTA.RA1 = 1;
 TRISA.TRISA2 =  0  ;
 PORTA.RA2 = 1;
 TRISA.TRISA3 =  1 ;
 PORTA.RA2 = 1;
 TRISA.TRISA4 =  0 ;
 PORTA.RA4 = 1;
 TRISA.TRISA5 =  0 ;
 PORTA.RA5 = 1;


 TRISC.TRISC0 =  1 ;
 PORTC.RC0 = 1;
 TRISC.TRISC1 =  1 ;
 PORTC.RC1 = 1;
 TRISC.TRISC2 =  1 ;
 PORTC.RC2 = 1;
 TRISC.TRISC3 =  0 ;
 PORTC.RC3 = 1;
 TRISC.TRISC4 =  0 ;
 PORTC.RC4 = 1;
 TRISC.TRISC5 =  0 ;
 PORTC.RC5 = 1;


 ANSELA.ANSA0 = 1;
 ANSELA.ANSA1 = 1;

 ANSELC.ANSC0 = 1;
 ANSELC.ANSC1 = 1;


 CM1CON0.C1POL = 0;
 CM1CON0.C1OE = 0;
 CM1CON0.C1SP = 1;
 CM1CON0.C1ON = 1;
 CM1CON0.C1HYS = 1;
 CM1CON0.C1SYNC = 0;
 CM1CON1.C1NCH0 = 1;
 CM1CON1.C1NCH1 = 0;
 CM1CON1.C1PCH0 = 1;
 CM1CON1.C1PCH1 = 0;


 DACCON0.DACEN = 1;
 DACCON0.DACLPS = 0;
 DACCON0.DACOE = 0;
 DACCON0.DACPSS0 = 0;
 DACCON0.DACPSS1 = 0;
 DACCON0.DACNSS = 0;
 DACCON1 = 16;


 ADCON0.ADON = 1;
 ADCON1.ADFM = 1;
 ADCON1.ADCS0 = 0;
 ADCON1.ADCS1 = 1;
 ADCON1.ADCS2 = 1;
 ADCON1.ADNREF = 0;
 ADCON1.ADPREF0 = 0;
 ADCON1.ADPREF1 = 0;




 CM1CON1.C1INTP = 1;
 CM1CON1.C1INTN = 0;
 PIE2.C1IE = 0;

 INTCON.PEIE = 1;
 INTCON.GIE = 1;



 APFCON0.RXDTSEL = 0;

 APFCON0.TXCKSEL = 0;


 UART1_Init(9600);





  LATA.LATA5  =  1 ;
  LATA.LATA4  =  1 ;
  LATC.LATC5  =  1 ;
  LATC.LATC4  =  1 ;
 Delay_ms(500);
  LATA.LATA5  =  0 ;
  LATA.LATA4  =  0 ;
  LATC.LATC5  =  0 ;
  LATC.LATC4  =  0 ;




 sendstring(STR_WELCOME,  2 );






 while(1)
 {

 pulse_count = 0;


 PIE2.C1IE = 1;
 Delay_ms( 128 );
 PIE2.C1IE = 0;


 if (pulse_count > 1024)
 {
 pulse_count = 1024;
 }


 potmeter1 = ADC_Read(0);
 potmeter2 = ADC_Read(1);

 potmeter4 = ADC_Read(4);

 sendhex (potmeter1,  0 );
 sendchar(',');
 sendchar(' ');
 sendhex (pulse_count,  2 );

 if ( PORTA.RA3 )
 {
 if ( absvalue(pulse_count, potmeter1) <  20 )
 {
  LATA.LATA5  =  1 ;
 }
 else
 {
  LATA.LATA5  =  0 ;
 }
 if ( absvalue(pulse_count, potmeter2) <  20 )
 {
  LATA.LATA4  =  1 ;
 }
 else
 {
  LATA.LATA4  =  0 ;
 }
 if ( absvalue(pulse_count, potmeter3) <  20 )
 {
  LATC.LATC5  =  1 ;
 }
 else
 {
  LATC.LATC5  =  0 ;
 }
 if ( absvalue(pulse_count, potmeter4) <  20 )
 {
  LATC.LATC4  =  1 ;
 }
 else
 {
  LATC.LATC4  =  0 ;
 }
 }
 else
 {
 if ( pulse_count > potmeter1 )
 {
  LATA.LATA5  =  1 ;
 }
 else
 {
  LATA.LATA5  =  0 ;
 }
 if ( pulse_count > potmeter2 )
 {
  LATA.LATA4  =  1 ;
 }
 else
 {
  LATA.LATA4  =  0 ;
 }
 if ( pulse_count > potmeter3 )
 {
  LATC.LATC5  =  1 ;
 }
 else
 {
  LATC.LATC5  =  0 ;
 }
 if ( pulse_count > potmeter4 )
 {
  LATC.LATC4  =  1 ;
 }
 else
 {
  LATC.LATC4  =  0 ;
 }

 }

 }

}
