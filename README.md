tiv: the terminal image viewer
==============================

Tiv implements its own rendering algorithms to display pictures loaded with the
Gdk library to the terminal using ascii art and ansi256 in color and grayscale.

This program has been written for fun, the code is ugly but it will be cleaned
up and refactorized into a library probably in the future.

kodim* images under the img/ directory are 24bit test images from kodak and are
freely available for unrestricted here: http://r0k.us/graphics/kodak/

stiv
====

Stiv is the suckless reimplementation in plain C, bitmaps should be provided in
rgb24 form and width/height are passed as arguments:

```
$ tiv -d foo.img > .bitmap 2> .size
$ stiv `cat .size` < .bitmap
```

Author
------

This program has been released on Jan 2013 by pancake
Contact addresses are: @trufae and pancake@nopcode.org

Supported terminals
-------------------
```
              ascii    ansi    grey   256
iTerm2          x       x       x      x
OSX Terminal    x       x       -      -
xterm           x       x       x      x
st              x       x       x      x

```

Usage
-----
Using the Vala implementation:
```
$ ./tiv -s 40 -t img/kodim15.jpg
```

Using the suckless C implementation:
```
$ ./stiv-jpeg
stiv-jpeg . suckless terminal image viewer
Usage: stiv [image] [width] [mode]
Modes: [ascii,ansi,grey,256,rgb]

$ ./stiv-jpeg img/kodim15.jpg 50
```

Example
-------

original picture

![original](https://github.com/radare/tiv/blob/master/img/kodim23.jpg?raw=true)

ascii

![ascii](https://github.com/radare/tiv/blob/master/test/img/ascii.png?raw=true)

ansi

![ansi](https://github.com/radare/tiv/blob/master/test/img/ansi.png?raw=true)

grey

![grey](https://github.com/radare/tiv/blob/master/test/img/grey.png?raw=true)

256

![256](https://github.com/radare/tiv/blob/master/test/img/256.png?raw=true)
