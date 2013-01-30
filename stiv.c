#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define XY(b,x,y) ( b+((y)*(w*3))+(x*3) )
#define ABS(x) (((x)<0)?-(x):(x))

static int ponderate (int x, int y) {
	return ABS (x) * y;
}

static int reduce8 (int r, int g, int b) {
	int colors_len = 8;
	int select = 0;
	int odistance = -1;
	int i, k = 1;
	int colors[][3] = {
		{ 0x00,0x00,0x00 }, // black
		{ 0xd0,0x10,0x10 }, // red
		{ 0x10,0xe0,0x10 }, // green
		{ 0xf7,0xf5,0x3a }, // yellow
		{ 0x10,0x10,0xe0 }, // blue
		{ 0xfb,0x3d,0xf8 }, // pink
		{ 0x10,0xf0,0xf0 }, // turqoise
		{ 0xf0,0xf0,0xf0 }, // white
	};

	r /= k; r *= k;
	g /= k; g *= k;
	b /= k; b *= k;
	// B&W
	if (r<30 && g<30 && b<30) return 0;
	if (r>200&& g>200&& b>200) return 7;
	odistance = -1;
	for (i = 0; i<colors_len; i++) {
		int distance =
			  ponderate (colors[i][0]-r, r)
			+ ponderate (colors[i][1]-g, g)
			+ ponderate (colors[i][2]-b, b);
		if (odistance == -1 || distance < odistance) {
			odistance = distance;
			select = i;
		}
	}
	return select;
}
void
render_ansi(const unsigned char *c, const unsigned char *d) {
	int fg = 0;
	int color = reduce8 (c[0], c[1], c[2]);
	if (color == -1)return;
	//if (c[0]<30 && c[1]<30 && c[2]<30) fg = 1;
	printf ("\x1b[%dm", color+(fg?30:40));
}

static int rgb(int r, int g, int b) {
	if (r<0) r=0; if (r>255) r = 255;
	if (g<0) g=0; if (g>255) g = 255;
	if (b<0) b=0; if (b>255) b = 255;
	r = (int)(r/50.6); 
	g = (int)(g/50.6);
	b = (int)(b/50.6);
	return 16 + (r*36) + (g*6) + b;
}

void
render_rgb(const unsigned char *c, const unsigned char *d) {
	printf ("\x1b[%d;5;%dm", 38, rgb (c[0], c[1], c[2]));
	printf ("\x1b[%d;5;%dm", 48, rgb (d[0], d[1], d[2]));
}

void
render_greyscale(const unsigned char *c, const unsigned char *d) {
	int color, color1, color2, k;
	color1 = (c[0]+c[1]+c[2]) / 3;
	color2 = (d[0]+d[1]+d[2]) / 3;
	k = 231 + ((int)((float)color1/10.3));
	if (k<232) k = 232;
	printf ("\x1b[%d;5;%dm", 48, k); // bg
	k = 231 + ((int)((float)color2/10.3));
	if (k<232) k = 232;
	printf ("\x1b[%d;5;%dm", 38, k); // fg
}

void
render_ascii(const unsigned char *c, const unsigned char *d) {
	const char *pal = " `.,-:+*%$#";
	int idx, pal_len = strlen (pal);
	float p = (c[0]+c[1]+c[2])/3;
	float q = (d[0]+d[1]+d[2])/3;
	idx = ((p+q)/2) / (255/pal_len);
	if (idx >= pal_len) idx = pal_len-1;
	printf ("%c", pal[idx]);
}

int
main(int argc, char **argv) {
	unsigned char *buf, *c, *d;
	int x, y, w, h, imgsz, readsz;
	if (argc<3) {
		printf ("stiv . suckless terminal image viewer\n");
		printf ("Usage: stiv [width] [height] < rgb24\n");
		return 1;
	}
	w = atoi (argv[1]);
	h = atoi (argv[2]);
	if (w<1 || h<1) {
		printf ("Invalid arguments\n");
		return 1;
	}
	imgsz = w * h * 3;
	buf = malloc (imgsz);
	readsz = 0;
	do {
		int n = read (0, buf+readsz, imgsz);
		if (n<1) break;
		readsz += n;
	} while (readsz < imgsz);
	for (y=0; y<h; y+=2) {
		for (x=0; x<w; x++) {
			c = XY (buf, x, y);
			d = XY (buf, x, y+1);
			if (d> (buf+readsz)) return 0;
			//render_greyscale (c, d);
			render_rgb (c, d);
			//render_ansi (c, d);
			render_ascii (c, d);
		}
		printf ("\x1b[0m\n");
	}
	free (buf);
	return 0;
}
