/* tiv - terminal image viewer - copyleft 2013 - pancake */
// TODO: enhace 16color dithering
// TODO: enhace asciiart mode
using Gdk;
using Linux;

string screen;
bool fix_width = false;
bool fix_height = false;
static string[] files;
static bool gotoxy00;
static bool clearscr;
private bool asciiart = false;
private bool dither16 = false;
private bool greyscale = false;
private bool interactive = false;
private int brightness = 0;
private int size = 0;

private static void newln() {
	if (asciiart)
		screen += "\n";
	else screen += "\x1b[0m\n";
}

private static void flush() {
	stdout.printf (screen);
	screen = "";
}

private static void clrscr() {
	if (gotoxy00)
		screen += "\x1b[0;0H";
	if (clearscr)
		screen += "\x1b[2J\x1b[0;0H";
	//screen += "\x1b[0;0H";
}

private static int ponderate (int x, int y) {
	return x.abs () * y;
}

private static int reduce8 (int r, int g, int b) {
	int odistance = int.MAX;
	int[,] colors = {
		{ 0x00,0x00,0x00 }, // black
		{ 0xd0,0x10,0x10 }, // red
		{ 0x10,0xe0,0x10 }, // green
		{ 0xf7,0xf5,0x3a }, // yellow
		{ 0x10,0x10,0xe0 }, // blue
		{ 0xfb,0x3d,0xf8 }, // pink
		{ 0x10,0xf0,0xf0 }, // turqoise
		{ 0xf0,0xf0,0xf0 }, // white
		//{ 0xc7,0xc7,0xc7 }, // white
	};
	int colors_len = colors.length[0];
	int select = 0;

	int k = 1;
	r /= k; r *= k;
	g /= k; g *= k;
	b /= k; b *= k;
	// B&W
	if (r<30 && g<30 && b<30) return 0;
	if (r>200&& g>200&& b>200) return 7;
	odistance = -1;
	for (int i = 0; i<colors_len; i++) {
#if 0
		int distance =
			  r-colors[i,0]
			+ g-colors[i,1]
			+ b-colors[i,2];
		int distance =
			  ponderate (r-colors[i,0], r).abs ()
			+ ponderate (g-colors[i,1], g).abs ()
			+ ponderate (b-colors[i,2], b).abs ();
#endif
		int distance =
			  ponderate (colors[i,0]-r, r)
			+ ponderate (colors[i,1]-g, g)
			+ ponderate (colors[i,2]-b, b);
		if (odistance == -1 || distance < odistance) {
			odistance = distance;
			select = i;
		}
	}
	return select;
}

private static void rgb(bool fg, int r, int g, int b) {
	int k;
	if (r<0) r=0; if (r>255) r = 255;
	if (g<0) g=0; if (g>255) g = 255;
	if (b<0) b=0; if (b>255) b = 255;
	if (asciiart) {
		return;
	}
	if (dither16) {
		//if (fg == 0) return;
		int color = reduce8 (r, g, b); // XXX: implement reduce16!!
		if (color == -1) return;
		if (r<30 && g<30 &&b<30) fg = !fg; // hack to get darker colors, must use asciiart here
		screen += "\x1b[%dm".printf (color + (fg?30:40));
		return;
	} else if (greyscale) {
		r = (r + g + b)/3;
		k = 232 + ((int)(r/10.3));
	} else {
		r = (int)(r/42.6); 
		g = (int)(g/42.6);
		b = (int)(b/42.6);
		k = 16 + (r*36) + (g*6) + b;
	}

	screen += "\x1b[%d;5;%dm".printf (fg?48:38, k);
	//screen += "\x1b[%d;m".printf (33);
}

private static void rst() {
	screen += "\x1b[0m";
}

private void wsz(out int w, out int h) {
	if (size != 0) {
		w = size;
		h = size;
	} else {
		winsize win;
		ioctl (1, Termios.TIOCGWINSZ, out win);
		w = win.ws_col;
		h = win.ws_row-1;
	}
}

