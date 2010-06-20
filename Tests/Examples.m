/*
 Copyright (C) 2007-2010 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "Examples.h"
#import <JSON/JSON.h>

@implementation Examples

- (void)setUp {
    parser = [SBJsonParser new];
    writer = [SBJsonWriter new];
    writer.humanReadable = YES;
    writer.sortKeys = YES;
    
}

- (void)testFiles {
    
    NSString *file;
    NSString *dir = @"Tests/Data";
    NSDirectoryEnumerator *files = [[NSFileManager defaultManager] enumeratorAtPath:dir];
    
    while ((file = [files nextObject])) {
        if (![[file pathExtension] isEqualToString:@"json"])
            continue;
        
        NSString *jsonPath = [dir stringByAppendingPathComponent:file];        
        NSString *jsonText = [NSString stringWithContentsOfFile:jsonPath
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];
        STAssertNotNil(jsonText, @"Could not load %@", jsonPath);
        
        id parsed;
        STAssertNoThrow(parsed = [parser objectWithString:jsonText], jsonPath);
        STAssertNotNil(parsed, jsonPath);
        STAssertNil(parser.errorTrace, @"%@: %@", jsonPath, parser.errorTrace);
        
        NSString *written;
        STAssertNoThrow(written = [writer stringWithObject:parsed], jsonPath);
        STAssertNotNil(written, jsonPath);
        STAssertNil(writer.errorTrace, @"%@: %@", jsonPath, writer.errorTrace);
        
        NSString *goldPath = [jsonPath stringByAppendingPathExtension:@"gold"];
        NSString *goldText = [NSString stringWithContentsOfFile:goldPath
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];
        STAssertNotNil(goldText, @"Could not load %@", goldPath);

        // Chop off newline at end of string
        goldText = [goldText substringToIndex:[goldText length]-1];
        STAssertEqualObjects(written, goldText, @"at %@", jsonPath);
    }
}

- (void)testJsonChecker {
    NSString *file, *dir = @"Tests/jsonchecker";
    NSDirectoryEnumerator *files = [[NSFileManager defaultManager] enumeratorAtPath:dir];
    
    SBJSON *sbjson = [SBJSON new];
    sbjson.maxDepth = 19;
    while ((file = [files nextObject])) {
        if (![[file pathExtension] isEqualToString:@"json"])
            continue;

        NSString *json = [NSString stringWithContentsOfFile:[dir stringByAppendingPathComponent:file]
                                                   encoding:NSASCIIStringEncoding
                                                      error:nil];

        if ([file hasPrefix:@"pass"]) {
            STAssertNotNil([sbjson objectWithString:json error:NULL], nil);
            
        } else {
            STAssertNil([sbjson objectWithString:json error:NULL], json);
        }
    }
}

@end
