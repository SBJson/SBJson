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

#import "SBJsonStreamParserState.h"
#import "SBJsonStreamParser.h"


@implementation SBJsonStreamParserState

+ (id)state {
	return [[[self alloc] init] autorelease];
}

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return NO;
}

- (BOOL)parserShouldStop:(SBJsonStreamParser*)parser {
	return NO;
}

- (SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser*)parser {
	return SBJsonStreamParserWaitingForData;
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {}

- (BOOL)needKey {
	return NO;
}

- (NSString*)name {
	return @"<aaiie!>";
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateStart

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_start || token == sbjson_token_object_start;
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {

	SBJsonStreamParserState *state = nil;
	switch (tok) {
		case sbjson_token_array_start:
			state = [SBJsonStreamParserStateArrayStart state];
			break;
			
		case sbjson_token_object_start:
			state = [SBJsonStreamParserStateObjectStart state];
			break;
			
		case sbjson_token_array_end:
		case sbjson_token_object_end:
			if (parser.multi)
				state = parser.states[parser.depth];
			else
				state = [SBJsonStreamParserStateComplete state];
			break;
			
		case sbjson_token_eof:
			return;
			
		default:
			state = [SBJsonStreamParserStateError state];
			break;
	}
	
	
	parser.states[parser.depth] = state;
}

- (NSString*)name { return @"before outer-most array or object"; }

@end

#pragma mark -

@implementation SBJsonStreamParserStateComplete

- (NSString*)name { return @"after outer-most array or object"; }

- (BOOL)parserShouldStop:(SBJsonStreamParser*)parser {
	return YES;
}

- (SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser*)parser {
	return SBJsonStreamParserComplete;
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateError

- (NSString*)name { return @"in error"; }

- (BOOL)parserShouldStop:(SBJsonStreamParser*)parser {
	return YES;
}

- (SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser*)parser {
	return SBJsonStreamParserError;
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateObjectStart

- (NSString*)name { return @"at beginning of object"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_string:
		case sbjson_token_string_encoded:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateObjectGotKey state];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateObjectGotKey

- (NSString*)name { return @"after object key"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_key_value_separator;
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateObjectSeparator state];
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateObjectSeparator

- (NSString*)name { return @"as object value"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_start:
		case sbjson_token_array_start:
		case sbjson_token_true:
		case sbjson_token_false:
		case sbjson_token_null:
		case sbjson_token_integer:
		case sbjson_token_double:
		case sbjson_token_string:
		case sbjson_token_string_encoded:
			return YES;
			break;

		default:
			return NO;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateObjectGotValue state];
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateObjectGotValue

- (NSString*)name { return @"after object value"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateObjectNeedKey state];
}


@end

#pragma mark -

@implementation SBJsonStreamParserStateObjectNeedKey

- (NSString*)name { return @"in place of object key"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_string:
		case sbjson_token_string_encoded:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateObjectGotKey state];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateArrayStart

- (NSString*)name { return @"at array start"; }

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_key_value_separator:
		case sbjson_token_separator:
			return NO;
			break;
			
		default:
			return YES;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateArrayGotValue state];
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateArrayGotValue

- (NSString*)name { return @"after array value"; }


- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_end || token == sbjson_token_separator;
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	if (tok == sbjson_token_separator)
		parser.states[parser.depth] = [SBJsonStreamParserStateArrayNeedValue state];
}

@end

#pragma mark -

@implementation SBJsonStreamParserStateArrayNeedValue

- (NSString*)name { return @"as array value"; }


- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_key_value_separator:
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.states[parser.depth] = [SBJsonStreamParserStateArrayGotValue state];
}

@end

