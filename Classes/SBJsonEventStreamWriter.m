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

#import "SBJsonEventStreamWriter.h"

static const uint8_t Null[] = "null";
static const uint8_t True[] = "true";
static const uint8_t False[] = "false";
static const uint8_t Newline[] = "\n";
static const uint8_t Space[] = " ";
static const uint8_t DictionaryStart[] = "{";
static const uint8_t DictionaryEnd[] = "}";
static const uint8_t ArrayStart[] = "[";
static const uint8_t ArrayEnd[] = "]";
static const uint8_t ElementSeparator[] = ",";

static NSMutableCharacterSet *kEscapeChars;


@interface SBJsonEventStreamWriter ()

- (void)writeElementSeparator;

@end


@implementation SBJsonEventStreamWriter

@synthesize keyValueSeparator;

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
	}
	return self;
}

- (void)dealloc {
	[stream release];
	[super dealloc];
}

#pragma mark Methods

- (void)writeDictionaryStart {
	[stream write:DictionaryStart maxLength:sizeof DictionaryStart-1];
}

- (void)writeDictionaryKey:(NSString*)key {
	[self writeString:key];
	[stream write:(uint8_t const *)keyValueSeparator maxLength:strlen(keyValueSeparator)];
}

- (void)writeDictionaryEnd {
	[stream write:DictionaryEnd maxLength:sizeof DictionaryEnd-1];
}

- (void)writeArrayStart {
	[stream write:ArrayStart maxLength:sizeof ArrayStart-1];
}

- (void)writeArrayEnd {
	[stream write:ArrayEnd maxLength:sizeof ArrayEnd-1];
}

- (void)writeString:(NSString*)string {
	
	// Special case for empty string.
	if (![string length]) {
		[stream write:(const uint8_t *)"\"\"" maxLength:2];
		return;
	}
	
	[stream write:(const uint8_t*)"\"" maxLength:1];
    
    NSRange esc = [string rangeOfCharacterFromSet:kEscapeChars];
    if (!esc.length) {
		const char *utf8 = [string UTF8String];
		[stream write:(const uint8_t *)utf8 maxLength:strlen(utf8)];
        
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
			[stream write:(const uint8_t *)c maxLength:strlen(c)];
        }
    }
    
	[stream write:(const uint8_t*)"\"" maxLength:1];
}

- (void)writeNumber:(NSNumber*)number {
	if ((CFBooleanRef)number == kCFBooleanTrue)
		[self writeBool:YES];
	else if ((CFBooleanRef)number == kCFBooleanFalse)
		[self writeBool:NO];
	else if ((CFNumberRef)number == kCFNumberNaN)
		@throw @"NaN is not a valid number in JSON";
	else if ((CFNumberRef)number == kCFNumberPositiveInfinity)
		@throw @"+Infinity is not valid in JSON";
	else if ((CFNumberRef)number == kCFNumberNegativeInfinity)
		@throw @"-Infinity is not valid in JSON";
	else {
		// TODO: There's got to be a better way to do this.
		char const *utf8 = [[number stringValue] UTF8String];
		[stream write:(const uint8_t *)utf8 maxLength:strlen(utf8)];
	}
}

- (void)writeBool:(BOOL)x {
	if (x)
		[stream write:True maxLength:sizeof True-1];
	else
		[stream write:False maxLength:sizeof False-1];
}

- (void)writeNull {
	[stream write:Null maxLength:sizeof Null-1];
}

- (void)writeElementSeparator {
	[stream write:ElementSeparator maxLength:sizeof ElementSeparator-1];
}

- (void)writeSpaces:(NSUInteger)count {
	// This is hardly high-performing code, but it
	// probably doesn't matter when we're just injecting whitespace
	// to make the file human-readable.
	for (int i = 0; i < count; i++)
		[stream write:Space maxLength:1];
}

- (void)writeNewline {
	[stream write:Newline maxLength:1];
}


@end
