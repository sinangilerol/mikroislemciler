
.org 0
giris_cikis_ayari:
	ldi r16,255		
	out ddrc,r16 ;C portu cikis 
	ldi r16,0
	out ddrb,r16;B portu giris
	ldi r16,255
	out portb,r16;pull up aktif
	ldi r16,1 ;ilk yanacak led
	ldi r20,90;ilk bekleme
	ldi r18,0 ;r18 ve r19 kontrol registerleri
	ldi r19,0

led_yak:  
	out portc,r16
	call bekle

led_sondur: 
	ldi r17,0
	out portc,r17 ;ledler sifirlandi
	call bekle

/*  KONTROL REGISTERI:r18
bitler: r18(0):b0 pinine basilirsa 1 olur, kalici degildir
		r18(1):b1 pinine basilirsa 1 olur, kalici degildir
		r18(2):b2 pinine basilirsa 1 olur, kalici degildir
		r18(3):yon registeridir, 0=saat yonu, 1=tersi                           -> r18(1) ile kontrol
		r18(4),r18(5):arttirma registerleridir, 00:+1 ,01:+2, 10:+3 ,11 :+4     -> r18(2) ile kontrol
		r18(6),r18(7):sure registerleridir: 00:yavaþ ,01:orta ,10: hýzlý		-> r18(0) ile kontrol
*/

bit_ayarla:
ilk_bit:  ;r18(0)
;HIZ
	sbrs r18,0 
	jmp ikinci_bit  ;butona basilmamissa hizi degistirme,diger butonlari kontrol et

	sbrs r18,7
	jmp _yedi_sifir 
	jmp _yedi_bir

_yedi_sifir:
	sbrs r18,6  
	jmp __ysifir_altisifir
	jmp __ysifir_altibir

__ysifir_altisifir: ;00
	ori r18,0x40 ;6.bit=1 oldu --- sonuc=01
	jmp led_ayarla ;gösterime geç

__ysifir_altibir:  ;01
	ori r18,0x80 ;7.bit=1 oldu
	andi r18, 0xbf ;6.bit 0 oldu ----sonuc=10
	jmp led_ayarla ;gosterime gec

_yedi_bir: ;10 
	andi r18,0x3f ;7.bit=0 ,6.bit=0 ----sonuc=00 
	jmp led_ayarla ; gösterime gec

;YÖN
ikinci_bit: ;r18(1)
	sbrs r18,1
	jmp ucuncu_bit  ;0 sa 3.biti kontrol et
	sbrs r18,3
	jmp _uc_sifir
	jmp _uc_bir

_uc_sifir: ;0
	ori r18,0x08 ;3.bit=1
	jmp led_ayarla ;gosterime gec

_uc_bir:  ;1
	andi r18,0xf7 ;3.bit=0 
	jmp led_ayarla ;gosterime gec

;ARTIS SAYISI
ucuncu_bit: ;r18(2)
	sbrs r18,2
	jmp led_ayarla
	ldi r19,1 ;r19 registeri butona basildiginda 1 olur(0.bit) ama gosterme dongusu bittikten sonra sifirlanir.
	sbrs r18,5
	jmp _bes_sifir
	jmp _bes_bir

_bes_sifir:
	sbrs r18,4
	jmp __bsifir_dortsifir
	jmp __bsifir_dortbir

__bsifir_dortsifir: ;00
	ori r18,0x10 ;4.bit=1  -- 01
	jmp led_ayarla

__bsifir_dortbir:  ;01
	ori r18,0x20  ;5.bit=1 
	andi r18,0xef ;4. bit=0---sonuc:10
	jmp led_ayarla

_bes_bir:
	sbrs r18,4
	jmp __bbir_dortsifir
	jmp __bbir_dortbir

__bbir_dortsifir: ;10
	ori r18,0x10 ;11 
	jmp led_ayarla

__bbir_dortbir: ;11
	andi r18,0xcf;00
	jmp led_ayarla

led_ayarla:

sure_ayarla:
	sbrs r18,7
	jmp _l_yedi_sifir
	jmp _l_yedi_bir

_l_yedi_sifir:
	sbrs r18,6
	jmp __l_ysifir_asifir
	jmp __l_ysifir_abir
	
__l_ysifir_asifir: ;00
	ldi r20,90  ;r20 registeri bekleme fonksiyonunun en fazla agirliga sahip registeridir.
	jmp sayi_ayarla 

__l_ysifir_abir:  ;01
	ldi r20,50 
	jmp sayi_ayarla

_l_yedi_bir: ;10
	ldi r20,30 
	jmp sayi_ayarla

sayi_ayarla:
	sbrs r19,0
	jmp yon_ayarla ;b(2) butonuna basilmadiysa eski sayiyi dondur
	jmp sayi_bul   ;b(2) butonuna basildiysa,artirilacak sayiyi bul

sayi_bul:
	sbrs r18,5
	jmp ddd_bir ;0
	jmp arttir

ddd_bir:
	sbrs r18,4
	jmp azalt ;00 -> 4 den 1 e gelmiþ
	jmp arttir 

azalt:
	//arasinda 4 bit fark olan bitler (0-4,1-5,2-6,3-7) ayni anda yanamaz ör:(0-4) if 0.bit=1,register=1 ; if 0.bit=0 ,register =16
	sbrs r16,4
	jmp biryap
	jmp onaltiyap

biryap:
	ldi r16,1
	jmp	register_ayarla
	
onaltiyap:
	ldi r16,16
	jmp register_ayarla
	
arttir:
	sbrs r18,3 ;yon butonu
	jmp s_yonu_arttir
	jmp s_tersi_arttir

s_yonu_arttir:
	lds r24,16
	rol r24
	brcc  orlama_odasi ;carry olusmamissa direkt yeni sayiyi bul
	inc r24 ; carryi ekledik
	or r16,r24
	clc ;carry flagi 0 yapildi
	jmp register_ayarla					
					
orlama_odasi:
	or r16,r24
	jmp register_ayarla

s_tersi_arttir:	
	lds r24,16
	ror r24
	brcc _orlama_odasi
	ldi r17,128
	add r24,r17 ; son bite carryi ekledik
	or r16,r24
	clc ;carry 0 yapildi
	jmp register_ayarla					

_orlama_odasi:
	or r16,r24
	jmp register_ayarla	
	
yon_ayarla:
	
	sbrs r18,3 ;yon butonu
	jmp s_yonu
	jmp s_tersi

s_yonu:
	rol r16
	brcc register_ayarla
	inc r16 ; carryi ekledik
	clc ;carry flagi 0 yapildi
	jmp register_ayarla 

s_tersi:
	ror r16
	brcc register_ayarla
	ldi r17,128
	add r16,r17 ; son bite carryi ekledik
	clc ;carry 0 yapildi
	jmp register_ayarla	

register_ayarla:
	ldi r24,0xf8
	and r18,r24 ;buton kontrol bitleri sifirlandi
	ldi r24,0
	and r19,r24 ;ilk basis kontrol sifirlandi
	clc ; carry sifirlandi
	jmp led_yak

bekle:				

	lds r17,20 ; r20 yi kopyaladi
L1:
	LDI	R21,200
L2:
	LDI	R22,250
L3:
	NOP
	NOP
	DEC	R22
	BRNE	L3
	DEC R21
	BRNE	L2
	call buton_kontrol
	DEC R17
	BRNE	L1
	ret

buton_kontrol:

	sbis pinb,0
	ori r18,1
	sbis pinb,1
	ori r18,2
	sbis pinb,2
	ori r18,4
	ret