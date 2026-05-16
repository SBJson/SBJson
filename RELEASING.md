# Release Checklist

1. Check that tests pass on trunk
2. Run AFL for at least 24 hours if changes to the parser
3. Add release notes
4. Run [RegenerateCredits](RegenerateCredits) script
5. Update version in README
6. Create a new release (with tag format `v5.0.x`) using [GitHub releases](https://github.com/SBJson/SBJson/releases)
7. Push new release to CocoaPods
   1. Update `spec.version` in pod specs
   2. `pod trunk register stig@brautaset.org`
   3. `pod trunk push`
