# Project name from the X.xcodeproj directory
PROJ    = $(subst .xcodeproj,,$(wildcard *.xcodeproj))

# Marketing version
VERS    = $(strip $(shell agvtool mvers -terse1))

DIST    = $(PROJ)_$(VERS)
DMG     = $(DIST).dmg
DMGURL  = http://code.brautaset.org/$(PROJ)/files/$(DMG)
CONF    = Release

OBJPATH = /tmp/build/$(CONF)/$(PROJDIR)
LIB     = $(OBJPATH)/$(PROJ)


FWKPATH = /tmp/Frameworks/$(PROJ).framework

SITE    = $(shell find Site -type f)
SRC     = $(shell find Source -type f)

site: _site

dmg: $(DMG)

enclosure: $(DMG)
	@echo    "<item>"
	@echo    "    <title>$(NAME) $(VERSION)</title>"
	@echo    "    <description><![CDATA["
	@echo    "    ]]></description>"
	@echo    "    <pubDate>`date +"%a, %b %e %Y %H:%M:%S %Z"`</pubDate>"
	@echo    "    <enclosure url='$(DMGURL)' "
	@echo    "        length='`stat $(DMG) | cut -d" "  -f8`'"
	@echo    ' type="application/octet-stream"/>'
	@echo    "</item>"

_site: $(SITE)
	-rm -rf _site
	cp -R Site _site
	find _site -type f | xargs perl -pi -e 's{__DMGURL__}{$(DMGURL)}g'
	find _site -type f | xargs perl -pi -e 's{__VERSION__}{$(VERS)}g'

upload-site: _site
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" 
	rsync -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(PROJ)/

$(DMG): $(SRC) _site
	-rm $(DMG)
	-chmod -R +w $(DIST)    && rm -rf $(DIST)
	-chmod -R +w $(FWKPATH) && rm -rf $(FWKPATH)
	xcodebuild -configuration $(CONF) -target $(PROJ) install
	mkdir $(DIST)
	cp -p -R $(FWKPATH) $(DIST)
	cp -p -R _site $(DIST)/Documentation
	rm $(DIST)/Documentation/news.xml
	hdiutil create -fs HFS+ -volname $(DIST) -srcfolder $(DIST) $(DMG)

upload-dmg: $(DMG)
	curl --head $(DMGURL) 2>/dev/null | grep -q "404 Not Found" || false
	scp $(DMG) stig@brautaset.org:code/$(PROJ)/files/$(DMG)


