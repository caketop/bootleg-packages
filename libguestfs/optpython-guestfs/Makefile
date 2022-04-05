PYTHON_RELEASE = @PYTHON_RELEASE@
GUESTFS_VERSION = @GUESTFS_VERSION@

all:
	echo "noop: all"

install:
	mkdir -p $(DESTDIR)
	tar -xzvf guestfs-$(GUESTFS_VERSION).tar.gz
	cd guestfs-$(GUESTFS_VERSION) && env CC=gcc-11 CFLAGS=-g python3 -m pip wheel .
	python3 -m pip install --root $(DESTDIR) guestfs-$(GUESTFS_VERSION)/*.whl

clean:
	echo "noop: clean"

distclean:
	echo "noop: distclean"

.PHONY: all install clean distclean
