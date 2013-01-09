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

#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif

#import "SBJsonStreamParser.h"
#import "SBJsonStreamTokeniser.h"
#import "SBJsonStreamParserState.h"

#define SBStringIsSurrogateHighCharacter(character) ((character >= 0xD800UL) && (character <= 0xDBFFUL))

@implementation SBJsonStreamParser {
    SBJsonStreamTokeniser *tokeniser;
}

@synthesize supportMultipleDocuments;
@synthesize error;
@synthesize delegate;
@synthesize maxDepth;
@synthesize state;
@synthesize stateStack;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		maxDepth = 32u;
        stateStack = [[NSMutableArray alloc] initWithCapacity:maxDepth];
        state = [SBJsonStreamParserStateStart sharedInstance];
		tokeniser = [[SBJsonStreamTokeniser alloc] init];
	}
	return self;
}


#pragma mark Methods

- (NSString*)tokenName:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_open:
			return @"start of array";
			break;

		case sbjson_token_array_close:
			return @"end of array";
			break;

        case sbjson_token_integer:
        case sbjson_token_real:
			return @"number";
			break;

        case sbjson_token_string:
        case sbjson_token_encoded:
			return @"string";
			break;

        case sbjson_token_bool:
			return @"boolean";
			break;

		case sbjson_token_null:
			return @"null";
			break;

        case sbjson_token_entry_sep:
			return @"key-value separator";
			break;

        case sbjson_token_value_sep:
			return @"value separator";
			break;

		case sbjson_token_object_open:
			return @"start of object";
			break;

		case sbjson_token_object_close:
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
    self.error = [NSString stringWithFormat:@"Input depth exceeds max depth of %lu", (unsigned long)maxDepth];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}

- (void)handleObjectStart {
	if (stateStack.count >= maxDepth) {
        [self maxDepthError];
        return;
	}

    [delegate parserFoundObjectStart:self];
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateObjectStart sharedInstance];
}

- (void)handleObjectEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];
    [delegate parserFoundObjectEnd:self];
}

- (void)handleArrayStart {
	if (stateStack.count >= maxDepth) {
        [self maxDepthError];
        return;
    }
	
	[delegate parserFoundArrayStart:self];
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateArrayStart sharedInstance];
}

- (void)handleArrayEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];
    [delegate parserFoundArrayEnd:self];
}

- (void) handleTokenNotExpectedHere: (sbjson_token_t) tok  {
    NSString *tokenName = [self tokenName:tok];
    NSString *stateName = [state name];

    self.error = [NSString stringWithFormat:@"Token '%@' not expected %@", tokenName, stateName];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}

- (SBJsonStreamParserStatus)parse:(NSData *)data_ {
    @autoreleasepool {
        [tokeniser appendData:data_];
        
        for (;;) {
            
            if ([state isError])
                return SBJsonStreamParserError;
            
            char *token;
            NSUInteger token_len;
            sbjson_token_t tok = [tokeniser getToken:&token length:&token_len];
            
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
                        case sbjson_token_object_open:
                            [self handleObjectStart];
                            break;
                            
                        case sbjson_token_object_close:
                            [self handleObjectEnd: tok];
                            break;
                            
                        case sbjson_token_array_open:
                            [self handleArrayStart];
                            break;
                            
                        case sbjson_token_array_close:
                            [self handleArrayEnd: tok];
                            break;
                            
                        case sbjson_token_value_sep:
                        case sbjson_token_entry_sep:
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_bool:
                            [delegate parser:self foundBoolean:token[0] == 't'];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            

                        case sbjson_token_null:
                            [delegate parserFoundNull:self];
                            [state parser:self shouldTransitionTo:tok];
                            break;

                        case sbjson_token_integer: {
                            NSString *string = [[NSString alloc] initWithBytes:token length:token_len encoding:NSUTF8StringEncoding];
                            [delegate parser:self foundNumber:[NSDecimalNumber decimalNumberWithString:string]];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                        }

                        case sbjson_token_real: {
                            NSString *string = [[NSString alloc] initWithBytes:token length:token_len encoding:NSUTF8StringEncoding];
                            [delegate parser:self foundNumber:[NSDecimalNumber decimalNumberWithString:string]];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                        }

                        case sbjson_token_string: {
                            NSString *string = [[NSString alloc] initWithBytes:token length:token_len encoding:NSUTF8StringEncoding];
                            if ([state needKey])
                                [delegate parser:self foundObjectKey:string];
                            else
                                [delegate parser:self foundString:string];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                        }

                        case sbjson_token_encoded: {
                            NSString *string = [self decodeStringToken:token length:token_len];
                            if ([state needKey])
                                [delegate parser:self foundObjectKey:string];
                            else
                                [delegate parser:self foundString:string];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                        }

                        default:
                            break;
                    }
                    break;
            }
        }
        return SBJsonStreamParserComplete;
    }
}

- (unichar)decodeHexQuad:(char *)quad {
    unichar ch = 0;
    for (NSUInteger i = 0; i < 4; i++) {
        int c = quad[i];
        ch *= 16;
        switch (c) {
            case '0' ... '9': ch += c - '0'; break;
            case 'a' ... 'f': ch += 10 + c - 'a'; break;
            case 'A' ... 'F': ch += 10 + c - 'A'; break;
            default: @throw @"FUT FUT FUT";
        }
    }
    return ch;
}

- (NSString*)decodeStringToken:(char*)bytes length:(NSUInteger)len {
    NSMutableString *string = [NSMutableString stringWithCapacity:len];

    for (NSUInteger i = 0; i < len;) {
        switch (bytes[i]) {
            case '\\': {
                switch (bytes[++i]) {
                    case '"': [string appendString:@"\""]; i++; break;
                    case '/': [string appendString:@"/"]; i++; break;
                    case '\\': [string appendString:@"\\"]; i++; break;
                    case 'b': [string appendString:@"\b"]; i++; break;
                    case 'f': [string appendString:@"\f"]; i++; break;
                    case 'n': [string appendString:@"\n"]; i++; break;
                    case 'r': [string appendString:@"\r"]; i++; break;
                    case 't': [string appendString:@"\t"]; i++; break;
                    case 'u': {
                        unichar hi = [self decodeHexQuad:bytes + i + 1];
                        i += 5;
                        if (SBStringIsSurrogateHighCharacter(hi)) {
                            // Skip past \u that we know is there..
                            unichar lo = [self decodeHexQuad:bytes + i + 2];
                            i += 6;
                            [string appendFormat:@"%C%C", hi, lo];
                        } else {
                            [string appendFormat:@"%C", hi];
                        }
                        break;
                    }
                    default: @throw @"FUT FUT FUT";
                }
                break;
            }
            default: [string appendFormat:@"%c", bytes[i++]]; break;
        }
    }
    return string;
}

@end
