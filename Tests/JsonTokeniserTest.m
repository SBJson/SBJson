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
#import "SBJsonTokeniser.h"

@interface JsonTokeniserTest : SenTestCase {
	SBJsonTokeniser *tokeniser;
}
@end

@implementation JsonTokeniserTest

- (SBJsonTokeniser*)tokeniserWithString:(NSString*)string {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	SBJsonTokeniser *tok = [[SBJsonTokeniser new] autorelease];
	[tok appendData:data];
	return tok;
}

- (void)testNext {
	tokeniser = [self tokeniserWithString:@""];
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);

	tokeniser = [self tokeniserWithString:@"\n[\rtrue\f,\vfalse\t,	null, {\t\n\r\f\v}]"];
	STAssertEquals([tokeniser next], sbjson_token_array_start, nil);
	STAssertEquals([tokeniser next], sbjson_token_true, nil);
	STAssertEquals([tokeniser next], sbjson_token_separator, nil);
	STAssertEquals([tokeniser next], sbjson_token_false, nil);
	STAssertEquals([tokeniser next], sbjson_token_separator, nil);
	STAssertEquals([tokeniser next], sbjson_token_null, nil);
	STAssertEquals([tokeniser next], sbjson_token_separator, nil);
	STAssertEquals([tokeniser next], sbjson_token_object_start, nil);
	STAssertEquals([tokeniser next], sbjson_token_object_end, nil);
	STAssertEquals([tokeniser next], sbjson_token_array_end, nil);
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);	
}

- (void)testNextErrors {
	tokeniser = [self tokeniserWithString:@"hello"];
	STAssertEquals([tokeniser next], sbjson_token_error, nil);

	tokeniser = [self tokeniserWithString:@" hello"];
	STAssertEquals([tokeniser next], sbjson_token_error, nil);
}

- (void)testString {
	
	tokeniser = [self tokeniserWithString:@"hello"];
	STAssertEquals([tokeniser next], sbjson_token_error, nil);
	
	// This *is* a JSON-style quoted string
	tokeniser = [self tokeniserWithString:@"\"hello\""];
	STAssertEquals([tokeniser next], sbjson_token_string, nil);
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);
	
	// ... with an embedded double-quote
	tokeniser = [self tokeniserWithString:@"\"\\\"hello\\\" world\""];
	STAssertEquals([tokeniser next], sbjson_token_string_encoded, nil);
	
	const char *bytes;
	NSUInteger len;
	STAssertTrue([tokeniser getToken:&bytes length:&len], nil);
	
	NSData *data = [NSData dataWithBytes:bytes length:len];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	STAssertEqualObjects(string, @"\"\\\"hello\\\" world\"", nil);
	
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);
}

- (void)testNumber {
	tokeniser = [self tokeniserWithString:@"b+345.445"];
	STAssertEquals([tokeniser next], sbjson_token_error, nil);

	tokeniser = [self tokeniserWithString:@"+3"];
	STAssertEquals([tokeniser next], sbjson_token_error, @"leading + is disallowed");

	tokeniser = [self tokeniserWithString:@".0 "];
	STAssertEquals([tokeniser next], sbjson_token_error, @"number must start with 0-9 or -");

	tokeniser = [self tokeniserWithString:@"9. "];
	STAssertEquals([tokeniser next], sbjson_token_error, nil);

	tokeniser = [self tokeniserWithString:@"0"];
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);

	tokeniser = [self tokeniserWithString:@"1"];
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);

	tokeniser = [self tokeniserWithString:@"1 0 -1,"];
	STAssertEquals([tokeniser next], sbjson_token_integer, nil);
	STAssertEquals([tokeniser next], sbjson_token_integer, nil);
	STAssertEquals([tokeniser next], sbjson_token_integer, nil);
	STAssertEquals([tokeniser next], sbjson_token_separator, nil);

	tokeniser = [self tokeniserWithString:@"1.1 0.0 -1.5331,"];
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_separator, nil);
	
	tokeniser = [self tokeniserWithString:@"345.445e+3 3.3E-123 3.2e992 2.3e1"];
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);
	
	// Test restarting after we've added more data
	[tokeniser appendData:[NSData dataWithBytes:" " length:1]];
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	STAssertEquals([tokeniser next], sbjson_token_eof, nil);

	tokeniser = [self tokeniserWithString:@"-345.4453 "];
	STAssertEquals([tokeniser next], sbjson_token_double, nil);
	
	const char *num;
	NSUInteger len;
	STAssertTrue([tokeniser getToken:&num length:&len], nil);
	
	NSData *data = [NSData dataWithBytes:num length:len];
	NSString *number = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	STAssertEqualObjects(number, @"-345.4453", nil);
}

- (void)testAppendTruncatesFront {
	tokeniser = [self tokeniserWithString:@" 1 2 3"];
	STAssertEqualObjects([tokeniser valueForKey:@"offset"], [NSNumber numberWithInt:0], nil);

	[tokeniser next];
	STAssertEqualObjects([tokeniser valueForKey:@"offset"], [NSNumber numberWithInt:1], nil);

	[tokeniser next];
	STAssertEqualObjects([tokeniser valueForKey:@"offset"], [NSNumber numberWithInt:3], nil);
	
	[tokeniser appendData:[NSData dataWithBytes:" " length:1]];
	STAssertEqualObjects([tokeniser valueForKey:@"offset"], [NSNumber numberWithInt:0], nil);
	
	
}


@end
