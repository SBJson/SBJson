# Release Checklist

1. Check that tests pass on trunk
2. Run AFL for at least 24 hours if changes to the parser
3. Add release notes
4. Run [RegenerateCredits](RegenerateCredits) script
5. Create a new release (with tag format `v5.0.3`) using [GitHub releases](https://github.com/SBJson/SBJson/releases)
6. Push new release to CocoaPods
   1. `sed "s/%VERSION%/v5.0.4/" RELEASING/SBJson.template.podspec > SBJson.podspec`
   2. `pod trunk register stig@brautaset.org`
   3. `pod trunk push`
