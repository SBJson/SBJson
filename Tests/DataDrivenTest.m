/*
 Copyright (C) 2011 Stig Brautaset. All rights reserved.

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


#import <SenTestingKit/SenTestingKit.h>
#import <JSON/JSON.h>

@interface DataDrivenTest : SenTestCase {
@private
    NSUInteger count;
    SBJsonParser * parser;
    SBJsonWriter * writer;
}

@end

@implementation DataDrivenTest

- (void)setUp {
    count = 0;
    parser = [[SBJsonParser alloc] init];
    writer = [[SBJsonWriter alloc] init];
}

- (void)tearDown {
    [parser release];
    [writer release];
}

- (void)foreachFilePrefixedBy:(NSString*)prefix inSuite:(NSString*)suite apply:(void(^)(NSString*))block {
    NSString *file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:suite];
    while ((file = [enumerator nextObject])) {
        if (![file hasPrefix:prefix])
            continue;

        NSString *path = [suite stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
            block(path);
            count++;
        }
    }
}

- (void)foreachTestInSuite:(NSString*)suite apply:(void(^)(NSString*, NSString*))block {
    NSString *file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:suite];
    while ((file = [enumerator nextObject])) {
        NSString *path = [suite stringByAppendingPathComponent:file];
        NSString *inpath = [path stringByAppendingPathComponent:@"input"];

        if ([[NSFileManager defaultManager] isReadableFileAtPath:inpath]) {
            NSString *outpath = [path stringByAppendingPathComponent:@"output"];
            STAssertTrue([[NSFileManager defaultManager] isReadableFileAtPath:outpath], nil);
            block(inpath, outpath);
            count++;
        }
    }
}

- (void)testJsonCheckerPass {
    [self foreachFilePrefixedBy:@"pass" inSuite:@"Tests/Data/jsonchecker" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);

        id object = [parser objectWithString:input];
        STAssertNotNil(object, path);
        STAssertNil(parser.error, path);

    }];
    STAssertEquals(count, (NSUInteger)3, nil);
}


- (void)testJsonCheckerFail {
    parser.maxDepth = 19;

    [self foreachFilePrefixedBy:@"fail" inSuite:@"Tests/Data/jsonchecker" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);

        STAssertNil([parser objectWithString:input], @"%@ - %@", input, path);
        STAssertNotNil(parser.error, path);
    }];

    STAssertEquals(count, (NSUInteger)33, nil);
}

- (void)testPrettyString {
    writer.humanReadable = YES;
    writer.sortKeys = YES;

    [self foreachTestInSuite:@"Tests/Data/format" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        id object = [parser objectWithString:input];
        STAssertNotNil(object, nil);

        NSString *json = [writer stringWithObject:object];
        STAssertNotNil(json, nil);

        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];

    STAssertEquals(count, (NSUInteger)8, nil);
}

- (void)testPrettyData {
    writer.humanReadable = YES;
    writer.sortKeys = YES;

    [self foreachTestInSuite:@"Tests/Data/format" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSData *input = [NSData dataWithContentsOfFile:inpath];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        id object = [parser objectWithData:input];
        STAssertNotNil(object, nil);

        NSData *json = [writer dataWithObject:object];
        STAssertNotNil(json, nil);

        NSData *output = [NSData dataWithContentsOfFile:outpath];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        output = [NSData dataWithBytes:output.bytes length:output.length-1];
        STAssertEqualObjects(json, output, nil);
    }];

    STAssertEquals(count, (NSUInteger)8, nil);
}


- (void)testString {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        id object = [parser objectWithString:input];
        STAssertNotNil(object, nil);

        NSString *json = [writer stringWithObject:object];
        STAssertNotNil(json, nil);

        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];

    STAssertEquals(count, (NSUInteger)16, nil);
}


- (void)testData {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSData *input = [NSData dataWithContentsOfFile:inpath];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        id object = [parser objectWithData:input];
        STAssertNotNil(object, nil);

        NSData *json = [writer dataWithObject:object];
        STAssertNotNil(json, nil);

        NSData *output = [NSData dataWithContentsOfFile:outpath];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        output = [NSData dataWithBytes:output.bytes length:output.length-1];
        STAssertEqualObjects(json, output, nil);
    }];

    STAssertEquals(count, (NSUInteger)16, nil);
}


- (void)testCategory {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        id object = [input JSONValue];
        STAssertNotNil(object, nil);

        NSString *json = [object JSONRepresentation];
        STAssertNotNil(json, nil);

        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];

    STAssertEquals(count, (NSUInteger)16, nil);
}

@end
