NAME=JSON
VERSION=0.2

RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg

UP=stig@brautaset.org:code/$(NAME)/files/
DMGURL=http://code.brautaset.org/$(NAME)/files/$(DMG)

site: Site/style.css Site/index.html Site/news.xml
	rm -rf _site; cp -r Site _site
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' _site/*.html
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' _site/*.html

upload-site: site
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" 
	rsync -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(NAME)/

dist: site
	chmod -R +w dmg; rm -rf dmg $(DMG)
	setCFBundleVersion.pl $(VERSION) JSON-Info.plist
	xcodebuild -target $(NAME) clean
	xcodebuild -target Tests
	xcodebuild -target $(NAME) install
	mkdir dmg
	mv /tmp/Frameworks/$(NAME).framework dmg
	rm _site/news.xml
	cp -r _site dmg/Documentation
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder dmg $(DMG)

upload-dist: dist
	curl --head $(DMGURL) 2>/dev/null | grep -q "404 Not Found" || false
	scp $(DMG) $(UP)

