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
#import <limits.h>

static NSNumber *kTrue;
static NSNumber *kFalse;
static NSNull *kNull;

@interface SBJsonStreamParser ()

- (void)pop;
- (void)parserFoundObject:(id)obj;

@end

@implementation SBJsonStreamParser

@synthesize levelsToSkip;
@synthesize supportMultipleDocuments;
@synthesize error;
@synthesize delegate;
@synthesize maxDepth;
@synthesize state;
@synthesize stateStack;

#pragma mark Housekeeping

+ (void)initialize {
    kTrue = [[NSNumber alloc] initWithBool:YES];
    kFalse = [[NSNumber alloc] initWithBool:NO];
    kNull = [NSNull null];
}

- (id)init {
	self = [super init];
	if (self) {
		maxDepth = 32u;
        stateStack = [[NSMutableArray alloc] initWithCapacity:maxDepth];
        state = [SBJsonStreamParserStateStart sharedInstance];
		tokeniser = [[SBJsonTokeniser alloc] init];
        
        keyStack = [[NSMutableArray alloc] initWithCapacity:32];
		stack = [[NSMutableArray alloc] initWithCapacity:32];		
		currentType = SBJsonStreamParserNone;

	}
	return self;
}

- (void)dealloc {
    [keyStack release];
	[stack release];
    [error release];
	[stateStack release];
	[tokeniser release];
	[super dealloc];
}

#pragma mark Methods

- (NSString*)tokenName:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_start:
			return @"start of array";
			break;

		case sbjson_token_array_end:
			return @"end of array";
			break;

		case sbjson_token_number:
			return @"number";
			break;

		case sbjson_token_string:
			return @"string";
			break;

		case sbjson_token_true:
		case sbjson_token_false:
			return @"boolean";
			break;

		case sbjson_token_null:
			return @"null";
			break;

		case sbjson_token_keyval_separator:
			return @"key-value separator";
			break;

		case sbjson_token_separator:
			return @"value separator";
			break;

		case sbjson_token_object_start:
			return @"start of object";
			break;

		case sbjson_token_object_end:
			return @"end of object";
			break;

		case sbjson_token_eof:
		case sbjson_token_error:
			break;
	}
	NSAssert(NO, @"Should not get here");
	return @"<aaiiie!>";
}

- (void)maxDepthError {
    self.error = [NSString stringWithFormat:@"Input depth exceeds max depth of %lu", maxDepth];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}


- (void)pop {
	[stack removeLastObject];
	array = nil;
	dict = nil;
	currentType = SBJsonStreamParserNone;
	
	id value = [stack lastObject];
	
	if ([value isKindOfClass:[NSArray class]]) {
		array = value;
		currentType = SBJsonStreamParserArray;
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		dict = value;
		currentType = SBJsonStreamParserObject;
	}
}

- (void)parserFoundObject:(id)obj {
	NSParameterAssert(obj);
	
	switch (currentType) {
		case SBJsonStreamParserArray:
			[array addObject:obj];
			break;
            
		case SBJsonStreamParserObject:
			NSParameterAssert(keyStack.count);
			[dict setObject:obj forKey:[keyStack lastObject]];
			[keyStack removeLastObject];
			break;
			
		case SBJsonStreamParserNone:
			if ([obj isKindOfClass:[NSArray class]]) {
				[delegate parser:self foundArray:obj];
			} else {
				[delegate parser:self foundObject:obj];
			}				
			break;
            
		default:
			break;
	}
}

- (void)handleObjectStart {
	if (depth >= maxDepth) {
        [self maxDepthError];
        return;
	}
    
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateObjectStart sharedInstance];

	if (++depth > levelsToSkip) {
		dict = [[NSMutableDictionary alloc] init];
		[stack addObject:dict];
        [dict release];
        
		currentType = SBJsonStreamParserObject;
	}
}

- (void)handleObjectEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];

	if (depth-- > levelsToSkip) {
		id value = [dict retain];
		[self pop];
		[self parserFoundObject:value];
		[value release];
	}
}

- (void)handleArrayStart {
    
	if (depth >= maxDepth) {
        [self maxDepthError];
        return;
    }
    
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateArrayStart sharedInstance];
    
	if (++depth > levelsToSkip) {
		array = [[NSMutableArray alloc] init];
		[stack addObject:array];
        [array release];
        
		currentType = SBJsonStreamParserArray;
	}
}

- (void)handleArrayEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];

	if (depth-- > levelsToSkip) {
		id value = [array retain];
		[self pop];
		[self parserFoundObject:value];
		[value release];
	}
}

- (void) handleTokenNotExpectedHere: (sbjson_token_t) tok  {
    NSString *tokenName = [self tokenName:tok];
    NSString *stateName = [state name];

    self.error = [NSString stringWithFormat:@"Token '%@' not expected %@", tokenName, stateName];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}

- (SBJsonStreamParserStatus)parse:(NSData *)data_ {
	[tokeniser appendData:data_];

	for (;;) {

        if ([state isError])
            return SBJsonStreamParserError;

        NSObject *token;
		sbjson_token_t tok = [tokeniser getToken:&token];
		switch (tok) {
			case sbjson_token_eof:
                return [state parserShouldReturn:self];
				break;

			case sbjson_token_error:
				self.state = [SBJsonStreamParserStateError sharedInstance];
				self.error = tokeniser.error;
				return SBJsonStreamParserError;
				break;

			default:

				if (![state parser:self shouldAcceptToken:tok]) {
                    [self handleTokenNotExpectedHere: tok];
					return SBJsonStreamParserError;
				}

				switch (tok) {
					case sbjson_token_object_start:
						[self handleObjectStart];
						break;

					case sbjson_token_object_end:
                        [self handleObjectEnd: tok];
						break;

					case sbjson_token_array_start:
						[self handleArrayStart];
						break;

					case sbjson_token_array_end:
                        [self handleArrayEnd: tok];
						break;

					case sbjson_token_separator:
					case sbjson_token_keyval_separator:
						[state parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_true:
                        [self parserFoundObject:kTrue];
						[state parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_false:
                        [self parserFoundObject:kFalse];
						[state parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_null:
                        [self parserFoundObject:kNull];
						[state parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_number:
                        [self parserFoundObject:token];
						[state parser:self shouldTransitionTo:tok];
						break;

					case sbjson_token_string:
                        if ([state needKey])
                            [keyStack addObject:token];
                        else
                            [self parserFoundObject:token];
						[state parser:self shouldTransitionTo:tok];
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
