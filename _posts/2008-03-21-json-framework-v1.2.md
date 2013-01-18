---
layout: post
title: JSON Framework v1.2
---
A couple days ago I released a new version of my JSON framework for Objective-C. This release saw the parser being completely rewritten to be a lot cleaner and about 10–20% faster at decoding short inputs. (Long inputs stay about the same.) This also fixed a bizarre bug, reported by David Zhao, where strings would not always be decoded properly.

I also applied a couple of patches from Greg Bolsinga. One to make the framework no longer depend on AppKit, thus really making it a Foundation framework rather than Cocoa framework, and one that adds another target to create a static library for use on the iPhone. (You will have to build this from source yourself, at the time being.)
