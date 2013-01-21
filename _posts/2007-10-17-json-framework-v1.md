---
layout: post
title: Cocoa JSON Framework v1!
---

This is an important bugfix release. I bumped the version all the way to the big 1-dot-oh since it now handles all the JSON checker tests correctly. Specifically, the bugs fixed since version 0.2 are:

* Unicode control characters, that is code points below 0×20, are now always escaped.
Earlier only the ones with special two-character shortcuts were.
* We now correctly throw an exception if any JSON strings contains unescaped control chars. Trailing garbage—extra characters after a JSON payload—is now not allowed.
* It turned out I was a little too lenient when parsing numbers. Strict JSON does not allow leading zeros (i.e. ’012′), leading plus signs (i.e. ‘+10′), or omission of digits after the exponent (i.e. ’0e’ and ’0e+’). This error has now been fixed.

This project has its own web site at http://code.brautaset.org/JSON/.
