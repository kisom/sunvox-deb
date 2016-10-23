VERSION :=	1.9.1
ZIPFILE :=	sunvox-$(VERSION).zip

UPSTREAM :=	http://warmplace.ru/soft/sunvox/$(ZIPFILE)
PACKAGE :=	pkg
UPSTREAM_IMG :=	http://warmplace.ru/soft/sunvox/disk.png

PKGBASE :=	pkg/usr
PKGDOC :=	$(PKGBASE)/share/doc/sunvox
PKGDATA :=	$(PKGBASE)/share/sunvox
PKGBIN :=	$(PKGBASE)/bin/sunvox
PKGFILE :=	sunvox-$(VERSION).deb

.PHONY: all
all: $(PKGDOC) $(PKGDATA) $(PKGBIN) $(PKGFILE)

print-%: ; @echo $*=$($*)

$(ZIPFILE):
	curl -LO $(UPSTREAM)

sunvox: $(ZIPFILE)
	[ ! -d "$@" ] && unzip $(ZIPFILE) || true

pkg: sunvox
	mkdir -p "$@"

disk.png:
	curl -LO $(UPSTREAM_IMG)

$(PKGDOC): pkg
	mkdir -p "$@"
	cp -r sunvox/docs/* $(PKGDOC)/

$(PKGDATA): pkg
	mkdir -p "$@"
	cp -r sunvox/examples $@/
	cp -r sunvox/instruments $@/
	cp disk.pnf $@/sunvox.png

$(PKGBIN): pkg
	mkdir -p $(dir $(PKGBIN))
	cp sunvox/sunvox/linux_x86_64/sunvox $@

$(PKGFILE): $(PKGDOC) $(PKGDATA) $(PKGBIN)
	fpm -s dir -t deb -C pkg -p $(PKGFILE) -n sunvox -v $(VERSION) \
		--license closed \
		--vendor "Alexander Zolotov <nightradio@gmail.com>" \
		--category audio -a amd64 -m "Kyle Isom <kyle@imap.cc>" \
		--description "A small, fast and powerful modular synthesizer with pattern-based sequencer (tracker)." \
		--url "http://warmplace.ru/s$(PKGFILE)oft/sunvox/" .
		

.PHONY: clean distclean
clean:
	rm -rf sunvox pkg $(PKGFILE) disk.png

distclean: clean
	rm -rf $(ZIPFILE)
