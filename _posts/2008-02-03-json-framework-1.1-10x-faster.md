---
layout: post
title: JSON Framework 1.1 now 10x faster!
---

[Jens Alfke](http://mooseyard.com/Jens) emailed me out of the blue with a couple of patches to <a href="http://code.brautaset.org/JSON/%23performance">seriously boost performance</a> both for parsing and generation. This framework is now a lot faster than BSJSONAdditions for all the four scenarios I tested: both encoding &amp; decoding of short &amp; long (~12k) strings.

Another new thing in this release is that the downloadable embedded framework is now compiled for both ppc and x86 platforms.

This is the first project where I've received patches that substantially improve the project. Does that mean it's time to set up a Google code project?
