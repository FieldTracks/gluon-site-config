# GLUON-RELEASE to use
# Hardcoded for addtional packages  - see below
#ifndef GLUON_RELEASE
#	GLUON_RELEASE:=v2018.2
#endif

#What targets to use?
ifndef TARGETS
	TARGETS:=ar71xx-generic
endif


###
### Nothing to be changed from here
###

world: dist

# Create all distribution artifacts in ./dist
dist: $(addprefix dist/,$(TARGETS))
	mv $(PWD)/gluon/output/packages $(PWD)/dist
	find $(PWD)/dist -type f -print0  | xargs -0 sha512sum > $(PWD)/dist/sha512sums

# Log Build
init: gluon/Makefile
	mkdir -p  $(PWD)/dist
	date > $(PWD)/dist/log.txt
	@echo "GLUON_RELEASE: $(GLUON_RELEASE)" >> $(PWD)/dist/log.txt
	@echo "REPOSITORY_PREFIX: $(REPOSITORY_PREFIX)" >> $(PWD)/dist/log.txt
	@echo "SITE_BRANCH: $(SITE_BRANCH)" >> $(PWD)/dist/log.txt
	@echo "Gluon git status" >> $(PWD)/dist/log.txt
	cd gluon; git branch -v >> $(PWD)/dist/log.txt

.PHONY: dist/% init clean clean-% dist world
# Create a distribution for a certain gluon
dist/%: init
	cp -a site/* $(PWD)/gluon/site/
	envsubst < site/site.conf > $(PWD)/gluon/site/site.conf
	make -C gluon update GLUON_DEPRECATED=1

	echo "Building Target: $*" >> $(PWD)/dist/out.txt
	echo "Building Target: $*" >> $(PWD)/dist/err.txt

	mkdir -p $(PWD)/dist/
	rm -rf $(PWD)/dist/*
	make -j2 -C gluon all GLUON_DEPRECATED=1 GLUON_TARGET=$* V=99 2>> $(PWD)/dist/err.txt >> $(PWD)/dist/out.txt
	rsync -Hav $(PWD)/gluon/output/images/ $(PWD)/dist/

	#make -j2 -C gluon clean GLUON_TARGET=$* GLUON_DEPRECATED=1

gluon/Makefile:
	#git clone https://github.com/freifunk-gluon/gluon.git -b $(GLUON_RELEASE)
	git clone https://github.com/yanosz/gluon.git -b master+wifi_encrypt
	mkdir -p $(PWD)/gluon/site/i18n

clean:
	rm -Rf dist
