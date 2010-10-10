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

static NSMutableCharacterSet *kEscapeChars;

@interface SBJsonEventStreamWriter ()

@property NSString *error;

- (void)writeElementSeparator;
- (void)write:(char const *)utf8 len:(NSUInteger)len;

@end


@implementation SBJsonEventStreamWriter

@dynamic keyValueSeparator;
@synthesize error;

+ (void)initialize {
	kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
	[kEscapeChars addCharactersInString: @"\"\\"];
}

#pragma mark Housekeeping

- (id)initWithStream:(NSOutputStream*)stream_ {
	self = [super init];
	if (self) {
		stream = [stream_ retain];
		self.keyValueSeparator = ":";
	}
	return self;
}

- (void)dealloc {
	[stream release];
	[super dealloc];
}

#pragma mark Private methods

- (void)write:(char const *)utf8 len:(NSUInteger)len {
	NSUInteger written = 0;
	do {
		NSInteger w = [stream write:(const uint8_t *)utf8 maxLength:len - written];
		if (w == -1)
			NSLog(@"Failed writing to stream");
		else if (w == 0)
			NSLog(@"Not enough space in stream");
		if (w > 0)
			written += w;
	} while (written < len);
}

- (void)writeElementSeparator {
	[self write:"," len:1];
}

#pragma mark Methods

- (void)writeDictionaryStart {
	[self write:"{" len:1];
}

- (BOOL)writeDictionaryKey:(NSString*)key {
	
	if (![key isKindOfClass:[NSString class]]) {
		self.error = @"JSON object key must be string";
		return NO;
	}
	
	[self writeString:key];
	[self write:keyValueSeparator len:keyValueSeparatorLen];
	return YES;
}

- (void)writeDictionaryEnd {
	[self write:"}" len:1];
}

- (void)writeArrayStart {
	[self write:"[" len:1];
}

- (void)writeArrayEnd {
	[self write:"]" len:1];
}

//TODO: Make this more efficient
- (void)writeString:(NSString*)string {
	
	// Special case for empty string.
	if (![string length]) {
		[self write:"\"\"" len:2];
		return;
	}

	[self write:"\"" len:1];
    
    NSRange esc = [string rangeOfCharacterFromSet:kEscapeChars];
    if (!esc.length) {
		const char *utf8 = [string UTF8String];
		[self write:utf8 len:strlen(utf8)];
        
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
			[self write:c len:strlen(c)];
        }
    }
    
	[self write:"\"" len:1];
}

- (BOOL)writeNumber:(NSNumber*)number {
	if ((CFBooleanRef)number == kCFBooleanTrue)
		[self writeTrue];

	else if ((CFBooleanRef)number == kCFBooleanFalse)
		[self writeFalse];

	else if ((CFNumberRef)number == kCFNumberNaN || [number isEqualToNumber:[NSDecimalNumber notANumber]]) {
		self.error = @"NaN is not a valid number in JSON";
		return NO;
	}
	else if ((CFNumberRef)number == kCFNumberPositiveInfinity) {
		self.error = @"+Infinity is not a valid number in JSON";
		return NO;
	}
	else if ((CFNumberRef)number == kCFNumberNegativeInfinity) {
		self.error = @"-Infinity is not a valid number in JSON";
		return NO;
	}
	else {
		// TODO: There's got to be a better way to do this.
		char const *utf8 = [[number stringValue] UTF8String];
		[self write:utf8 len:strlen(utf8)];
	}
	return YES;
}

- (void)writeTrue {
	[self write:"true" len:4];
}

- (void)writeFalse {
	[self write:"false" len:5];
}

- (void)writeBool:(BOOL)x {
	if (x)
		[self writeTrue];
	else
		[self writeFalse];
}

- (void)writeNull {
	[self write:"null" len:4];
}

- (void)writeSpaces:(NSUInteger)count {
	// This is hardly high-performing code, but it
	// probably doesn't matter when we're just injecting whitespace
	// to make the file human-readable.
	for (int i = 0; i < count; i++)
		[self write:" " len:1];
}

- (void)writeNewline {
	[self write:"\n" len:1];
}


- (void)setKeyValueSeparator:(char const *)c {
	keyValueSeparator = c;
	keyValueSeparatorLen = strlen(c);
}
	
	

@end
