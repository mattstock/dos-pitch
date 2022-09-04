.asm.obj:
	tasm /l $<

cards.obj: random.inc misc.inc video.inc

random.obj: random.inc

misc.obj: misc.inc

video.obj: video.inc

cards.exe: cards.obj random.obj misc.obj video.obj
	tlink /v @cards.rsp

