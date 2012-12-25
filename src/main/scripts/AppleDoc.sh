#!/bin/sh

VERS=3.2

appledoc \
--project-name "SBJson" \
--project-company "Stig Brautaset" \
--company-id "org.brautaset" \
--docset-atom-filename "SBJson.atom" \
--docset-feed-url "http://sbjson.org/api/$VERS/%DOCSETATOMFILENAME" \
--docset-package-url "http://sbjson.org/api/$VERS/%DOCSETPACKAGEFILENAME" \
--docset-fallback-url "http://sbjson.org/api/$VERS/" \
--output "../json-framework-pages/api/$VERS/" \
--publish-docset \
--logformat xcode \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--ignore "*.m" \
--index-desc "README.md" \
Classes
