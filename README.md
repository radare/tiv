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
$ tiv -d foo.img > foo.bitmap 2> foo.resolution
$ tiv `cat foo.resolution` < foo.bitmap
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
```
$ ./tiv  --help
Usage:
  tiv [OPTION...] FILE FILE .. timg

Help Options:
  -?, --help            Show help options

Application Options:
  -i, --interactive     run in interactive mode
  -s, --size            maximum square resolution for the picture in chars
  -w, --width           fit image in console width
  -h, --height          fit image in console height
  -b, --brightness      -255 - 255 value to brightness (default 0)
  -g, --grayscale       render image using grayscale ansi256
  -a, --ansi16          render using ansi16 escape codes
  -n, --no-color        render using just text, no escape codes
  -0, --gotoxy00        gotoxy 0,0
  -c, --clear           clear screen
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
