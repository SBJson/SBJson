---
layout: post
title: JSON Framework 2.1
---

<img src="http://skuggdev.files.wordpress.com/2008/08/json211.png" alt="JSON2.1.png" border="0" width="371" height="144" align="right" />
I just uploaded <a href="http://json-framework.googlecode.com/files/JSON_2.1.dmg">JSON framework version 2.1</a> to Google Code. Changes since the 2.0 series, big and small, include:

**iPhone-ready SDK**<br/>
The disk image now contains a Custom SDK. This makes the framework a lot easier to use on the iPhone. See the INSTALL file in the dmg for details.

**New sortKeys option**<br/>
This makes the generator produce objects with the keys in sorted order. This is very handy when you need to compare JSON documents.

**Leopard only**<br/>
From version 2.1 onwards this framework is Leopard-only. Stick with version 2.0 if you need Tiger support. Some of the Objective-C 2.0 features are just <em>too shiny</em> to pass up for long. Some of the changes related to this:

* **64 bit support**<br/>
The JSON framework now supports 64 bit. Moved to use the 10.5 64-bit compatibility typedefs for basic types.
* **Garbage collection support**<br/>
The framework is now built with garbage collection support by default.
* **Syntesized properties**<br/>
Killed some redundant code by moving to use synthesised properties.
* **Fast iteration loops**<br/>
Update the code to use Objective-C 2.0 fast iteration loops in a couple of places.

**Removed deprecated methods**<br/>
Removed the option-taking category methods, as promised in v2.0. Rewrote some tests to use the underlying object instead.

**New error code**<br/>
Introduced a new error code for clarity: EEOF - premature end of input.

**Documentation target**<br/>
Added a documentation target to integrate the documentation into Xcode automatically.
