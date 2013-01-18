---
layout: post
title: JSON.framework v2.2.3 is out!
---

This is a minor bugfix release. It can be downloaded from <a href="http://json-framework.googlecode.com">its website</a>. The main issues fixed are:

* **Added -all_load to libjsontests linker flag.** <br />
This allows the tests to run with more recent versions of GCC.
* **Fix -proxyForJson method for first-level objects.**<br />
Allow the -proxyForJson method to be called for first-level proxy objects, in addition to objects that are embedded in other objects. Reported in issues 54 &amp; 60.

