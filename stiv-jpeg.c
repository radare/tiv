/* tiv - terminal image viewer - copyleft 2013 - pancake */

#include <stdio.h>
#include <string.h>
#include <jpeglib.h>

#define MAIN
#include "stiv.c"

int
main(int argc, const char **argv) {
	unsigned char *p1, *buf;
	unsigned char **p2 = &p1;
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	int counter, width, stride;
	JSAMPARRAY buffer;
	int numlines;
	FILE *fd;
	if (argc<2) {
		printf ("stiv-jpeg . suckless terminal image viewer\n"
				"Usage: stiv [image] [width] [mode]\n");
		return 1;
	}
	selectrenderer (argc>3?argv[3]:"");
	fd = fopen (argv[1], "rb");
	if (!fd) {
		fprintf (stderr, "Cannot open '%s'\n", argv[1]);
		return 1;
	}
	width = (argc<3)? 78: atoi (argv[2]);
	memset (&cinfo, 0, sizeof (cinfo));
	cinfo.err = jpeg_std_error (&jerr);
	jpeg_create_decompress (&cinfo);

	//jpeg_set_colorspace (&cinfo, JCS_RGB);
	jpeg_stdio_src (&cinfo, fd);
	jpeg_read_header (&cinfo, TRUE);

	// scale image works fine here
	cinfo.scale_num = width;
	cinfo.scale_denom = cinfo.image_width;
	width = ( width * cinfo.scale_num ) / cinfo.scale_denom;

	jpeg_start_decompress (&cinfo);

	stride = cinfo.output_width * cinfo.output_components;
	if (cinfo.output_components != 3) {
		printf ("Not in rgb24\n");
		return 1;
	}
	//fprintf (stderr, "%d %d\n", cinfo.output_width, cinfo.output_height);

	counter = 0;
	stride = cinfo.output_width * 3;
	p1 = malloc (stride);
	buf = malloc (stride * cinfo.output_height);
	p2 = &p1;
	while (cinfo.output_scanline < cinfo.output_height) {
		*p2 = p1;
		numlines = jpeg_read_scanlines (&cinfo, p2, 1);
#if STANDALONE
		write (1, p1, cinfo.output_width*3);
#else
		memcpy (buf+counter, p1, cinfo.output_width* 3);
#endif
		counter += stride;
	}
	dorender (buf, stride*cinfo.output_height,
			cinfo.output_width, cinfo.output_height);
	jpeg_finish_decompress (&cinfo);
	jpeg_destroy_decompress (&cinfo);

	free (buf);
	fclose (fd);
	return 0;
}
