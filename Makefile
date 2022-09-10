.asm.obj:
	tasm /m /l $<

cards.obj: random.inc misc.inc video.inc ai.inc globals.inc

ai.obj: ai.inc ai.asm globals.inc misc.inc

random.obj: random.inc random.asm

misc.obj: misc.inc misc.asm

video.obj: video.inc video.asm

cards.exe: cards.obj random.obj misc.obj video.obj ai.obj
	tlink /v @cards.rsp

