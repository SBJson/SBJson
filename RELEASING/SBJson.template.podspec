# coding: utf-8
Pod::Spec.new do |spec|
    spec.name         = "SBJson"
    spec.version      = "%VERSION%"

    spec.homepage     = "https://github.com/SBJson/SBJson"
    spec.license      = { :type => "BSD", :file => "LICENSE" }
    spec.author       = { "Stig Brautaset" => "stig@brautaset.org" }

    spec.summary      = <<-SUMMARY
        A strict JSON parser and generator in Objective-C.
        Its primary feature is stream/chunk-based operation.
    SUMMARY

    spec.description  = <<-DESC
        SBJson implements a strict JSON parser and generator in
        Objective-C. Its primary feature is stream/chunk-based
        operation: feed it one or more chunks of UTF8-encoded data and
        it will call a block you provide with each root-level document
        or array. Or, optionally, for each top-level entry in each
        root-level array.

        With this you can reduce the apparent latency for each
        download/parse cycle of documents over a slow connection. You
        can start parsing *and return chunks of the parsed document*
        before the full document has downloaded. You can also parse
        massive documents bit by bit so you don't have to keep them
        all in memory.
    DESC

    spec.ios.deployment_target     = "5.0"
    spec.osx.deployment_target     = "10.7"
    spec.watchos.deployment_target = "2.0"
    spec.tvos.deployment_target    = "9.0"

    spec.source       = { :git => "https://github.com/SBJson/SBJson.git", :tag => "v#{spec.version}" }
    spec.source_files = "Classes/*"
    spec.requires_arc = true
end
