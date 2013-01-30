VALAC=valac
DESTDIR?=/
PREFIX?=usr

all: tiv stiv

tiv: tiv.vala
	${VALAC} tiv.vala --pkg gdk-3.0 --pkg linux

stiv: stiv.o
	${CC} stiv.o -o stiv

clean:
	rm -f tiv stiv

install:
	cp tiv ${DESTDIR}/${PREFIX}/bin
	cp stiv ${DESTDIR}/${PREFIX}/bin

uninstall deinstall:
	rm -f ${DESTDIR}/${PREFIX}/bin/tiv
	rm -f ${DESTDIR}/${PREFIX}/bin/stiv

test:
	./tiv img/kodim23.jpg

.PHONY: all clean test install uninstall deinstall
