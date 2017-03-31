VALAC=valac
DESTDIR?=/
PREFIX?=usr
CFLAGS += -I/opt/local/include -I/usr/local/include
JPEGLIBS += -L/opt/local/lib -L/usr/local/lib -L/usr/local/Cellar -ljpeg


all: tiv stiv stiv-jpeg

stiv-jpeg: stiv-jpeg.o stiv.c
	${CC} stiv-jpeg.o -o stiv-jpeg ${JPEGLIBS}

stiv: stiv.o
	${CC} stiv.o -o stiv

tiv: tiv.vala
	${VALAC} tiv.vala --pkg gdk-3.0 --pkg linux

clean:
	rm -f tiv stiv stiv-jpeg stiv-jpeg.static stiv-jpeg.o stiv.o

install:
	cp tiv ${DESTDIR}/${PREFIX}/bin
	cp stiv-jpeg ${DESTDIR}/${PREFIX}/bin

uninstall deinstall:
	rm -f ${DESTDIR}/${PREFIX}/bin/tiv
	rm -f ${DESTDIR}/${PREFIX}/bin/stiv-jpeg

test:
	./tiv img/kodim23.jpg

.PHONY: all clean test install uninstall deinstall

osx:
	${CC} -o stiv-jpeg.static stiv-jpeg.c -I /opt/local/include/ /opt/local/lib/libjpeg.a 
