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
				return SBJsonStreamParserError;
				break;

			default:
				
				if (![states[depth] parser:self shouldAcceptToken:tok]) {
					NSLog(@"Token of type %u not expected at state %@", tok, states[depth]);
					states[depth] = [SBJsonStreamParserStateError state];
					return SBJsonStreamParserError;
				}
				
				switch (tok) {
					case sbjson_token_array_start:
						if (depth >= maxDepth) {
							NSLog(@"Parser exceeded max depth of %lu", maxDepth);
							states[--depth] = [SBJsonStreamParserStateError state];
							break;
						}
						
						[delegate parsedArrayStart:self];
						states[++depth] = [SBJsonStreamParserStateArrayStart state];
						break;
						
					case sbjson_token_array_end:
						[states[--depth] parser:self shouldTransitionTo:tok];
						[delegate parsedArrayEnd:self];
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
