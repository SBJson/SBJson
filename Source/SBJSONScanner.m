/*
Copyright (C) 2008 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
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

#import "SBJSONScanner.h"

@interface SBJSONScanner (Private)

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

- (void)log:(NSString *)x;

@end

NSString *const enocomma  = @"enocomma";
NSString *const enocolon  = @"enocolon";
NSString *const enostring = @"enostring";
NSString *const enovalue  = @"enovalue";
NSString *const enojson   = @"enojson";
NSString *const etoodeep  = @"depth";

NSString *const etrue   = @"etrue";
NSString *const efalse  = @"efalse";
NSString *const enull   = @"enull";
NSString *const enumber = @"enumber";
NSString *const estring = @"estring";
NSString *const evalue  = @"evalue";

#define skipWhitespace(c) while (isspace(*c)) c++
#define skipDigits(c) while (isdigit(*c)) c++

@implementation SBJSONScanner

static char ctrl[0x22];

+ (void)initialize
{
    ctrl[0] = '\"';
    ctrl[1] = '\\';
    for (int i = 1; i < 0x20; i++)
        ctrl[i+1] = i;
    ctrl[0x21] = 0;    
}

- (id)initWithString:(NSString *)s
{
    if (self = [super init]) {
        start = c = [s UTF8String];
        depth = 0;
        [self setMaxDepth:512];
    }
    return self;
}

- (void)setMaxDepth:(unsigned)x
{
    maxDepth = x;
}

- (void)raise:(NSString *)e format:(NSString *)msg
{
    const char *snippet = c - 8;
    if (snippet < start)
        snippet = start;
    [NSException raise:e format:@"%@ at %.16s", msg, snippet];
}

- (BOOL)isAtEnd
{
    skipWhitespace(c);
    return !*c;
}

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
        default:
            c--;
            [self raise:enovalue format:@"Unrecognised leading character"];
            return NO;
            break;
    }
}

- (BOOL)scanRestOfTrue:(NSNumber **)o
{
    if (!strncmp(c, "rue", 3)) {
        c += 3;
        *o = [NSNumber numberWithBool:YES];
        return YES;
    }
    [self raise:etrue format:@"Expected 'true'"];
    return NO;
}

- (BOOL)scanRestOfFalse:(NSNumber **)o
{
    if (!strncmp(c, "alse", 4)) {
        c += 4;
        *o = [NSNumber numberWithBool:NO];
        return YES;
    }
    [self raise:efalse format:@"Expected 'false'"];
    return NO;
}

- (BOOL)scanRestOfNull:(NSNull **)o
{
    if (!strncmp(c, "ull", 3)) {
        c += 3;
        *o = [NSNull null];
        return YES;
    }
    [self raise:enull format:@"Expected 'null'"];
    return NO;
}

- (BOOL)scanArray:(NSArray **)o
{
    skipWhitespace(c);
    if (*c == '[' && c++)
        return [self scanRestOfArray:(NSMutableArray **)o];
    return NO;
}

- (BOOL)scanRestOfArray:(NSMutableArray **)o
{
    if (maxDepth && ++depth > maxDepth)
        [self raise:etoodeep format:@"Nested too deep"];
    
    *o = [NSMutableArray arrayWithCapacity:8];
    
    skipWhitespace(c);
    if (*c == ']' && c++) {
        depth--;
        return YES;
    }
    
    do {
        id v;
        if (![self scanValue:&v])
            [self raise:enovalue format:@"Expected value while parsing array"];
        
        [*o addObject:v];
        
        skipWhitespace(c);
        if (*c == ']' && c++) {
            depth--;
            return YES;
        }
        
    } while (*c == ',' && c++);

    [self raise:enocomma format:@"Expected , or ] while parsing array"];
}

- (BOOL)scanDictionary:(NSDictionary **)o
{
    skipWhitespace(c);
    if (*c == '{' && c++)
        return [self scanRestOfDictionary:(NSMutableDictionary **)o];
    return NO;
}


- (BOOL)scanRestOfDictionary:(NSMutableDictionary **)o
{
    if (maxDepth && ++depth > maxDepth)
        [self raise:etoodeep format:@"Nested too deep"];

    *o = [NSMutableDictionary dictionaryWithCapacity:7];
    
    skipWhitespace(c);
    if (*c == '}' && c++) {
        depth--;
        return YES;
    }    
    
    do {
        id k, v;

        skipWhitespace(c);
        if (!(*c == '\"' && c++ && [self scanRestOfString:&k]))
            [self raise:enostring format:@"Expected string for dictionary key"];
        
        skipWhitespace(c);
        if (*c != ':')
            [self raise:enocolon format:@"Expected ':' separating dictionary pair"];

        c++;
        if (![self scanValue:&v])
            [self raise:enovalue format:@"Expected value part of dictionary pair"];

        [*o setObject:v forKey:k];

        skipWhitespace(c);
        if (*c == '}' && c++) {
            depth--;
            return YES;
        }
        
    } while (*c == ',' && c++);
    
    [self raise:enocomma format:@"Expected , or } while parsing dictionary"];
}

- (BOOL)scanRestOfString:(NSMutableString **)o
{
    *o = [NSMutableString stringWithCapacity:16];
    do {
        // First see if there's a portion we can grab in one go. 
        // Doing this caused a massive speedup on the long string.
        size_t len = strcspn(c, ctrl);
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
                        [self raise:estring format:@"Broken unicode escape sequence"];
                        return NO;
                    }
                    c--; // hack.
                    break;
                default:
                    [self raise:estring format:[NSString stringWithFormat:@"Found illegal escape sequence '0x%x'", uc]];
                    return NO;
                    break;
            }
            [*o appendFormat:@"%C", uc];
            c++;

        } else if (*c < 0x20) {
            [self raise:estring format:[NSString stringWithFormat:@"Found unescaped control character '0x%x'", *c]];
            return NO;

        } else {
            NSLog(@"should not be able to get here");
        }
    } while (*c);
    
    [self raise:estring format:@"Unexpected EOF while parsing string"];
    return NO;
}

- (BOOL)scanUnicodeChar:(unichar *)x
{
    unichar hi, lo;
    
    if (![self scanHexQuad:&hi])
        return NO;
    
    if (hi >= 0xd800) {     // high surrogate char?
        if (hi < 0xdc00) {  // yes - expect a low char
            
            if (!(*c == '\\' && ++c && *c == 'u' && ++c && [self scanHexQuad:&lo]))
                [self raise:@"no_low_surrogate_char" format:@"Missing low character in surrogate pair"];
            
            if (lo < 0xdc00 || lo >= 0xdfff) 
                [self raise:@"expected_low_surrogate" format:@"Expected low surrogate char"];
            
            hi = (hi - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000;
            
        } else if (hi < 0xe000) {
            [self raise:@"no_high_surrogate_char" format:@"Missing high character in surrogate pair"];
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
        if (d == -1)
            return NO;
        *x *= 16;
        *x += d;
    }
    return YES;
}

- (BOOL)scanNumber:(NSNumber **)o
{
    const char *ns = c;
    
    // The logic to test for validity of the number formatting is relicensed
    // from JSON::XS with permission from its author Marc Lehmann.
    // (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)

    if ('-' == *c)
        c++;

    if ('0' == *c && c++) {        
        if (isdigit(*c)) {
            [self raise:enumber format:@"Found illegal leading zero in number"];
            return NO;
        }

    } else if (!isdigit(*c) && c != ns) {
        [self raise:enumber format:@"No digits after initial minus"];
        return NO;
        
    } else {
        skipDigits(c);
    }
    
    // Fractional part
    if ('.' == *c && c++) {
        
        if (!isdigit(*c)) {
            [self raise:enumber format:@"No digits after decimal point"];
            return NO;
        }        
        skipDigits(c);
    }
    
    // Exponential part
    if ('e' == *c || 'E' == *c) {
        c++;
        
        if ('-' == *c || '+' == *c)
            c++;
        
        if (!isdigit(*c)) {
            [self raise:enumber format:@"No digits after exponent"];
            return NO;
        }
        skipDigits(c);
    }
    
    id str = [[NSString alloc] initWithBytesNoCopy:(char*)ns
                                            length:c - ns
                                          encoding:NSUTF8StringEncoding
                                      freeWhenDone:NO];
    [str autorelease];
    if (str && (*o = [NSDecimalNumber decimalNumberWithString:str]))
        return YES;
    
    [self raise:enumber format:@"Failed creating decimal instance"];
    return NO;
}

@end
