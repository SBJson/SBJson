/*
 Copyright (C) 2009,2010 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SBJsonParser.h"

@interface SBJsonParser ()

- (BOOL)scanValue:(NSObject **)o;

- (BOOL)scanRestOfArray:(NSMutableArray **)o;
- (BOOL)scanRestOfDictionary:(NSMutableDictionary **)o;
- (BOOL)scanRestOfNull:(NSNull **)o;
- (BOOL)scanRestOfFalse:(NSNumber **)o;
- (BOOL)scanRestOfTrue:(NSNumber **)o;
- (BOOL)scanRestOfString:(NSMutableString **)o;

// Cannot manage without looking at the first digit
- (BOOL)scanNumber:(NSNumber **)o;

- (BOOL)scanHexQuad:(unichar *)x;
- (BOOL)scanUnicodeChar:(unichar *)x;

- (BOOL)scanIsAtEnd;

@end

#define skipWhitespace(c) while (isspace(*c)) c++
#define skipDigits(c) while (isdigit(*c)) c++


@implementation SBJsonParser

@synthesize error;
@synthesize maxDepth;

static char ctrl[0x22];


+ (void)initialize {
    ctrl[0] = '\"';
    ctrl[1] = '\\';
    for (int i = 1; i < 0x20; i++)
        ctrl[i+1] = i;
    ctrl[0x21] = 0;    
}

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 512;
    return self;
}

- (void)dealloc {
    [error release];
    [super dealloc];
}


- (id)objectWithString:(NSString *)repr {
	self.error = nil;
	
    if (!repr) {
		self.error = @"Input was 'nil'";
        return nil;
    }
    
    depth = 0;
    c = [repr UTF8String];
    
    id o;
    if (![self scanValue:&o]) {
        return nil;
    }
    
    // We found some valid JSON. But did it also contain something else?
    if (![self scanIsAtEnd]) {
		self.error = @"Garbage after JSON";
        return nil;
    }
    
    NSAssert1(o, @"Should have a valid object from %@", repr);
    
    // Check that the object we've found is a valid JSON container.
    if (![o isKindOfClass:[NSDictionary class]] && ![o isKindOfClass:[NSArray class]]) {
		self.error = @"Valid fragment, but not JSON";
        return nil;
    }
    
    return o;
}

- (id)objectWithString:(NSString*)repr error:(NSError**)error_ {
    id tmp = [self objectWithString:repr];
    if (tmp)
        return tmp;
    
    if (error_) {
		NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        *error_ = [NSError errorWithDomain:@"org.brautaset.json.parser.ErrorDomain" code:0 userInfo:ui];
	}
	
    return nil;
}


/*
 In contrast to the public methods, it is an error to omit the error parameter here.
 */
- (BOOL)scanValue:(NSObject **)o
{
    skipWhitespace(c);
    
    switch (*c++) {
        case '{':
            return [self scanRestOfDictionary:(NSMutableDictionary **)o];
            break;
        case '[':
            return [self scanRestOfArray:(NSMutableArray **)o];
            break;
        case '"':
            return [self scanRestOfString:(NSMutableString **)o];
            break;
        case 'f':
            return [self scanRestOfFalse:(NSNumber **)o];
            break;
        case 't':
            return [self scanRestOfTrue:(NSNumber **)o];
            break;
        case 'n':
            return [self scanRestOfNull:(NSNull **)o];
            break;
        case '-':
        case '0'...'9':
            c--; // cannot verify number correctly without the first character
            return [self scanNumber:(NSNumber **)o];
            break;
        case '+':
			if (!error) self.error = @"Leading + disallowed in number";
            return NO;
            break;
        case 0x0:
			if (!error) self.error = @"Unexpected end of string";
            return NO;
            break;
        default:
			if (!error) self.error = @"Unrecognised leading character";
            return NO;
            break;
    }
    
    NSAssert(0, @"Should never get here");
    return NO;
}

- (BOOL)scanRestOfTrue:(NSNumber **)o
{
    if (!strncmp(c, "rue", 3)) {
        c += 3;
        *o = [NSNumber numberWithBool:YES];
        return YES;
    }
	if (!error) self.error = @"Expected 'true'";
    return NO;
}

- (BOOL)scanRestOfFalse:(NSNumber **)o
{
    if (!strncmp(c, "alse", 4)) {
        c += 4;
        *o = [NSNumber numberWithBool:NO];
        return YES;
    }
    if (!error) self.error = @"Expected 'false'";
    return NO;
}

