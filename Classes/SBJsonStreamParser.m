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

#import "SBJsonStreamParser.h"
#import "SBJsonTokeniser.h"
#import "SBJsonStreamParserState.h"


@implementation SBJsonStreamParser

@synthesize error;
@synthesize delegate;
@synthesize maxDepth;
@synthesize states;
@synthesize depth;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		tokeniser = [SBJsonTokeniser new];
		maxDepth = 512;
		states = calloc(maxDepth, sizeof(SBJsonStreamParserState*));
		NSAssert(states, @"States not initialised");
		states[0] = [SBJsonStreamParserStateStart state];
	}
	return self;
}

- (void)dealloc {
	[tokeniser release];
	[error release];
	[super dealloc];
}

#pragma mark Methods

- (SBJsonStreamParserStatus)parse:(NSData *)data {
	[tokeniser appendData:data];
	
	const char *buf;
	NSUInteger len;
	
	for (;;) {		
		if ([states[depth] parserShouldStop:self])
			return [states[depth] parserShouldReturn:self];
		
		sbjson_token_t tok = [tokeniser next];
		
		switch (tok) {
			case sbjson_token_eof:
				return SBJsonStreamParserInsufficientData;
				break;

			case sbjson_token_error:
				states[depth] = [SBJsonStreamParserStateError state];
				self.error = tokeniser.error;
				return SBJsonStreamParserError;
				break;

			default:
				
				if (![states[depth] parser:self shouldAcceptToken:tok]) {
					self.error = [NSString stringWithFormat:@"Token of type %u not expected at state %@", tok, states[depth]];
					states[depth] = [SBJsonStreamParserStateError state];
					return SBJsonStreamParserError;
				}
				
				switch (tok) {
					case sbjson_token_object_start:
						if (depth >= maxDepth) {
							self.error = [NSString stringWithFormat:@"Parser exceeded max depth of %lu", maxDepth];
							states[depth] = [SBJsonStreamParserStateError state];

						} else {
							[delegate parsedObjectStart:self];
							states[++depth] = [SBJsonStreamParserStateObjectStart state];
						}
						break;
						
					case sbjson_token_object_end:
						[states[--depth] parser:self shouldTransitionTo:tok];
						[delegate parsedObjectEnd:self];
						break;
						
					case sbjson_token_array_start:
						if (depth >= maxDepth) {
							self.error = [NSString stringWithFormat:@"Parser exceeded max depth of %lu", maxDepth];
							states[depth] = [SBJsonStreamParserStateError state];
						} else {
							[delegate parsedArrayStart:self];
							states[++depth] = [SBJsonStreamParserStateArrayStart state];
						}						
						break;
						
					case sbjson_token_array_end:
						[states[--depth] parser:self shouldTransitionTo:tok];
						[delegate parsedArrayEnd:self];
						break;
						
					case sbjson_token_separator:
					case sbjson_token_key_value_separator:
						[states[depth] parser:self shouldTransitionTo:tok];
						break;
						
					case sbjson_token_true:
						[delegate parser:self parsedBoolean:YES];
						[states[depth] parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_false:
						[delegate parser:self parsedBoolean:NO];
						[states[depth] parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_null:
						[delegate parsedNull:self];
						[states[depth] parser:self shouldTransitionTo:tok];
						break;
						
					case sbjson_token_integer:
						if ([tokeniser getToken:&buf length:&len]) {
							char *e;
							NSInteger integer = strtol(buf, &e, 0);
							NSAssert(e-buf == len, @"Unexpected length");
							[delegate parser:self parsedInteger:integer];
							[states[depth] parser:self shouldTransitionTo:tok];
						}
						break;

					case sbjson_token_double:
						if ([tokeniser getToken:&buf length:&len]) {
							char *e;
							double d = strtod(buf, &e);
							NSAssert(e-buf == len, @"Unexpected length");
							[delegate parser:self parsedDouble:d];
							[states[depth] parser:self shouldTransitionTo:tok];
						}
						break;
						
					case sbjson_token_string:
						NSAssert([tokeniser getToken:&buf length:&len], @"failed to get token");
						NSString *string = [[NSString alloc] initWithBytes:buf+1 length:len-2 encoding:NSUTF8StringEncoding];
						if ([states[depth] needKey])
							[delegate parser:self parsedObjectKey:string];
						else
							[delegate parser:self parsedString:string];
						[string release];
						[states[depth] parser:self shouldTransitionTo:tok];
						break;
						
					case sbjson_token_string_encoded:
						NSAssert([tokeniser getToken:&buf length:&len], @"failed to get token");
						NSString *decoded = [tokeniser getDecodedStringToken];
						if ([states[depth] needKey])
							[delegate parser:self parsedObjectKey:decoded];
						else
							[delegate parser:self parsedString:decoded];
						[states[depth] parser:self shouldTransitionTo:tok];
						break;
						
					default:
						break;
				}
				break;
		}
	}
	return SBJsonStreamParserComplete;
}


@end
