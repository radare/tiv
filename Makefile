VALAC=valac
DESTDIR?=/
PREFIX?=usr

all: tiv

tiv: tiv.vala
	${VALAC} tiv.vala --pkg gdk-3.0 --pkg linux

clean:
	rm -f tiv

install:
	cp tiv ${DESTDIR}/${PREFIX}/bin

uninstall deinstall:
	rm -f ${DESTDIR}/${PREFIX}/bin/tiv

test:
	./tiv img/kodim23.jpg

.PHONY: all clean test install uninstall deinstall
