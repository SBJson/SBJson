/*
 Copyright (c) 2010-2013, Stig Brautaset.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
  
   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 
   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "SBJson5.h"
#import <XCTest/XCTest.h>


@interface StreamSuite : XCTestCase
@end

static NSUInteger arrayCount, objectCount;
static NSError *error;

@implementation StreamSuite {
    SBJson5ValueBlock block;
    SBJson5ErrorBlock eh;
}

- (void)setUp {
    block = ^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]])
            arrayCount++;
        else if ([obj isKindOfClass:[NSDictionary class]])
            objectCount++;
    };

    eh = ^(NSError *e) { error = e; };

    arrayCount = objectCount = 0u;
}


- (void) testParsingWithShortWorkBuffer{   
    char* validjson = "[{\"description\": \"Lorem ipsum dolor sit amet, "\
        "consectetur adipiscing elit. Donec ultrices ornare gravida. Vestibulum"\
        " ante ipsum primisin faucibus orci luctus et ultrices posuere\"}]";

    id parser = [SBJson5Parser parserWithBlock:block
                                allowMultiRoot:NO
                               unwrapRootArray:NO
                                  errorHandler:eh];

    SBJson5ParserStatus status = SBJson5ParserWaitingForData;
    NSData* data = nil;
   
    for (int i=0, e=(int)strlen(validjson); i<e; ++i){
        data = [NSData dataWithBytes:validjson+i length:1];
        status = [parser parse:data];
        if(status == SBJson5ParserError){
            break;
        }
    }
    XCTAssertEqual(status, SBJson5ParserComplete);
}

/*
  This test reads a 100k chunk of data downloaded from 
  http://stream.twitter.com/1/statuses/sample.json 
  and split into 1k files. It simulates streaming by parsing
  this data incrementally.
*/
- (void)testMultipleDocuments {
    id parser = [SBJson5Parser multiRootParserWithBlock:block errorHandler:eh];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *root = [[bundle resourcePath] stringByAppendingPathComponent:@"TestData/stream"];

    for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:root]) {
        NSString *file = [root stringByAppendingPathComponent:fileName];

        // Don't accidentally test directories. That would be bad.
        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir] || isDir)
            continue;

        NSData *data = [NSData dataWithContentsOfFile:file];
        XCTAssertNotNil(data);
	
        XCTAssertEqual([parser parse:data], SBJson5ParserWaitingForData, @"%@ - %@", file, error);
    }
    XCTAssertEqual(arrayCount, (NSUInteger)0);
    XCTAssertEqual(objectCount, (NSUInteger)98);
}

- (void)parseArrayOfObjects:(SBJson5Parser *)parser {
    [parser parse:[NSData dataWithBytes:"[" length:1]];
    for (int i = 1;; i++) {
        char *utf8 = "{\"foo\":[],\"bar\":[]}";
        [parser parse:[NSData dataWithBytes:utf8 length:strlen(utf8)]];
        if (i == 100)
            break;
        [parser parse:[NSData dataWithBytes:"," length:1]];
    }
    [parser parse:[NSData dataWithBytes:"]" length:1]];
}

- (void)testSingleArray {
    id parser = [SBJson5Parser parserWithBlock:block
                                allowMultiRoot:NO
                               unwrapRootArray:NO
                                  errorHandler:eh];

    [self parseArrayOfObjects:parser];
    XCTAssertEqual(arrayCount, (NSUInteger)1);
    XCTAssertEqual(objectCount, (NSUInteger)0);
}

- (void)testSkipArray {
    id parser = [SBJson5Parser unwrapRootArrayParserWithBlock:block
                                                 errorHandler:eh];

    [self parseArrayOfObjects:parser];
    XCTAssertEqual(arrayCount, (NSUInteger)0);
    XCTAssertEqual(objectCount, (NSUInteger)100);	
}

- (void)testStop {
    __block int count = 0;
    __block NSMutableArray *ary = [NSMutableArray array];
    SBJson5ValueBlock block2 = ^(id obj, BOOL *stop) {
        [ary addObject:obj];
        *stop = ++count >= 23;
    };

    id parser = [SBJson5Parser unwrapRootArrayParserWithBlock:block2
                                                 errorHandler:eh];

    [self parseArrayOfObjects:parser];
    XCTAssertEqual(ary.count, (NSUInteger)23);
}

- (void)testWriteToStream {
    SBJson5StreamWriter *streamWriter = [[SBJson5StreamWriter alloc] init];

    XCTAssertTrue([streamWriter writeArray:[NSArray array]]);

    XCTAssertFalse([streamWriter writeArray:[NSArray array]]);
    XCTAssertEqualObjects(streamWriter.error, @"Stream is closed");
}

@end
