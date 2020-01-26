# 5.0.3 (TBD)

- Added [Code of Conduct](CODE_OF_CONDUCT.md), based on the
  [Contributor Covenant v2](https://www.contributor-covenant.org/).
- Change header syntax in README for easier maintenance
- Added note on backwards compatibility to README

# 5.0.3-alpha2 (January 19th, 2020)

- Removed the `SBJson5Stream{Parser,Writer}State` singletons and use
  per parser/writer instances instead.
- Properly hid the `SBJson5Stream{Parser,Writer}State` helper classes
  from the public interface.

# 5.0.3-alpha1 (January 19th, 2020)

This is the first release after migrating the Git repo from
[stig/json-framework](https://github.com/stig/json-framework) to its
new home at [SBJson/SBJson](https://github.com/SBJson/SBJson).

Changes include:

- Migrating CI from Travis to CircleCI
- Migrated Emacs Org files to Markdown for ease of contribution
- Add Carthage CI test job to avoid breaking it in the future
- Added template Cocoapods podspec
- Add Cocoapods `pod lib lint` CI step to catch problems early
- Add Cocoapods job to run `pod trunk push` for releases
- Fixed a test that broke due to filesystem traversal no longer being
  in alphabetical order
- Fixed a signedness issue in the `sbjson` cli tool
- Swapped NEWS files around so the current one has no version number
- Updated CREDITS
- Updated/automated release procedures
- Removed static NSNumber instances in the writer

# 5.0.2 (August 19th, 2019)

Fix header accessbility for macOS Target.

# 5.0.1 (July 25th, 2019)

In addition to the "headline" item, this patch release also quashes some warnings.

# 5.0.0 (November 15th, 2016)

I bet you didn't see this coming! *I* certainly didn't a month ago.

This is the second release motivated by Nicholas Seriot's [Parsing JSON is a
Minefield](http://seriot.ch/parsing_json.php) post.


## Targeting RFC 7159

This release allows scalar values at the top level; as recommended by RFC
7159, which obsoletes the original RFC 4627. Since it is a change in
behaviour I chose to bump the major version to 5.

**Please note**: When parsing numbers at the top level there is *no way* to
differentiate `42` on its own from `4200` truncated to just the first two
digits. This problem affects SBJson 5 because it expects to receive input
bit-by-bit. When SBJson 5 sees "42" on its own it returns
`SBJson5WaitingForData`, since cannot be sure it has seen the full token
yet, and needs more data to make sure. A workaround for this issue could be
to append a space or newline to your input if you intend to give SBJson 5
the whole input in one go. This is not an issue with any of the other JSON
datatypes because they are either fixed length (`true`, `false`, `null`) or
have unambigous delimiters at both ends (`[]`, `{}`, `""`).

-   <https://github.com/stig/json-framework/pull/238>
-   <https://github.com/stig/json-framework/pull/239>

## Rename all classes & public symbols

Because the class names contains the major version number a major-version
bump necessitates renaming all the classes & enums. The upshoot of this is
that you can use SBJson 3, 4 **and** 5 in the same application without
problems. (Though why you would want to I cannot even begin to guess at.)

-   <https://github.com/stig/json-framework/commit/736dbb1c3fe9dfa85e2c89a4a020479ee2a37619>

## Remove the processBlock: API

This release removes the untested `processBlock:` interface. I believe it
was a distraction from SBJson's core purpose: to parse & generate JSON.
Additionally this API had no tests, and the code had a lot of special case
hooks all over the SBJson\*Parser class to do its work.

SBJson actually has two parsers: the low-level SBJson5StreamParser and the
higher-level SBJson5Parser providing a block interface. I believe it's
better to just do what the processBlock interface did in SBJson5Parser's
value block. However, you could also use the stream parser to implement the
processBlock interface yourself.

-   <https://github.com/stig/json-framework/pull/242>

## Constructor changes for parsers + writers

Since I decided to bump the major version number anyway, I took the
opportunity to iron out some UI niggles that's been bothering me for a
while. Now we take options as constructor parameters rather than as
properties for boh the parsers and writers, to avoid the impression that
you can (and that it might make sense!) to change these settings during
parse/generation. It is absolutely not supported, and that should be more
clear now.

-   <https://github.com/stig/json-framework/pull/243>
-   <https://github.com/stig/json-framework/pull/247>

## Add a `sbjson` binary for reformatting JSON

This can be useful from a sort of *what would SBJson do?* point of view. It
takes some options. Here's the result of invoking it with `--help`:

    Usage: sbjson [OPTIONS] [FILES]

    Options:
      --help, -h
        This message.
      --verbose, -v
        Be verbose about which arguments are used
      --multi-root, -m
        Accept multiple top-level JSON inputs
      --unwrap-root, -u
        Unwrap top-level arrays
      --max-depth INT, -m INT
        Change the max recursion limit to INT (default: 32)
      --sort-keys, -s
        Sort dictionary keys in output
      --human-readable, -r
        Format the JSON output with linebreaks and indents

    If no FILES are provided, the program reads standard input.

## Run `sbjson` under American Fuzzy Lop

To try and shake out any new crashes, I've run the `sbjson` binary alluded
to above under [American Fuzzy Lop](http://lcamtuf.coredump.cx/afl/). I didn't find any more crashes in the
parser after fixing the bugs that went into v4.0.4, but wanted to share
this with you to show I *tried* to find more bugs before releasing v5.

Here's a snapshot of the latest session I've run:

                           american fuzzy lop 2.35b (master)

    ┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
    │        run time : 1 days, 12 hrs, 36 min, 22 sec     │  cycles done : 11     │
    │   last new path : 0 days, 0 hrs, 34 min, 26 sec      │  total paths : 583    │
    │ last uniq crash : none seen yet                      │ uniq crashes : 0      │
    │  last uniq hang : 0 days, 2 hrs, 10 min, 54 sec      │   uniq hangs : 47     │
    ├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
    │  now processing : 170 (29.16%)      │    map density : 0.39% / 1.49%         │
    │ paths timed out : 0 (0.00%)         │ count coverage : 5.02 bits/tuple       │
    ├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
    │  now trying : splice 7              │ favored paths : 93 (15.95%)            │
    │ stage execs : 5/32 (15.62%)         │  new edges on : 142 (24.36%)           │
    │ total execs : 18.1M                 │ total crashes : 0 (0 unique)           │
    │  exec speed : 282.7/sec             │   total hangs : 297 (47 unique)        │
    ├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
    │   bit flips : 0/678k, 4/677k, 0/677k                │    levels : 15         │
    │  byte flips : 0/84.8k, 0/84.5k, 0/83.9k             │   pending : 31         │
    │ arithmetics : 0/4.72M, 0/16.6k, 0/307               │  pend fav : 0          │
    │  known ints : 0/480k, 0/2.35M, 0/3.69M              │ own finds : 40         │
    │  dictionary : 0/0, 0/0, 2/2.49M                     │  imported : 3          │
    │       havoc : 29/1.25M, 5/753k                      │ stability : 100.00%    │
    │        trim : 11.02%/43.6k, 0.00%                   ├────────────────────────┘
    ^C────────────────────────────────────────────────────┘             [cpu: 69%]

    +++ Testing aborted by user +++
    [+] We're done here. Have a nice day!

-   <https://github.com/stig/json-framework/pull/246>

## Fix bug in unwrapper code that caused arrays to be skipped

Whilst playing with AFL I accidentally found (and fixed) a bug where the
unwrapRootArray parser would break on any arrays at the next-to-outermost
level.

-   <https://github.com/stig/json-framework/pull/244>

## Improved documentation

I've tried to improve the documentation a little, both in README and the API
documentation in the header files.
