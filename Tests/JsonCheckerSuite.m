/*
 Copyright (C) 2011-2013 Stig Brautaset. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

 * Neither the name of the author nor the names of its contributors
   may be used to endorse or promote products derived from this
   software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */


#import "SBJson5.h"
#import <XCTest/XCTest.h>

@interface JsonCheckerSuite : XCTestCase
@end

@implementation JsonCheckerSuite {
    NSUInteger count;
}

- (void)setUp {
    count = 0;
}

- (void)foreachFilePrefixedBy:(NSString*)prefix apply:(void(^)(NSString*))block {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *rootPath = [[bundle resourcePath] stringByAppendingPathComponent:@"TestData/jsonchecker"];
    
    for (NSString *file in [[NSFileManager defaultManager] enumeratorAtPath:rootPath]) {
        if (![file hasPrefix:prefix])
            continue;

        NSString *path = [rootPath stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
            block(path);
            count++;
        }
    }
}

- (void)testPass {
    SBJson5ErrorBlock eh = ^(NSError *err) {
        XCTFail(@"%@", err);
    };

    [self foreachFilePrefixedBy:@"pass" apply:^(NSString* path) {
            __block BOOL success = NO;
            SBJson5ValueBlock block = ^(id obj, BOOL *stop) {
                XCTAssertNotNil(obj, @"%@", path);
                success = YES;
            };

            SBJson5Parser *parser = [[SBJson5Parser alloc] initWithBlock:block
                                                            processBlock:nil
                                                               multiRoot:NO
                                                         unwrapRootArray:NO
                                                                maxDepth:19
                                                            errorHandler:eh];
            SBJson5ParserStatus status = [parser parse:[NSData dataWithContentsOfFile:path]];

            XCTAssertTrue(success && status == SBJson5ParserComplete, @"Success block was called & parsing complete");

        }];
}

- (void)testFail {
    SBJson5ValueBlock block = ^(id obj, BOOL *stop) {};
    [self foreachFilePrefixedBy:@"fail" apply:^(NSString* path) {

            __block BOOL success = NO;
            SBJson5ErrorBlock eh = ^(NSError *err) {
                XCTAssertNotNil(err, @"%@", path);
                success = YES;
            };

            SBJson5Parser *parser = [[SBJson5Parser alloc] initWithBlock:block
                                                            processBlock:nil
                                                               multiRoot:NO
                                                         unwrapRootArray:NO
                                                                maxDepth:19
                                                            errorHandler:eh];

            SBJson5ParserStatus status = [parser parse:[NSData dataWithContentsOfFile:path]];

            if (status != SBJson5ParserWaitingForData)
                XCTAssertTrue(success, @"ErrorHandler block was called: %@", [path lastPathComponent]);
        }];
}

@end
