.asm.obj:
	tasm /l $<

cards.exe: cards.obj random.obj misc.obj
	tlink /v @cards.rsp