- (BOOL)scanRestOfNull:(NSNull **)o {
    if (!strncmp(c, "ull", 3)) {
        c += 3;
        *o = [NSNull null];
        return YES;
    }
	if (!error) self.error = @"Expected 'null'";
    return NO;
}

- (BOOL)scanRestOfArray:(NSMutableArray **)o {
    if (maxDepth && ++depth > maxDepth) {
        if (!error) self.error = @"Nested too deep";
        return NO;
    }
    
    *o = [NSMutableArray arrayWithCapacity:8];
    
    for (; *c ;) {
        id v;
        
        skipWhitespace(c);
        if (*c == ']' && c++) {
            depth--;
            return YES;
        }
        
        if (![self scanValue:&v]) {
			self.error = [NSString stringWithFormat:@"Expected value while parsing array (%@)", error];
            return NO;
        }
        
        [*o addObject:v];
        
        skipWhitespace(c);
        if (*c == ',' && c++) {
            skipWhitespace(c);
            if (*c == ']') {
				if (!error) self.error = @"Trailing comma disallowed in array";
                return NO;
            }
        }        
    }
    
	if (!error) self.error = @"End of input while parsing array";
    return NO;
}

- (BOOL)scanRestOfDictionary:(NSMutableDictionary **)o 
{
    if (maxDepth && ++depth > maxDepth) {
        if (!error) self.error = @"Nested too deep";
        return NO;
    }
    
    *o = [NSMutableDictionary dictionaryWithCapacity:7];
    
    for (; *c ;) {
        id k, v;
        
        skipWhitespace(c);
        if (*c == '}' && c++) {
            depth--;
            return YES;
        }    
        
        if (!(*c == '\"' && c++ && [self scanRestOfString:&k])) {
			if (!error) self.error = @"Object key string expected";
            return NO;
        }
        
        skipWhitespace(c);
        if (*c != ':') {
			if (!error) self.error = @"Expected ':' separating key and value";
            return NO;
        }
        
        c++;
        if (![self scanValue:&v]) {
            self.error = [NSString stringWithFormat:@"Object value expected for key: %@ (%@)", k, error];
            return NO;
        }
        
        [*o setObject:v forKey:k];
        
        skipWhitespace(c);
        if (*c == ',' && c++) {
            skipWhitespace(c);
            if (*c == '}') {
				if (!error) self.error = @"Trailing comma disallowed in object";
                return NO;
            }
        }        
    }
    
	if (!error) self.error = @"End of input while parsing object";
    return NO;
}

- (BOOL)scanRestOfString:(NSMutableString **)o 
{
    // if the string has no control characters in it, return it in one go, without any temporary allocations.
    size_t len = strcspn(c, ctrl);
    if (len && *(c + len) == '\"')
    {
        *o = [[[NSMutableString alloc] initWithBytes:(char*)c length:len encoding:NSUTF8StringEncoding] autorelease];
        c += len + 1;
        return YES;
    }
    
    *o = [NSMutableString stringWithCapacity:16];
    do {
        // First see if there's a portion we can grab in one go. 
        // Doing this caused a massive speedup on the long string.
        len = strcspn(c, ctrl);
        if (len) {
            // check for 
            id t = [[NSString alloc] initWithBytesNoCopy:(char*)c
                                                  length:len
                                                encoding:NSUTF8StringEncoding
                                            freeWhenDone:NO];
            if (t) {
                [*o appendString:t];
                [t release];
                c += len;
            }
        }
        
        if (*c == '"') {
            c++;
            return YES;
            
        } else if (*c == '\\') {
            unichar uc = *++c;
            switch (uc) {
                case '\\':
                case '/':
                case '"':
                    break;
                    
                case 'b':   uc = '\b';  break;
                case 'n':   uc = '\n';  break;
                case 'r':   uc = '\r';  break;
                case 't':   uc = '\t';  break;
                case 'f':   uc = '\f';  break;                    
                    
                case 'u':
                    c++;
                    if (![self scanUnicodeChar:&uc]) {
						self.error = [NSString stringWithFormat:@"Broken unicode character (%@)", error];
                        return NO;
                    }
                    c--; // hack.
                    break;
                default:
					if (!error) self.error = [NSString stringWithFormat:@"Illegal escape sequence '0x%x'", uc];
                    return NO;
                    break;
            }
            CFStringAppendCharacters((CFMutableStringRef)*o, &uc, 1);
            c++;
            
        } else if (*c < 0x20) {
			if (!error) self.error = [NSString stringWithFormat:@"Unescaped control character '0x%x'", *c];
            return NO;
            
        } else {
            NSLog(@"should not be able to get here");
        }
    } while (*c);
    
	if (!error) self.error = @"Unexpected EOF while parsing string";
    return NO;
}

