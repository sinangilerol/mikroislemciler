
.org 0
   rjmp main
main:
   ldi r16,0xff 	
   out DDRC,r16		
   clr r17

   ldi r20,0x00
   ldi r22,0xff
   out DDRA,r20
   out PORTA,r22

   ldi r17,0x01 	 
				
mainloop:
call wait
   sbis PINA,0
   call bekle				
   clc 			
   out PORTC,r17 	
   call wait
   rol r17 
   brcs sag
   		
   rjmp mainloop 	
wait:				
   push r16			
   push r17			
   
   ldi r16,0x10 	
   ldi r17,0x03 	
   ldi r18,0x00 	
_w0:
   dec r18			
   brne _w0			
   dec r17			
   brne _w0			
   dec r16			
   brne _w0			
   pop r17
   pop r16
   ret				

sag:
  clc 
  ldi r17,0b10000000
sag_d:
  sbis PINA,0
  call bekle
  out PORTC, r17
  call wait
  ror r17 
  brcs main

  rjmp sag_d

bekle:
  call wait
bekle2:
  sbis PINA,0
  ret
  rjmp bekle2