.asm.obj:
	tasm /l $<

cards.exe: cards.obj random.obj
	tlink /v @cards.rsp