- (BOOL)scanUnicodeChar:(unichar *)x
{
    unichar hi, lo;
    
    if (![self scanHexQuad:&hi]) {
		if (!error) self.error = @"Missing hex quad";
        return NO;        
    }
    
    if (hi >= 0xd800) {     // high surrogate char?
        if (hi < 0xdc00) {  // yes - expect a low char
            
            if (!(*c == '\\' && ++c && *c == 'u' && ++c && [self scanHexQuad:&lo])) {
				if (!error) self.error = @"Missing low character in surrogate pair";
                return NO;
            }
            
            if (lo < 0xdc00 || lo >= 0xdfff) {
				if (!error) self.error = @"Invalid low surrogate char";
                return NO;
            }
            
            hi = (hi - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000;
            
        } else if (hi < 0xe000) {
			if (!error) self.error = @"Invalid high character in surrogate pair";
            return NO;
        }
    }
    
    *x = hi;
    return YES;
}

- (BOOL)scanHexQuad:(unichar *)x
{
    *x = 0;
    for (int i = 0; i < 4; i++) {
        unichar uc = *c;
        c++;
        int d = (uc >= '0' && uc <= '9')
        ? uc - '0' : (uc >= 'a' && uc <= 'f')
        ? (uc - 'a' + 10) : (uc >= 'A' && uc <= 'F')
        ? (uc - 'A' + 10) : -1;
        if (d == -1) {
			if (!error) self.error = @"Missing hex digit in quad";
            return NO;
        }
        *x *= 16;
        *x += d;
    }
    return YES;
}

- (BOOL)scanNumber:(NSNumber **)o
{
    BOOL simple = YES;
    
    const char *ns = c;
    
    // The logic to test for validity of the number formatting is relicensed
    // from JSON::XS with permission from its author Marc Lehmann.
    // (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)
    
    if ('-' == *c)
        c++;
    
    if ('0' == *c && c++) {        
        if (isdigit(*c)) {
			if (!error) self.error = @"Leading 0 disallowed in number";
            return NO;
        }
        
    } else if (!isdigit(*c) && c != ns) {
		if (!error) self.error = @"No digits after initial minus";
        return NO;
        
    } else {
        skipDigits(c);
    }
    
    // Fractional part
    if ('.' == *c && c++) {
        simple = NO;
        if (!isdigit(*c)) {
            if (!error) self.error = @"No digits after decimal point";
            return NO;
        }        
        skipDigits(c);
    }
    
    // Exponential part
    if ('e' == *c || 'E' == *c) {
        simple = NO;
        c++;
        
        if ('-' == *c || '+' == *c)
            c++;
        
        if (!isdigit(*c)) {
            if (!error) self.error = @"No digits after exponent";
            return NO;
        }
        skipDigits(c);
    }
    
    // If we are only reading integers, don't go through the expense of creating an NSDecimal.
    // This ends up being a very large perf win.
    if (simple) {
        BOOL negate = NO;
        long long val = 0;
        const char *d = ns;
        
        if (*d == '-') {
            negate = YES;
            d++;
        }
        
        while (isdigit(*d)) {
            val *= 10;
            if (val < 0)
                goto longlong_overflow;
            val += *d - '0';
            if (val < 0)
                goto longlong_overflow;
            d++;
        }
        
        *o = [NSNumber numberWithLongLong:negate ? -val : val];
        return YES;
        
    } else {
        // jumped to by simple branch, if an overflow occured
        longlong_overflow:;
        
        id str = [[NSString alloc] initWithBytesNoCopy:(char*)ns
                                                length:c - ns
                                              encoding:NSUTF8StringEncoding
                                          freeWhenDone:NO];
        [str autorelease];
        if (str && (*o = [NSDecimalNumber decimalNumberWithString:str locale:nil]))
            return YES;

        if (!error) self.error = @"Failed creating decimal instance";
        return NO;
    }
}

- (BOOL)scanIsAtEnd
{
    skipWhitespace(c);
    return !*c;
}


@end
