---
title: JSON framework v2.3 released!
layout: post
---

### Links

* Download the [source and documentation][dmg] distribution.
* Read the [online API documentation][api].
* Browse [the source][git].

[dmg]: http://code.google.com/p/json-framework/downloads/list
[api]: http://stig.github.com/json-framework/api/
[git]: http://github.com/stig/json-framework

---

### Changes

* **Parsing performance improvements.**
Issue 56. Dewvinci & Tobias Hoehman came up with a patch to improve parsing of short JSON texts with lots of numbers by over 60%.
* **Refactored tests to be more data-driven.**
This should make the source leaner and easier to maintain.
* **Removed problematic SDK**
Issue 33, 58, 63, and 64--to name a few. The vast majority of the issues people are having with this framework were related to the somewhat mystical Custom SDK. This has been removed in this version.
* **Removed the deprecated SBJSON facade**
Issue 71. You should use the SBJsonParser or SBJsonWriter classes, or the category methods, instead. This also let us remove the SBJsonParser and SBJsonWriter categories; these were only there to support the facade, but made the code less transparent.
* **Removed the deprecated fragment support**
Issue 70. Fragments were a bad idea from the start, but deceptively useful while writing the framework's test suite. This has now been rectified.

### Bug Fixes

* Issue 38: Fixed header-inclusion issue.
* Issue 74: Fix bug in handling of Infinity, -Infinity & NaN.
* Issue 68: Fixed documentation bug.
