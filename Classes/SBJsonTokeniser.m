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

#import "SBJsonTokeniser.h"


#define isDigit(x) (*x >= '0' && *x <= '9')
#define skipDigits(x) while (isDigit(x)) x++


@interface SBJsonTokeniser ()

@property (copy) NSString *error;

- (const char *)bytes;
- (void)skipWhitespace;

- (sbjson_token_t)match:(const char *)utf8 ofLength:(NSUInteger)len andReturn:(sbjson_token_t)tok;
- (sbjson_token_t)matchString;
- (sbjson_token_t)matchNumber;

@end


@implementation SBJsonTokeniser

@synthesize error;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		offset = length = 0;
		buf = [[NSMutableData alloc] initWithCapacity:4096];
	}
	return self;
}

- (void)dealloc {
	[buf release];
	[super dealloc];
}

#pragma mark Methods

- (void)appendData:(NSData *)data {
	
	// Remove previous NUL char
	if (buf.length)
		buf.length = buf.length - 1;
	
	if (offset) {
		// Remove stuff in the front of the offset
		[buf replaceBytesInRange:NSMakeRange(0, offset) withBytes:"" length:0];
		offset = 0;
	}
		
	[buf appendData:data];
	
	// Append NUL byte to simplify logic
	[buf appendBytes:"\0" length:1];
}

- (BOOL)getToken:(const char **)utf8 length:(NSUInteger *)len {
	if (!length)
		return NO;
	
	*len = length;
	*utf8 = [self bytes];
	return YES;
}

- (sbjson_token_t)next {
	offset += length;
	length = 0;

	[self skipWhitespace];
	
	switch (*[self bytes]) {
		case '\0':
			return sbjson_token_eof;
			break;
			
		case '[':
			length = 1;
			return sbjson_token_array_start;
			break;
			
		case ']':
			length = 1;
			return sbjson_token_array_end;
			break;
			
		case '{':
			length = 1;
			return sbjson_token_object_start;
			break;
			
		case ':':
			length = 1;
			return sbjson_token_key_value_separator;
			break;
			
		case '}':
			length = 1;
			return sbjson_token_object_end;
			break;
			
		case ',':
			length = 1;
			return sbjson_token_separator;
			break;
			
		case 'n':
			return [self match:"null" ofLength:4 andReturn:sbjson_token_null];
			break;
			
		case 't':
			return [self match:"true" ofLength:4 andReturn:sbjson_token_true];
			break;

		case 'f':
			return [self match:"false" ofLength:5 andReturn:sbjson_token_false];
			break;

		case '"':
			return [self matchString];
			break;
			
		case '-':
		case '0' ... '9':
			return [self matchNumber];
			break;			
			
		case '+':
			self.error = [NSString stringWithFormat:@"Leading + is illegal in numbers at offset %u", offset];
			return sbjson_token_error;
			break;			
	}
	
	self.error = [NSString stringWithFormat:@"Unrecognised leading char at offset %u", offset];
	return sbjson_token_error;
}

#pragma mark Private methods

- (const char *)bytes {
	if (offset == buf.length)
		return ""; // dereferencing this sees the NUL byte.
	
	return (const char *)[buf bytes] + offset;
}

- (void)skipWhitespace {
	const char *b = [self bytes];
	
	for (;;) {
		switch (*b++) {
			case ' ':
			case '\t':
			case '\n':
			case '\r':
			case '\f':
			case '\v':
				offset++;
				break;
			default:
				return;
				break;
		}
	}
}

- (sbjson_token_t)match:(const char *)utf8 ofLength:(NSUInteger)len andReturn:(sbjson_token_t)tok {
	if (buf.length - offset < len)
		return sbjson_token_eof;
	
	if (strncmp([self bytes], utf8, len)) {
		NSString *format = [NSString stringWithFormat:@"Expected '%%s' but found '%%.%us'.", len];
		self.error = [NSString stringWithFormat:format, utf8, [self bytes]];
		return sbjson_token_error;
	}
	
	length = len;
	return tok;
}

- (sbjson_token_t)matchString {
	const char *c = [self bytes] + 1;
	sbjson_token_t ret = sbjson_token_string;
	
	for (;;) {
		switch (*c++) {
			case '\\':
				ret = sbjson_token_string_encoded;
				switch (*c++) {
					case 'b':
					case 't':
					case 'n':
					case 'r':
					case 'f':
					case 'v':
					case '"':
					case '\\':
					case '/':
						// Valid escape sequence
						break;
					case 'u':
						for (int i = 0; i < 4; i++) {
							if (!isDigit(c)) {
								self.error = [NSString stringWithFormat:@"Broken unichar sequence in token at offset %u", offset];
								return sbjson_token_error;
							}
							c++;
						}
						break;
					default:
						self.error = [NSString stringWithFormat:@"Broken escape character in token starting at offset %u", offset];
						return sbjson_token_error;
						break;
				}
				break;
			case '"':
				length = c - [self bytes];
				return ret;
				break;
			default:
				// any other character
				break;
		}
	}

	NSAssert(NO, @"Should never get here");
	return sbjson_token_error;
}

- (sbjson_token_t)matchNumber {

	sbjson_token_t ret = sbjson_token_integer;
	const char *c = [self bytes];

	if (*c == '-')
		c++;
	
	if (*c == '0') {
		c++;
		if (isDigit(c)) {
			self.error = [NSString stringWithFormat:@"Leading zero is disallowed in number at offset %u", offset];
			return sbjson_token_error;
		}
	}
	
	skipDigits(c);
	
	
	if (*c == '.') {
		ret = sbjson_token_double;
		c++;
		
		if (!isDigit(c) && *c) {
			self.error = [NSString stringWithFormat:@"Number cannot end with '.' at offset %u", offset];
			return sbjson_token_error;
		}
		
		skipDigits(c);
	}
	
	if (*c == 'e' || *c == 'E') {
		ret = sbjson_token_double;
		c++;
		
		if (*c == '-' || *c == '+')
			c++;
	
		if (!isDigit(c) && *c) {
			self.error = [NSString stringWithFormat:@"Exponential marker must be followed by digits at offset %u", offset];
			return sbjson_token_error;
		}
		
		skipDigits(c);
	}
	
	if (!*c)
		return sbjson_token_eof;
	
	length = c - [self bytes];
	return ret;
}

@end
