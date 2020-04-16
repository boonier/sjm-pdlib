<CsoundSynthesizer>
<CsOptions>
-d -n
</CsOptions>
<CsInstruments>
;sr is set by the host
ksmps 		= 	64
nchnls 		= 	2
0dbfs		=	1	;MAXIMUM AMPLITUDE

;Author: Iain McCurdy (2013)
;http://iainmccurdy.org/csound.html

/* FFT attribute tables */
giFFTattributes1	ftgen	0, 0, 4, -2,   64,  32,   64, 1
giFFTattributes2	ftgen	0, 0, 4, -2,  128,  64,  128, 1
giFFTattributes3	ftgen	0, 0, 4, -2,  256, 128,  256, 1
giFFTattributes4	ftgen	0, 0, 4, -2,  512, 128,  512, 1
giFFTattributes5	ftgen	0, 0, 4, -2, 1024, 256, 1024, 1
giFFTattributes6	ftgen	0, 0, 4, -2, 2048, 512, 2048, 1
giFFTattributes7	ftgen	0, 0, 4, -2, 4096, 1024, 4096, 1
giFFTattributes8	ftgen	0, 0, 4, -2, 8192, 2048, 8192, 1

opcode	pvsfreeze_module,a,akkkkiiiik
	ain,kfreeza,kfreezf,kmix,klev,iFFTsize,ioverlap,iwinsize,iwintype,klock	xin
	f_anal  	pvsanal	ain, iFFTsize, ioverlap, iwinsize, iwintype		;ANALYSE AUDIO INPUT SIGNAL AND OUTPUT AN FSIG
	f_freeze	pvsfreeze f_anal, kfreeza, kfreezf
	f_lock 		pvslock f_freeze, klock
	aout		pvsynth f_lock
	amix		ntrpol	ain, aout, kmix	;CREATE DRY/WET MIX
				xout	amix*klev	
endop

instr	1
	kmix		chnget	"mix"			; read in widgets
	klev		chnget	"lev"
	kfreeza		chnget	"freeza"
	kfreezf		chnget	"freeza"
	kfreezb		chnget	"freezb"
	klock		chnget	"lock"
	
	; triggering of 'Freeze All' mode
	kon		=	1
	koff		=	0
	ktrigon		trigger	kfreezb,0.5,0
	ktrigoff	trigger	kfreezb,0.5,1
	if(ktrigon==1) then
	 chnset		kon,"freeza"
	 chnset		kon,"freezf"
	elseif(ktrigoff==1) then
	 chnset		koff,"freeza"
	 chnset		koff,"freezf"
	endif

	; audio input
	ainL,ainR	ins

	; auto freeze triggering
	kauto	chnget	"auto"				; read in widgets
	kthresh	chnget	"thresh"
	kdelay	chnget	"delay"
	if kauto==1 then				; if 'Auto' is on
	 krms	rms	ainL+ainR			; scan RMS of audio signal
	 ktrig	trigger	krms,kthresh,0			; if signal crosses threshold upwards																																																																													
	 ktrigdel	vdel_k	ktrig,kdelay,0.5	; delayed version of the trigger
	 if ktrig==1 then				; if initial threshold crossing occurs...
	  outvalue		"freeza", koff		; turn freezing off
	  outvalue		"freezf", koff
	 endif
	 if ktrigdel==1 then				; if delayed trigger is received...
	  outvalue		"freeza", kon		; turn freezing on
	  outvalue		"freezf", kon
	 endif
	endif

	kofftrig	trigger	kauto,0.5,1		; when 'Auto' is turned off generate a trigger
	if kofftrig==1 then				; if 'Auto' is turned off...
	 outvalue		"freeza", koff			; turn freezing off
	 outvalue		"freezf", koff
	endif	

	/* SET FFT ATTRIBUTES */
	katt_table	chnget	"att_table"	; FFT atribute table
	katt_table	init	5
	ktrig		changed2	katt_table
	
	if ktrig==1 then
	 reinit update
	endif
	update:
	iFFTsize	table	0, giFFTattributes1 + i(katt_table) - 1
	print iFFTsize
	ioverlap	table	1, giFFTattributes1 + i(katt_table) - 1
	print ioverlap
	iwinsize	table	2, giFFTattributes1 + i(katt_table) - 1
	print iwinsize
	iwintype	table	3, giFFTattributes1 + i(katt_table) - 1
	print iwintype
	/*-------------------*/
	
	aoutL		pvsfreeze_module	ainL,kfreeza,kfreezf,kmix,klev,iFFTsize,ioverlap,iwinsize,iwintype, klock
	aoutR		pvsfreeze_module	ainR,kfreeza,kfreezf,kmix,klev,iFFTsize,ioverlap,iwinsize,iwintype, klock
				outs				aoutR,aoutR
endin

</CsInstruments>

<CsScore>
i 1 0 [60*60*24*7]
</CsScore>

</CsoundSynthesizer>