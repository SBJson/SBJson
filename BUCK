apple_library(
  name = 'SBJson',
  deps = [],
  preprocessor_flags = ['-fobjc-arc'],
  header_path_prefix = 'SBJson',
  exported_headers = [
    'src/main/objc/SBJson4.h',
    'src/main/objc/SBJson4Parser.h',
    'src/main/objc/SBJson4Writer.h',
    'src/main/objc/SBJson4StreamParser.h',
    'src/main/objc/SBJson4StreamTokeniser.h',
    'src/main/objc/SBJson4StreamWriter.h',
  ],
  headers = [
    'src/main/objc/SBJson4StreamParserState.h',
    'src/main/objc/SBJson4StreamWriterState.h',
  ],
  srcs = [
    'src/main/objc/SBJson4Parser.m',
    'src/main/objc/SBJson4StreamParser.m',
    'src/main/objc/SBJson4StreamParserState.m',
    'src/main/objc/SBJson4StreamTokeniser.m',
    'src/main/objc/SBJson4StreamWriter.m',
    'src/main/objc/SBJson4StreamWriterState.m',
    'src/main/objc/SBJson4Writer.m',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
  ],
)

apple_resource(
  name = 'TestData',
  files = glob(['*.in', '*.out']),
  dirs = glob(['src/test/resources/*']),
)

apple_test(
  name = 'ErrorTest',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/ErrorTest.m'],
  deps = [
    ':SBJson',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)


apple_test(
  name = 'JsonCheckerSuite',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/JsonCheckerSuite.m'],
  deps = [
    ':SBJson',
    ':TestData',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)


apple_test(
  name = 'JsonStreamTokeniserTest',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/JsonStreamTokeniserTest.m'],
  deps = [
    ':SBJson',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)

apple_test(
  name = 'MainSuite',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/MainSuite.m'],
  deps = [
    ':SBJson',
    ':TestData',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)


apple_test(
  name = 'StreamSuite',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/StreamSuite.m'],
  deps = [
    ':SBJson',
    ':TestData',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)


apple_test(
  name = 'ProxyTest',
  extension = 'xctest',
  info_plist = 'SBJsonTests/SBJsonTests-Info.plist',
  info_plist_substitutions = { 'CURRENT_PROJECT_VERSION': '38' },
  preprocessor_flags = ['-fobjc-arc'],
  srcs = ['src/test/objc/ProxyTest.m'],
  deps = [
    ':SBJson',
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$PLATFORM_DIR/Developer/Library/Frameworks/XCTest.framework',
  ],
)