int main(string[] args) {
	files = {""};
	const OptionEntry[] options = {
		{ "interactive", 'i', 0, OptionArg.NONE, ref interactive,
			"run in interactive mode", null },
		{ "size", 's', 0, OptionArg.INT, ref size,
			"maximum square resolution for the picture in chars", null },
		{ "width", 'w', 0, OptionArg.NONE, ref fix_width,
			"fit image in console width", null },
		{ "height", 'h', 0, OptionArg.NONE, ref fix_height,
			"fit image in console height", null },
		{ "brightness", 'b', 0, OptionArg.INT, ref brightness,
			"-255 - 255 value to brightness (default 0)", null },
		{ "greyscale", 'g', 0, OptionArg.NONE, ref greyscale,
			"render image using greyscale ansi256", null },
		{ "ansi16", 'a', 0, OptionArg.NONE, ref dither16,
			"render using ansi16 escape codes", null },
		{ "no-color", 'n', 0, OptionArg.NONE, ref asciiart,
			"render using just text, no escape codes", null },
		{ "gotoxy00", '0', 0, OptionArg.NONE, ref gotoxy00,
			"gotoxy 0,0", null },
		{ "clear", 'c', 0, OptionArg.NONE, ref clearscr,
			"clear screen", null },
		{ "", '\0', 0, OptionArg.FILENAME_ARRAY, ref files, "image to load", "FILE FILE .." },
		{ null }
	}; 
	if (args.length<2) {
		stderr.printf ("Usage: timg [file.jpg]\n");
		return 1;
	}
	try {
		var opt = new OptionContext("timg");
		opt.set_help_enabled(true);
		opt.add_main_entries(options, null);
		opt.parse(ref args);
	} catch (GLib.Error e) {
		stderr.printf("Error: %s\n", e.message);
		stderr.printf("Run '%s --help' to see a full list of available "+
				"options\n", args[0]);
		return 1;
	} 
	if (files[0] == "") {
		stderr.printf ("Missing argument\n");
		return 1;
	}
	string file = files[0];
	screen = "";
	int tw, th;
	wsz (out tw, out th);
	try {
		// TODO: add support for GIF
		var p = new Gdk.Pixbuf.from_file (file);
		int w = p.get_width ();
		int h = p.get_height ();

		int columns = 80;
		int rows = 60;

		if (!fix_width && !fix_height) {
			fix_height = true; // defaults
		}
		if (fix_width) {
			columns = rows = tw;
		}
		if (fix_height) {
			columns = rows = th*2;
		}
		if (columns <2) columns = 80;
		if (w>h) {
			double ratio = w/h;
			h = columns;
			w = (int)((double)h*1.5*ratio);
		} else 
		if (h>w) {
			double ratio = h/w;
			w = columns;
			h = (int)((double)w*1.5*ratio);
		} else {
			w = h = columns;
		}
		p = p.scale_simple (w, h, InterpType.BILINEAR);
		weak uint8[] pixels = p.get_pixels ();
/*
		stdout.printf ("rowstride : %d\n", p.get_rowstride ());
		stdout.printf ("width : %d\n", p.get_width ());
		stdout.printf ("bps : %d\n", p.get_bits_per_sample ());
		stdout.printf ("chans : %d\n", p.get_n_channels ());
		var cs = p.get_colorspace (); // only RGB wtf
*/

		int chans = p.get_n_channels ();
		int stride = p.get_rowstride ();
		do {
			clrscr ();
			for (int y = 0; y<h; y+=2) {
				int _ = y * stride;
				int _2 = (y+1) * stride;
				for (int i=0; i<w; i++) {
					int r = pixels[(i*chans)+_];
					int g = pixels[(i*chans)+_+1];
					int b = pixels[(i*chans)+_+2];
					if (brightness != 0) {
						r += brightness;
						g += brightness;
						b += brightness;
						if (r<0) r = 0; if (r>255) r= 255;
						if (g<0) g = 0; if (g>255) g= 255;
						if (b<0) b = 0; if (b>255) b= 255;
					}
					if (asciiart) {
						string pal = " `.-:+*%$#";
						float q = (r + g + b)/3;
						q /= (float) (255f/pal.length);
						int idx = (int)q;
						if (idx>=pal.length) idx = pal.length-1;
						screen += "%c".printf (pal.get(idx));
						continue;
					}
					int p_r, p_g, p_b;
					int n_r, n_g, n_b;
					if (i>0) {
						p_r = pixels[((i-1)*chans)+_];
						p_g = pixels[((i-1)*chans)+_+1];
						p_b = pixels[((i-1)*chans)+_+2];
					} else {
						p_r = p_g = p_b = 0;
					}
					if (i+1<w) {
						n_r = pixels[((1+i)*chans)+_];
						n_g = pixels[((1+i)*chans)+_+1];
						n_b = pixels[((1+i)*chans)+_+2];
					} else {
						n_r = n_g = n_b = 0;
					}
					if (brightness != 0) {
						n_r += brightness;
						n_g += brightness;
						n_b += brightness;
						if (n_r<0) r = 0; if (n_r>255) n_r= 255;
						if (n_g<0) g = 0; if (n_g>255) n_g= 255;
						if (n_b<0) b = 0; if (n_b>255) n_b= 255;
						p_r += brightness;
						p_g += brightness;
						p_b += brightness;
						if (p_r<0) r = 0; if (p_r>255) p_r= 255;
						if (p_g<0) g = 0; if (p_g>255) p_g= 255;
						if (p_b<0) b = 0; if (p_b>255) p_b= 255;
					}
					n_r /= 32; n_g /= 32; n_b /= 32;
					p_r /= 32; p_g /= 32; p_b /= 32;
					if (y+1==h) {
						rgb (false, r, g, b);
						rgb (true, r, g, b);
						screen += ".";
					} else {
						int r2 = pixels[(i*chans)+_2];
						int g2 = pixels[(i*chans)+_2+1];
						int b2 = pixels[(i*chans)+_2+2];
						rgb (false, r2, g2, b2);
						rgb (true, r-20, g-20, b-20);
						/*
						   p x n
						     2
						*/
						r/=32; g/=32; b/=32;
						r2/=32; g2/=32; b2/=32;
							string ch = ".";
							if (p_r == r2 && p_g == g2 && p_b == b2 && (r != p_r && g != p_g && b != p_b )) {
								ch = "\\";
							} else if ((r==r2 && g==g2 && b==b2) && (p_r != r && n_r != r)) {
								ch = "|";
							} else if (r2 == n_r && g2 == n_g && b2 == n_b) {
								if (r==r2 && g==g2 && b==b2) {
									if (asciiart) ch = " ";
									else ch = "\"";
								} else ch = "/";
							} else if (p_r == n_r && p_g == n_g && p_b == n_b) {
								ch = (p_r == r && p_g == g && p_b == b)? "_": "=";
							} else {
								ch = (p_r == r2)? "*": ".";
							}
							screen += ch;
					}
				}
				newln();
				rst();
				flush ();
			}
		} while (false);
	} catch (Error e) {
		stderr.printf ("failed\n");
		return 1;
	}
	return 0;
}
