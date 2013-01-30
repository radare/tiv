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

osx:
	valac tiv.vala -X -static --pkg linux --pkg gdk-3.0 --pkg posix -X -c
	gcc tiv.o /opt/local/lib/libglib-2.0.a /opt/local/lib/libgdk-quartz-2.0.a /opt/local/lib/libintl.a /opt/local/lib/libgobject-2.0.a /opt/local/lib/libiconv.a /opt/local/lib/libffi.a -framework CoreFoundation -framework CoreServices /opt/local/lib/libgdk_pixbuf-2.0.dylib 
