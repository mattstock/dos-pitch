all: cards.exe

cards.exe: cards.obj random.obj misc.obj video.obj ai.obj player.obj debug.obj
	tlink /v @cards.rsp

.asm.obj:
	tasm /m /l $<

cards.obj: random.inc misc.inc video.inc ai.inc globals.inc player.inc debug.inc

ai.obj: ai.inc ai.asm globals.inc misc.inc

random.obj: random.inc random.asm

misc.obj: misc.inc misc.asm

video.obj: video.inc video.asm

player.obj: player.inc player.asm

debug.obj: debug.inc debug.asm

