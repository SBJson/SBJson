/*
 Copyright (c) 2010, Stig Brautaset.
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


#import <SenTestingKit/SenTestingKit.h>
#import <JSON/JSON.h>
#import "StreamParserDelegate.h"

@interface StreamParserTest : SenTestCase {
	SBJsonStreamParser *parser;
	StreamParserDelegate *delegate;
}
@end

static NSData *x(char *s) {
	return [NSData dataWithBytes:s length:strlen(s)];
}

@implementation StreamParserTest

- (void)setUp {
	delegate = [[StreamParserDelegate new] autorelease];
	parser = [[SBJsonStreamParser new] autorelease];
	parser.delegate = delegate;
}

- (void)testEof {
	STAssertEquals([parser parse:x("")], SBJsonStreamParserInsufficientData, nil);
	STAssertEqualObjects(delegate.string, @"", nil);
}

- (void)testEmptyArray {
	STAssertEquals([parser parse:x("[]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 0) ", nil);
}

- (void)testNestedEmptyArray {
	STAssertEquals([parser parse:x("[[[]]]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 (1 (2 2) 1) 0) ", nil);
}

- (void)testNestedEmptyArrays {
	STAssertEquals([parser parse:x("[[[],[]]]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 (1 (2 2) (2 2) 1) 0) ", nil);
}

- (void)testBoolAndNull {
	STAssertEquals([parser parse:x("[true,null,false]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 YES nil NO 0) ", nil);
}

- (void)testNumbers {
	STAssertEquals([parser parse:x("[0,1.98,-23.7e+3]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 0 1.98 -23700 0) ", nil);
}

- (void)testSimpleStrings {
	STAssertEquals([parser parse:x("[\"foo\",\"\\t\",\"a\\\"b\"]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 'foo' '\t' 'a\"b' 0) ", nil);
}

- (void)testStrings {
	STAssertEquals([parser parse:x("[\"\\u0041\\\"\\u0042\"]")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"(0 'A\"B' 0) ", nil);
}

- (void)testEmptyObject {
	STAssertEquals([parser parse:x("{}")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"{0 0} ", nil);
}

- (void)testSimpleObject {
	STAssertEquals([parser parse:x("{\"k\":true}")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"{0 k=YES 0} ", nil);
}

- (void)testNestedObject {
	STAssertEquals([parser parse:x("{\"k\":{\"kk\":[],\"kkk\":\"foo\"}}")], SBJsonStreamParserComplete, nil);
	STAssertEqualObjects(delegate.string, @"{0 k={1 kk=(2 2) kkk='foo' 1} 0} ", nil);
}



@end