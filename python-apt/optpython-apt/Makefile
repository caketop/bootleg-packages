PYTHON_RELEASE = @PYTHON_RELEASE@
PYTHON_APT_VERSION = @PYTHON_APT_VERSION@

all:
	echo "noop: all"

install:
	mkdir -p $(DESTDIR)
	env CC=gcc-11 CFLAGS=-g python3 -m pip wheel git+https://salsa.debian.org/apt-team/python-apt.git@$(PYTHON_APT_VERSION)
	python3 -m pip install --root $(DESTDIR) *.whl

clean:
	echo "noop: clean"

distclean:
	echo "noop: distclean"

.PHONY: all install clean distclean
