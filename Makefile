.PHONY : doc build clean dist

pre_build:
	git rev-parse HEAD > .git-ref
	mkdir -p build/src
	mkdir -p build/demo/kitchen-sink
	mkdir -p build/textarea/src
	
	cp -r demo/kitchen-sink/styles.css build/demo/kitchen-sink/styles.css
	cp demo/kitchen-sink/logo.png build/demo/kitchen-sink/logo.png
	cp -r doc/site/images build/textarea

build: pre_build
	./Makefile.dryice.js normal
	./Makefile.dryice.js demo

# Minimal build: call Makefile.dryice.js only if our sources changed
basic: build/src/ace.js

build/src/ace.js : ${wildcard lib/*} \
                   ${wildcard lib/*/*} \
                   ${wildcard lib/*/*/*} \
                   ${wildcard lib/*/*/*/*} \
                   ${wildcard lib/*/*/*/*/*} \
                   ${wildcard lib/*/*/*/*/*/*}
	./Makefile.dryice.js

doc:
	cd doc;\
	(test -d node_modules && npm update) || npm install;\
	node build.js

clean:
	rm -rf build
	rm -rf ace-*
	rm -f ace-*.tgz

ace.tgz: build
	mv build ace-`./version.js`/
	cp Readme.md ace-`./version.js`/
	cp LICENSE ace-`./version.js`/
	tar cvfz ace-`./version.js`.tgz ace-`./version.js`/

SHA=$(shell git rev-parse HEAD)
VERSION=$(shell ./version.js)
RELEASE=$(VERSION)-$(SHA)
TAR=builds/$(RELEASE).tar.gz

package_url:
	@echo $(HUDSON_URL)artifacts/ace/$(BRANCH_NAME)/$(BUILD_ID)/$(TAR)

minimal: build/loose_files
build/loose_files:
	mkdir -p build/
	echo $(RELEASE) > build/.release
	cp build_support/package.json build/
	cp LICENSE build/

minimal: build/src-noconflict
build/src-noconflict:
	./Makefile.dryice.js --nc

minimal: build/src-min-noconflict
build/src-min-noconflict:
	./Makefile.dryice.js -m --nc

archive: $(TAR)
$(TAR):
	mkdir -p builds/
	tar --create build/ | gzip -9 > $@

clean_builds:
	rm -rf builds/

clean_ci:
	rm -rf build/ builds/ node_modules/

dist: clean build ace.tgz
