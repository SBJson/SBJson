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

#import "SBJsonStreamWriter.h"
#import "SBProxyForJson.h"

static NSMutableCharacterSet *kEscapeChars;

#define maxDepthCheck()	\
	do {																	\
		if (maxDepth && ++depth > maxDepth) {								\
			[self addErrorWithCode:EDEPTH description:@"Nested too deep"];	\
			return NO;														\
		}																	\
	} while (0)

#define humanReadable()	\
	do {											\
		if (humanReadable) {						\
			writeToStream("\n", 1);					\
			for (int i = 0; i < 2 * depth; i++)		\
				writeToStream(" ", 1);				\
		}											\
	} while (0)

#define writeToStream(utf8, lenExp) \
	do {																					\
		NSUInteger len = lenExp;															\
		NSUInteger written = 0;																\
		do {																				\
			NSInteger w = [stream write:(const uint8_t *)utf8 maxLength:len - written];		\
			if (w > 0)																		\
				written += w;																\
			else if (w == -1)																\
				NSLog(@"Failed writing to stream");											\
			else if (w == 0)																\
				NSLog(@"Not enough space in stream");										\
			} while (written < len);														\
	} while(0)

@interface SBJsonStreamWriter ()

- (void)writeString:(NSString*)string;
- (BOOL)writeNumber:(NSNumber*)number;

@end


@implementation SBJsonStreamWriter

@synthesize sortKeys;
@dynamic humanReadable;

+ (void)initialize {
	kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
	[kEscapeChars addCharactersInString: @"\"\\"];
}

#pragma mark Housekeeping

- (id)initWithStream:(NSOutputStream*)stream_ {
	self = [super init];
	if (self) {
		stream = [stream_ retain];
		keyValueSeparator = ":";
		keyValueSeparatorLen = 1;
	}
	return self;
}

- (void)dealloc {
	[stream release];
	[super dealloc];
}

#pragma mark Methods

- (BOOL)write:(id)object {
	if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
		return [self writeValue:object];
	}
	
	if ([object respondsToSelector:@selector(proxyForJson)]) {
		return [self write:[object proxyForJson]];

	}
	
	[self addErrorWithCode:EUNSUPPORTED description:@"Not valid type for JSON"];
	return NO;
}

#pragma mark SBJsonStreamEvents

- (BOOL)writeValue:(id)o {
	if ([o isKindOfClass:[NSDictionary class]]) {
		return [self writeDictionary:o];

	} else if ([o isKindOfClass:[NSArray class]]) {
		return [self writeArray:o];

	} else if ([o isKindOfClass:[NSString class]]) {
		[self writeString:o];

	} else if ([o isKindOfClass:[NSNumber class]]) {
		return [self writeNumber:o];

	} else if ([o isKindOfClass:[NSNull class]]) {
		writeToStream("null", 4);
	} else if ([o respondsToSelector:@selector(proxyForJson)]) {
		return [self writeValue:[o proxyForJson]];

	} else {
		[self addErrorWithCode:EUNSUPPORTED
				   description:[NSString stringWithFormat:@"JSON serialisation not supported for @%", [o class]]];
		return NO;
	}
	return YES;
}

- (BOOL)writeDictionary:(NSDictionary*)dict {
	maxDepthCheck();

	writeToStream("{", 1);	
	NSArray *keys = [dict allKeys];
	if (self.sortKeys)
		keys = [keys sortedArrayUsingSelector:@selector(compare:)];
	
	BOOL doSep = NO;
	for (id key in keys) {
		if (doSep)
			writeToStream(",", 1);
		else
			doSep = YES;

		humanReadable();
		
		if (![key isKindOfClass:[NSString class]]) {
			[self addErrorWithCode:EUNSUPPORTED description: @"JSON object key must be string"];
			return NO;
		}
		
		[self writeString:key];
		writeToStream(keyValueSeparator, keyValueSeparatorLen);		
		if (![self writeValue:[dict objectForKey:key]])
			return NO;
	}
	
	depth--;

	if ([dict count])
		humanReadable();

	writeToStream("}", 1);
	return YES;
}

- (BOOL)writeArray:(NSArray*)array {
	maxDepthCheck();

	writeToStream("[", 1);
	BOOL doSep = NO;
	for (id value in array) {
		if (doSep)
			writeToStream(",", 1);		else
			doSep = YES;

		humanReadable();
		if (![self writeValue:value])
			return NO;
	}
	
	depth--;
	
	if ([array count])
		humanReadable();
	
	writeToStream("]", 1);
	return YES;
}


- (void)writeArrayStart {
	writeToStream("[", 1);
}

- (void)writeArrayEnd {
	writeToStream("]", 1);
}

//TODO: Make this more efficient
- (void)writeString:(NSString*)string {
	
	// Special case for empty string.
	if (![string length]) {
		writeToStream("\"\"", 2);
		return;
	}
	
	writeToStream("\"", 1);    
    NSRange esc = [string rangeOfCharacterFromSet:kEscapeChars];
    if (!esc.length) {
		const char *utf8 = [string UTF8String];
		writeToStream(utf8, strlen(utf8));
		
    } else {
        NSUInteger length = [string length];
        for (NSUInteger i = 0; i < length; i++) {
            unichar uc = [string characterAtIndex:i];
			char const *c;
            switch (uc) {
                case '"':  c = "\\\""; break;
                case '\\': c = "\\\\"; break;
                case '\t': c = "\\t"; break;
                case '\n': c = "\\n"; break;
                case '\r': c = "\\r"; break;
                case '\b': c = "\\b"; break;
                case '\f': c = "\\f"; break;
                default:    
                    if (uc < 0x20) {
                        c = [[NSString stringWithFormat:@"\\u%04x", uc] UTF8String];
                    } else {
						c = [[NSString stringWithCharacters:&uc length:1] UTF8String];
                    }
                    break;                    
            }
			writeToStream(c, strlen(c));
        }
    }
    
	writeToStream("\"", 1);
}

- (BOOL)writeNumber:(NSNumber*)number {
	if ((CFBooleanRef)number == kCFBooleanTrue)
		writeToStream("true", 4);
	else if ((CFBooleanRef)number == kCFBooleanFalse)
		writeToStream("false", 5);
	else if ((CFNumberRef)number == kCFNumberNaN || [number isEqualToNumber:[NSDecimalNumber notANumber]]) {
		[self addErrorWithCode:EUNSUPPORTED description:@"NaN is not a valid number in JSON"];
		return NO;
	}
	else if ((CFNumberRef)number == kCFNumberPositiveInfinity) {
		[self addErrorWithCode:EUNSUPPORTED description:@"+Infinity is not a valid number in JSON"];
		return NO;
	}
	else if ((CFNumberRef)number == kCFNumberNegativeInfinity) {
		[self addErrorWithCode:EUNSUPPORTED description:@"-Infinity is not a valid number in JSON"];
		return NO;
	}
	else {
		// TODO: There's got to be a better way to do this.
		char const *utf8 = [[number stringValue] UTF8String];
		writeToStream(utf8, strlen(utf8));
	}
	return YES;
}

#pragma mark Properties

- (void)setHumanReadable:(BOOL)x {
	humanReadable = x;
	keyValueSeparator = x ? " : " : ":";
	keyValueSeparatorLen = strlen(keyValueSeparator);
}

@end
