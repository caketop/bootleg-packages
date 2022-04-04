PYTHON_RELEASE = @PYTHON_RELEASE@

all:
	echo "noop: all"

install:
	mkdir -p $(DESTDIR)/opt
	cp -r /opt/python-$(PYTHON_RELEASE) $(DESTDIR)/opt/python-$(PYTHON_RELEASE)

clean:
	echo "noop: clean"

distclean:
	echo "noop: distclean"

uninstall:
	rm -rf $(DESTDIR)/opt/python-$(PYTHON_RELEASE)

.PHONY: all install clean distclean uninstall
