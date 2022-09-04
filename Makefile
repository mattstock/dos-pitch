.asm.obj:
	tasm /l $<

cards.obj: random.inc misc.inc

random.obj: random.inc

misc.obj: misc.inc

cards.exe: cards.obj random.obj misc.obj
	tlink /v @cards.rsp

vidtest.exe: video.obj
	tlink /v video.obj

all: cards.exe vidtest.exe

clean:
	del *.OBJ *.LST *~ *.MAP *.EXE
