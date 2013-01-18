---
layout: post
title: JSON Framework v2.3.1 released!
---

Some fairly minor changes, but hopefully it fixes some of the most important usability issues people were having.

**Changes**

* Move to host releases on Github rather than Google code.
* Renamed .md files to .markdown.
* Removed bench target--use [Sam Soffes's benchmarks][json-benchmark] instead.
* Releases are no longer a munged form of the source tree, but identical to the tagged source.

[json-benchmark]: http://github.com/samsoffes/json-benchmark

**Bug fixes**

* [Issue 2][issue#2]: Linkage not supported by default distribution.
* [Issue 4][issue#4]: Writer reported to occasionally fail infinity check.
* [Issue 8][issue#8]: Installation.markdown refers to missing JSON folder.

[issue#2]: http://github.com/stig/json-framework/issues/closed/#issue/2
[issue#4]: http://github.com/stig/json-framework/issues/closed/#issue/4
[issue#8]: http://github.com/stig/json-framework/issues/closed/#issue/8
