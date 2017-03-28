#@maintainer kang@mozilla.com
#@update 2017-03-28

# Required RPM packaes:
# fpm
# rpm-build
# mono-devel
# nodejs

#If you change the PKGVER ensure the module list in npm_modules.sha256sum is accurate

#This is the ad-ldap-connector version
PKGVER:= 3.6.0-mozilla
#This is the packaging sub-release version
PKGREL:= 1
PKGNAME:=ad-ldap-connector
PKGPATH:=https://github.com/gdestuynder/ad-ldap-connector/archive/
PKGSHA256:=ec83c07bf880ecd56d45247ad385f404ca2a29f21dcf1c04721fcb8150bb5c27
NPMS=npm_modules.sha256sum

PKGTARBALL:=v$(PKGVER).tar.gz
PKGDIRNAME:=$(PKGNAME)-$(PKGVER)

#Required for the fancy checksumming
#with GNU Make we'd reach foreach's and patterns limits
SHELL:=/bin/bash

all: fpm

fpm: extract npm_verify
	#Creating package
	mkdir -p target/opt
	cp -vr $(PKGDIRNAME) target/opt/$(PKGNAME)
	mkdir -p target/usr/lib/systemd/system
	cp -v $(PKGNAME).service target/usr/lib/systemd/system
	cp -v environ target/opt/$(PKGNAME)/
	fpm -s dir -t rpm \
		--rpm-user $(PKGNAME) --rpm-group $(PKGNAME) \
		--rpm-digest sha256 \
		--before-install pre-install.sh \
		--config-files opt/$(PKGNAME)/environ \
		--iteration $(PKGREL) \
		--exclude opt/$(PKGNAME)/$(PKGNAME)-$(PKGVER) \
		-n $(PKGNAME) -v $(PKGVER) -C target

npm_download: extract
	@cd $(PKGDIRNAME) && npm i --production

npm_verify: npm_download
	cat $(NPMS) | sha256sum -c

regenerate_sums: $(PKGTARBALL)
	@echo Generating NEW checksums...
	find $(PKGDIRNAME)/node_modules/ -type f -exec sha256sum {} \; > npm_modules.sha256sum

extract: $(PKGDIRNAME)
$(PKGDIRNAME): verify
	tar xvzf $(PKGTARBALL)

download: $(PKGTARBALL)
$(PKGTARBALL):
	@echo Getting package release $(PKGVER)...
	curl -# -L -O $(PKGPATH)/$(PKGTARBALL)

verify: $(PKGTARBALL)
	@echo Verifying tarball checksum...
	echo "$(PKGSHA256) $(PKGTARBALL)" | sha256sum -c

.PHONY: clean verify download extract npm_verify npm_download
clean:
	-rm $(PKGTARBALL)
	-rm -r $(PKGDIRNAME)
	-rm -r target
	-rm *.rpm
