---
layout: default
title: JSON Framework 2.1
---

<img src="http://skuggdev.files.wordpress.com/2008/08/json211.png" alt="JSON2.1.png" border="0" width="371" height="144" align="right" />I just uploaded <a href="http://json-framework.googlecode.com/files/JSON_2.1.dmg">JSON framework version 2.1</a> to Google Code. Changes since the 2.0 series, big and small, include:

<strong>iPhone-ready SDK</strong><br>
The disk image now contains a Custom SDK. This makes the framework a lot easier to use on the iPhone. See the INSTALL file in the dmg for details.

<strong>New sortKeys option</strong><br>
This makes the generator produce objects with the keys in sorted order. This is very handy when you need to compare JSON documents.

<strong>Leopard only</strong><br>
From version 2.1 onwards this framework is Leopard-only. Stick with version 2.0 if you need Tiger support. Some of the Objective-C 2.0 features are just <em>too shiny</em> to pass up for long. Some of the changes related to this:

<ul>
<li><strong>64 bit support</strong><br>
The JSON framework now supports 64 bit. Moved to use the 10.5 64-bit compatibility typedefs for basic types.

</li><li><strong>Garbage collection support</strong><br>
The framework is now built with garbage collection support by default.

</li><li><strong>Syntesized properties</strong><br>
Killed some redundant code by moving to use synthesised properties.

</li><li><strong>Fast iteration loops</strong><br>
Update the code to use Objective-C 2.0 fast iteration loops in a couple of places.
</li></ul>

<strong>Removed deprecated methods</strong><br>
Removed the option-taking category methods, as promised in v2.0. Rewrote some tests to use the underlying object instead.

<strong>New error code</strong><br>
Introduced a new error code for clarity: EEOF - premature end of input.

<strong>Documentation target</strong><br>
Added a documentation target to integrate the documentation into Xcode automatically.
