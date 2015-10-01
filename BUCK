apple_library(
  name = 'SBJson-iOS',
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

