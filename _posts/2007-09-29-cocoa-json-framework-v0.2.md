---
layout: post
title: Cocoa JSON Framework v0.2---now with pretty-printing!
---

You can now produce human-readable JSON! There is a new method that takes options to control the formatting.

The public methods were renamed to jive better with existing Cocoa conventions. The affected methods are as follows:

<ul>
    <li>-JSONString             was renamed -JSONRepresentation</li>
    <li>-JSONStringFragment     was renamed -JSONFragment</li>
    <li>-objectFromJSON         was renamed -JSONValue</li>
    <li>-objectFromJSONFragment was renamed -JSONFragmentValue</li>
</ul>

See the <a href="http://code.brautaset.org/JSON/">website</a> for up-to-date documentation.

<strong>I released <a href="http://skuggdev.wordpress.com/2007/10/17/cocoa-json-framework-v1/">version 1</a> a little while ago.</strong>
