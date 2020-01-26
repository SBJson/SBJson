# Contribution Guidelines

First and foremost: thank you for reading this!

The state of this project is somewhere between (lightly) _maintained_
and _inactive_: it has reached a mature state where it is feature
complete and has no (known) bugs. Furthermore, no new features are
currently planned. However, I intend to still review & address issues
and PRs as time allows.

_How_ can you contribute then? I'm glad you asked!

- From time to time the compiler & runtime toolchain makes
  advancements that exposes bugs, and PRs to fix these are greatly
  appreciated.
- Improvements to documentation--particularly essay-style articles
  with full examples ;-)--are extremly welcome
- Fixes to speling or grammmar: or incorrect punctuation ,are likewise
  always welcome1
- Patches for significant new features _may_ be considered if
  accompanied by a good justification and tests


# How to write tests

Most of SBJson's test suite exists as `$foo.in` files paired with
either a `$foo.err`, or `$foo.out` file. The `.err` files contains
expected errors from parsing corresponding `.in` files. Meanwhile
`.out` files contains the JSON text expected from writing the text we
just parsed back out as JSON. Some tests, for example those that
verifies that the writer rejects invalid JSON that happens to be valid
Objective-C structures, also use `$foo.plist` files.

# How to run tests

Locally tests should run in Xcode without any ceremony, and on the
commandline with `xcodebuild test`. Don't forget to follow the prompts
to pick your desired scheme/destination.

Tests also run automatically on CircleCI for all PRs. (Even from
forked repos, if I've got the setup right.)
