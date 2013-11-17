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


#import "SBJson.h"

@interface JsonCheckerSuite : SenTestCase
@end

@implementation JsonCheckerSuite {
    NSUInteger count;
}

- (void)setUp {
    count = 0;
}

- (void)foreachFilePrefixedBy:(NSString*)prefix apply:(void(^)(NSString*))block {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *rootPath = [[bundle resourcePath] stringByAppendingPathComponent:@"jsonchecker"];
    
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
    SBErrorHandlerBlock eh = ^(NSError *err) {
        STFail(@"%@", err);
    };

    [self foreachFilePrefixedBy:@"pass" apply:^(NSString* path) {
        __block BOOL success = NO;
        SBItemBlock block = ^(id obj, BOOL *stop) {
            STAssertNotNil(obj, path);
            success = YES;
        };

        SBJsonParser *parser = [[SBJsonParser alloc] initWithBlock:block
                                                      processBlock:nil
                                                     manyDocuments:NO
                                                    rootArrayItems:NO
                                                          maxDepth:19
                                                      errorHandler:eh];
        SBJsonParserStatus status = [parser parse:[NSData dataWithContentsOfFile:path]];

        STAssertTrue(success && status == SBJsonParserComplete, @"Success block was called & parsing complete");

    }];
    STAssertEquals(count, (NSUInteger)3, nil);
}

- (void)testFail {
    SBItemBlock block = ^(id obj, BOOL *stop) {};
    [self foreachFilePrefixedBy:@"fail" apply:^(NSString* path) {

        __block BOOL success = NO;
        SBErrorHandlerBlock eh = ^(NSError *err) {
            STAssertNotNil(err, path);
            success = YES;
        };

        SBJsonParser *parser = [[SBJsonParser alloc] initWithBlock:block
                                                      processBlock:nil
                                                     manyDocuments:NO
                                                    rootArrayItems:NO
                                                          maxDepth:19
                                                      errorHandler:eh];

        SBJsonParserStatus status = [parser parse:[NSData dataWithContentsOfFile:path]];

        if (status != SBJsonParserWaitingForData)
            STAssertTrue(success, @"ErrorHandler block was called: %@", [path lastPathComponent]);
    }];

    STAssertEquals(count, (NSUInteger)33, nil);
}

@end
