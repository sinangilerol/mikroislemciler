
.org 0
   rjmp main

main:
   ldi r16,0x80 	; 0x20=0010 0000 -> PORTB nin 5. pinini output yapmak istiyoruz, o nedenle 5. bit 1
   out DDRB,r16		; PortB nin data direction registeri DDRB ye r16 daki degeri yaziyoruz
   clr r17			; r17 yi LED imizi yakip sondurmek icin gecici olarak kullanacagiz.
mainloop:
   eor r17,r16 		; r16 da bulunan ve degistirilmeyen 0x20 verisiyle r17 yi XOR luyoruz. 
					; Bu sayede, bu komut her calistirildiginda 5. bit 1 ve 0 arasinda surekli olarak
					; deger degistirir; ledin yanip sonmesini saglar.
   out PORTB,r17 	; r17 deki degeri PORTB ye yaziyoruz.
   call wait 		; 700ms lik bekleme fonksiyonumuzu cagiriyoruz.
   rjmp mainloop 	; programin mainloop etiketine giderek sonsuz dongude calismasini sagliyoruz.

wait:				; 700ms lik bekleme saglayan fonksiyonumuz
   push r16			; mainloop icerisinde kullandigimiz r16 ve r17 nin degerlerini wait icinde de kullanmak istiyoruz.
   push r17			; bu nedenle push komutunu kullanarak bu registerlarin icindeki degerleri yigina kaydediyoruz
   
   ldi r16,0x40 	; 0x400000 kere dongu calistirilacak
   ldi r17,0x00 	; ~12 milyon komut cycle i surecek
   ldi r18,0x00 	; 16Mhz calisma frekansi icin ~0.7s zaman gecikmesi elde edilecek
_w0:
   dec r18			; r18 deki degeri 1 azalt
   brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan
   dec r17			; r17 deki degeri 1 azalt
   brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan
   dec r16			; r16 daki degeri 1 azalt
   brne _w0			; azaltma sonucu elde edilen deger 0 degilse _w0 a dallan

   pop r17			; fonksiyondan donmeden once en son push edilen r17 yi geri cek
   pop r16			; r16 yi geri cek
   
   ret				; fonksiyondan geri don
