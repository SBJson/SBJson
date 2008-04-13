NAME=JSON
VERSION=$(strip $(shell /Developer/Tools/agvtool vers -terse))

FRAMEWORK=/tmp/Frameworks/$(NAME).framework
RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg
DMGURL=http://code.brautaset.org/$(NAME)/files/$(DMG)


enclosure: $(DMG)
	@echo    "<item>"
	@echo 	 "    <title>$(NAME) $(VERSION)</title>"
	@echo 	 "    <description><![CDATA["
	@echo 	 "    ]]></description>"
	@echo    "    <pubDate>`date +"%a, %b %e %Y %H:%M:%S %Z"`</pubDate>"
	@echo    "    <enclosure url='$(DMGURL)' "
	@echo -n "        length='`stat $(DMG) | cut -d" "  -f8`'"
	@echo    ' type="application/octet-stream"/>'
	@echo 	 "</item>"

_site: Site/* Makefile
	rm -rf _site; cp -r Site _site
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' _site/*.*
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' _site/*.*

site: _site

upload-site: _site
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" 
	rsync -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(NAME)/

$(FRAMEWORK): Source/* 
	-chmod -R +w /tmp/Frameworks ; rm -rf /tmp/Frameworks
	-chmod -R +w /tmp/$(NAME).dst ; rm -rf /tmp/$(NAME).dst
	xcodebuild -target $(NAME) clean install

install: $(FRAMEWORK)

$(DMG): $(FRAMEWORK)
	-rm -f $(DMG)
	-chmod -R +w _dmg ; rm -rf _dmg ; mkdir _dmg
	cp -R /tmp/Frameworks/$(NAME).framework _dmg
	cp -R _site _dmg/Documentation
	rm _dmg/Documentation/news.xml
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder _dmg $(DMG)

dmg: $(DMG)

upload-dmg: $(DMG)
	curl --head $(DMGURL) 2>/dev/null | grep -q "404 Not Found" || false
	scp $(DMG) stig@brautaset.org:code/$(NAME)/files/$(DMG)

