/*
 Copyright (C) 2007-2011 Stig Brautaset. All rights reserved.

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

#import <SenTestingKit/SenTestingKit.h>
#import <JSON/JSON.h>

@interface ErrorTest : SenTestCase {
	SBJsonParser * parser;
	SBJsonWriter * writer;
}
@end

#define SBAssertStringContains(e, s) \
    STAssertTrue([e rangeOfString:s].location != NSNotFound, @"%@ vs %@", e, s)

@implementation ErrorTest


- (void)setUp {
    parser = [SBJsonParser new];
    writer = [SBJsonWriter new];
}

- (void)tearDown {
    [parser release];
    [writer release];
}

#pragma mark Generator

- (void)testUnsupportedObject
{

    STAssertNil([writer stringWithObject:[NSData data]], nil);
    STAssertNotNil(writer.error, nil);
}

- (void)testNonStringDictionaryKey
{
    NSArray *keys = [NSArray arrayWithObjects:[NSNull null],
                     [NSNumber numberWithInt:1],
                     [NSArray array],
                     [NSDictionary dictionary],
                     nil];

    for (id key in keys) {

        NSDictionary *object = [NSDictionary dictionaryWithObject:@"1" forKey:key];
        STAssertEqualObjects([writer stringWithObject:object], nil, nil);
        STAssertNotNil(writer.error, nil);
    }
}


- (void)testScalar
{
    NSArray *fragments = [NSArray arrayWithObjects:@"foo", @"", [NSNull null], [NSNumber numberWithInt:1], [NSNumber numberWithBool:YES], nil];
    for (NSUInteger i = 0; i < [fragments count]; i++) {
        NSString *fragment = [fragments objectAtIndex:i];

        // We don't check the convenience category here, like we do for parsing,
        // because the category is explicitly on the NSArray and NSDictionary objects.
        // STAssertNil([fragment JSONRepresentation], nil);


        STAssertNil([writer stringWithObject:fragment], @"%@", fragment);
        SBAssertStringContains(parser.error, @"Not valid type for JSON");
    }
}

- (void)testInfinity {
    NSArray *obj = [NSArray arrayWithObject:[NSNumber numberWithDouble:INFINITY]];

    STAssertNil([writer stringWithObject:obj], nil);
    SBAssertStringContains(parser.error, @"Infinity is not a valid number in JSON");
}

- (void)testNegativeInfinity {
    NSArray *obj = [NSArray arrayWithObject:[NSNumber numberWithDouble:-INFINITY]];

    STAssertNil([writer stringWithObject:obj], nil);
    SBAssertStringContains(parser.error, @"Infinity is not a valid number in JSON");
}

- (void)testNaN {
    NSArray *obj = [NSArray arrayWithObject:[NSDecimalNumber notANumber]];

    STAssertNil([writer stringWithObject:obj], nil);
    SBAssertStringContains(parser.error, @"NaN is not a valid number in JSON");
}

#pragma mark Scanner

- (void)testArray {
    STAssertNil([parser objectWithString:@"[1,,2]"], nil);
    SBAssertStringContains(parser.error, @"not expected as array value");

    STAssertNil([parser objectWithString:@"[1,,]"], nil);
    SBAssertStringContains(parser.error, @"not expected as array value");

    STAssertNil([parser objectWithString:@"[,1]"], nil);
    SBAssertStringContains(parser.error, @"not expected at array start");

    STAssertNil([parser objectWithString:@"[1,]"], nil);
    SBAssertStringContains(parser.error, @"not expected as array value");

    STAssertNil([parser objectWithString:@"[1"], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@"[[]"], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    // See if seemingly-valid arrays have nasty elements
    STAssertNil([parser objectWithString:@"[+1]"], nil);
    SBAssertStringContains(parser.error, @"Leading + is illegal");
}

- (void)testObject {
    STAssertNil([parser objectWithString:@"{1,"], nil);
    SBAssertStringContains(parser.error, @"Token 'number' not expected at beginning of object");

    STAssertNil([parser objectWithString:@"{null"], nil);
    SBAssertStringContains(parser.error, @"Token 'null' not expected at beginning of object");

    STAssertNil([parser objectWithString:@"{\"a\":1,,}"], nil);
    SBAssertStringContains(parser.error, @"Token 'value separator' not expected in place of object key");

    STAssertNil([parser objectWithString:@"{,\"a\":1}"], nil);
    SBAssertStringContains(parser.error, @"Token 'value separator' not expected at beginning of object");


    STAssertNil([parser objectWithString:@"{\"a\","], nil);
    SBAssertStringContains(parser.error, @"Token 'value separator' not expected after object key");


    STAssertNil([parser objectWithString:@"{\"a\":,"], nil);
    SBAssertStringContains(parser.error, @"Token 'value separator' not expected as object value");


    STAssertNil([parser objectWithString:@"{\"a\":1,}"], nil);
    SBAssertStringContains(parser.error, @"Token 'end of object' not expected in place of object key");


    STAssertNil([parser objectWithString:@"{"], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@"{\"a\":{}"], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");
}

- (void)testNumber {
    STAssertNil([parser objectWithString:@"[- "], nil);
    SBAssertStringContains(parser.error, @"No digits after initial minus");

    STAssertNil([parser objectWithString:@"[+1 "], nil);
    SBAssertStringContains(parser.error, @"Leading + is illegal in number");

    STAssertNil([parser objectWithString:@"[01"], nil);
    SBAssertStringContains(parser.error, @"Leading zero is illegal in number");

    STAssertNil([parser objectWithString:@"[0. "], nil);
    SBAssertStringContains(parser.error, @"No digits after decimal point");


    STAssertNil([parser objectWithString:@"[1e "], nil);
    SBAssertStringContains(parser.error, @"No digits after exponent");

    STAssertNil([parser objectWithString:@"[1e- "], nil);
    SBAssertStringContains(parser.error, @"No digits after exponent");

    STAssertNil([parser objectWithString:@"[1e+ "], nil);
    SBAssertStringContains(parser.error, @"No digits after exponent");
}

- (void)testNull {
    STAssertNil([parser objectWithString:@"[nil "], nil);
    SBAssertStringContains(parser.error, @"Expected 'null'");
}

- (void)testBool {
    STAssertNil([parser objectWithString:@"[truth "], nil);
    SBAssertStringContains(parser.error, @"Expected 'true'");

    STAssertNil([parser objectWithString:@"[fake "], nil);
    SBAssertStringContains(parser.error, @"Expected 'false'");
}

- (void)testString {
    STAssertNil([parser objectWithString:@""], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@""], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@"[\""], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@"[\"foo"], nil);
    SBAssertStringContains(parser.error, @"Didn't find full object before EOF");

    STAssertNil([parser objectWithString:@"[\"\\uD834foobar\""], nil);
    SBAssertStringContains(parser.error, @"Missing low character");

    STAssertNil([parser objectWithString:@"[\"\\uD834\\u001E\""], nil);
    SBAssertStringContains(parser.error, @"Invalid low character in surrogate pair");

    STAssertNil([parser objectWithString:@"[\"\\uDD1Ef\""], nil);
    SBAssertStringContains(parser.error, @"Invalid high character");

    for (NSUInteger i = 0; i < 0x20; i++) {
        NSString *str = [NSString stringWithFormat:@"[\"%C\"]", i];
        STAssertNil([parser objectWithString:str], nil);
        SBAssertStringContains(parser.error, @"Unescaped control char 0x");
    }
}

- (void)testObjectGarbage {
    STAssertNil([parser objectWithString:@"['1'"], nil);
    SBAssertStringContains(parser.error, @"Unrecognised leading character");

    STAssertNil([parser objectWithString:@"['hello'"], nil);
    SBAssertStringContains(parser.error, @"Unrecognised leading character");

    STAssertNil([parser objectWithString:@"[**"], nil);
    SBAssertStringContains(parser.error, @"Unrecognised leading character");

    STAssertNil([parser objectWithString:nil], nil);
    SBAssertStringContains(parser.error, @"Input was 'nil'");
}

- (void)testParseDepth {
    parser.maxDepth = 2;

    STAssertNotNil([parser objectWithString:@"[[]]"], nil);
    STAssertNil([parser objectWithString:@"[[[]]]"], nil);
    STAssertEqualObjects(parser.error, @"Parser exceeded max depth of 2", parser.error);
}

- (void)testWriteDepth {
    writer.maxDepth = 2;

    NSArray *a1 = [NSArray array];
    NSArray *a2 = [NSArray arrayWithObject:a1];
    STAssertNotNil([writer stringWithObject:a2], nil);

    NSArray *a3 = [NSArray arrayWithObject:a2];
    STAssertNil([writer stringWithObject:a3], nil);
    STAssertEqualObjects(writer.error, @"Nested too deep", writer.error);
}

- (void)testWriteRecursion {
    // set a high limit
    writer.maxDepth = 100;

    // create a challenge!
    NSMutableArray *a1 = [NSMutableArray array];
    NSMutableArray *a2 = [NSMutableArray arrayWithObject:a1];
    [a1 addObject:a2];

    STAssertNil([writer stringWithObject:a1], nil);
    STAssertEqualObjects(writer.error, @"Nested too deep", writer.error);
}

@end
