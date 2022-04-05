PYTHON_RELEASE = @PYTHON_RELEASE@
PYGOBJECT_VERSION = @PYGOBJECT_VERSION@

all:
	echo "noop: all"

install:
	mkdir -p $(DESTDIR)
	env CC=gcc-11 CFLAGS=-g PYGOBJECT_WITHOUT_PYCAIRO=True python3 -m pip wheel PyGObject==$(PYGOBJECT_VERSION)
	python3 -m pip install --root $(DESTDIR) PyGObject*.whl

clean:
	echo "noop: clean"

distclean:
	echo "noop: distclean"

.PHONY: all install clean distclean
