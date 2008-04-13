/*
Copyright (C) 2007 Stig Brautaset. All rights reserved.

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

#import "NSScanner+SBJSON.h"


@implementation NSScanner (NSScanner_SBJSON)

static void skipDigits(unichar *c, unsigned *loc, NSString *str)
{
    unsigned strlen = [str length];
    do {
        *c = ++*loc < strlen ? [str characterAtIndex:*loc] : 0;
    } while (*c >= '0' && *c <= '9');
}

static unichar skipWhitespace(unsigned *loc, NSString *str)
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    unsigned strlen = [str length];
    unichar c;
    do {
        c = *loc < strlen ? [str characterAtIndex:*loc] : 0;
    } while ([whitespace characterIsMember:c] && ++*loc);
    return c;
}

- (BOOL)scanJSONChar: (unichar)c
{
    unsigned loc = [self scanLocation];
    if (skipWhitespace(&loc, [self string]) == c) {
        [self setScanLocation: loc+1];
        return YES;
    } else
        return NO;
}

- (BOOL)scanJSONNull:(NSNull **)x
{
    if ([self scanString:@"null" intoString:nil]) {
        *x = [NSNull null];
        return YES;
    }
    return NO;
}

- (BOOL)scanJSONBool:(NSNumber **)x
{
    if ([self scanString:@"true" intoString:nil]) {
        *x = [NSNumber numberWithBool:YES];
        return YES;
    }
    if ([self scanString:@"false" intoString:nil]) {
        *x = [NSNumber numberWithBool:NO];
        return YES;
    }
    return NO;
}

- (BOOL)scanHexQuad:(unichar *)x
{
    *x = 0;
    NSString *s = [self string];
    unsigned loc = [self scanLocation];
    for (int i = 0; i < 4; i++) {
        unichar c = [s characterAtIndex:loc + i];
        int d = (c >= '0' && c <= '9') ? c - '0'
                : (c >= 'a' && c <= 'f') ? (c - 'a' + 10)
                    : (c >= 'A' && c <= 'F') ? (c - 'A' + 10)
                        : -1;
        if (d == -1)
            return NO;
        *x *= 16;
        *x += d;
    }
    [self setScanLocation:loc+4];
    return YES;
}

- (BOOL)scanJSONUnicodeChar:(unichar *)x
{
    unichar hi, lo;

    if (![self scanHexQuad:&hi])
        return NO;

    if (hi >= 0xd800) {     // high surrogate char?
        if (hi < 0xdc00) {  // yes - expect a low char
            if (!([self scanString:@"\\u" intoString:nil] && [self scanHexQuad:&lo]))
                [NSException raise:@"no_low_surrogate_char" format:@"Missing low character in surrogate pair"];

            if (lo < 0xdc00 || lo >= 0xdfff) 
                [NSException raise:@"expected_low_surrogate" format:@"Expected low surrogate char"];

            hi = (hi - 0xd800) * 0x400 + (lo - 0xdc00) + 0x10000;

        } else if (hi < 0xe000) {
            [NSException raise:@"no_high_surrogate_char" format:@"Missing high character in surrogate pair"];
        }
    }

    *x = hi;
    return YES;
}

static inline void appendCharacter( NSMutableString *dst, unichar c )
{
    CFStringAppendCharacters((CFMutableStringRef)dst, &c, 1);
}

static void appendSubstring( NSMutableString *dst, NSString *src, NSRange range )
{
    if ( range.length > 0 ) {
        unichar *buf = range.length < 200 ? alloca(range.length * sizeof(unichar))
                                          : malloc(range.length * sizeof(unichar));
        [src getCharacters: buf range: range];
        CFStringAppendCharacters((CFMutableStringRef)dst, buf, range.length);
        if ( range.length >= 200 )
            free(buf);
    }
}

- (BOOL)scanRestOfJSONString:(NSString **)x
{
    unsigned start = [self scanLocation], loc = start-1;
    NSString *str = [self string];
    unsigned length = [str length];
    
    CFStringInlineBuffer strBuffer;
    CFStringInitInlineBuffer((CFStringRef)str, &strBuffer, CFRangeMake(0, length));
    
    NSMutableString *result = nil;
    while (YES) {
        // No need to do range checking -- the next call will set uc to 0 if it's past the end.
        unichar uc = CFStringGetCharacterFromInlineBuffer(&strBuffer, ++loc); //[str characterAtIndex:loc];
        
        if ('"' == uc) {
            // End of the string.
            NSRange chunk = NSMakeRange(start, loc-start);
            if ( result ) {
                appendSubstring(result, str, chunk);
                *x = result;
            } else {
                *x = [str substringWithRange: chunk];
            }
            [self setScanLocation:loc+1];
            return TRUE;
        } else if ( '\\' == uc ) {
            // Escape sequence; Grab the next char after this one.
            if ( ! result )
                result = [NSMutableString stringWithCapacity:length-start];
            appendSubstring(result, str, NSMakeRange(start, loc-start));
            uc = CFStringGetCharacterFromInlineBuffer(&strBuffer, ++loc); // [str characterAtIndex:++loc];
            id c;
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
                {
                    [self setScanLocation:loc+1];
                    if ([self scanJSONUnicodeChar:&uc]) {
                        loc = [self scanLocation]-1;
                    }
                }
                    break;
                default:    [NSException raise:@"malformed"
                                        format:@"Found character '%C' in %@", uc, str];
            }
            appendCharacter(result, uc);
            start = loc+1;
        } else if (0x20 > uc) {
            if ( loc > length )                  // uc will be 0 if it fell off the end
                [NSException raise:@"enojson"
                            format:@"Malformed JSON string (no close quote)"];
            else
                [NSException raise:@"ctrlchar"
                            format:@"Found unescaped control char %x in JSON", uc];
        }
    }
}

- (BOOL)scanJSONString:(NSString **)x
{
    return [self scanJSONChar: '"'] && [self scanRestOfJSONString: x];
}

- (BOOL)scanJSONNumber:(NSNumber **)x loc: (unsigned)loc firstChar: (unichar)c
{
    NSString *str = [self string];
    unsigned strlen = [str length];
    unsigned start = loc;

    // The logic to test for validity of the number formatting is relicensed
    // from JSON::XS with permission from its author Marc Lehmann.
    // (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)
    if ('-' == c)
        c = loc+1 < strlen ? [str characterAtIndex:++loc] : 0;
    
    if ('0' == c) {
        c = loc+1 < strlen ? [str characterAtIndex:++loc] : 0;

        if (c >= '0' && c <= '9')
            [NSException raise:@"enonum" format:@"Leading zeroes not allowed in number"];

    } else if ((c < '0' || c > '9') && loc != start) {
        [NSException raise:@"enonum" format:@"No digits after initial minus (saw %C)", c];
    
    } else {
        skipDigits(&c, &loc, str);
    }

    // Fractional part
    if ('.' == c) {
        c = loc+1 < strlen ? [str characterAtIndex:++loc] : 0;

        if (c < '0' || c > '9')
            [NSException raise:@"enonum" format:@"No digits after decimal point"];
        
        skipDigits(&c, &loc, str);
    }

    // Exponential part
    if ('e' == c || 'E' == c) {
        c = loc+1 < strlen ? [str characterAtIndex:++loc] : 0;
        
        if ('-' == c || '+' == c)
            c = loc+1 < strlen ? [str characterAtIndex:++loc] : 0;

        if (c < '0' || c > '9')
            [NSException raise:@"enonum" format:@"No digits after exponent"];

        skipDigits(&c, &loc, str);
    }

    NSDecimal decimal;
    if ([self scanDecimal:&decimal]) {
        *x = [NSDecimalNumber decimalNumberWithDecimal:decimal];
        return YES;
    }
    return NO;
}

- (BOOL)scanJSONNumber:(NSNumber **)x
{
    NSString *str = [self string];
    unsigned loc = [self scanLocation];
    unsigned strlen = [str length];
    
    unichar firstChar = skipWhitespace(&loc, str);
    if (loc >= strlen)
        return NO;
    else
        return [self scanJSONNumber: x loc: loc firstChar: firstChar];
}    

- (BOOL)scanRestOfJSONArray:(NSArray **)array
{
    *array = [NSMutableArray array];
    if ([self scanJSONChar: ']'])
        return YES;
        
    for (;;) {
        id o;
        if (![self scanJSONValue:&o])
            [NSException raise:@"enovalue" format:@"Expected array element"];

        [(NSMutableArray *)*array addObject:o];

        if ([self scanJSONChar: ']'])
            return YES;

        if ([self scanJSONChar: ',']) {
            if ([self scanJSONChar: ']'])
                [NSException raise:@"comma"
                            format:@"Trailing comma in array"];
        } else {
            [NSException raise:@"enocomma"
                        format:@", or ] expected while parsing array"];
        }
    }
    return NO;
}

- (BOOL)scanJSONArray:(NSArray **)array
{
    return [self scanJSONChar:'['] && [self scanRestOfJSONArray: array];
}        

- (BOOL)scanRestOfJSONObject:(NSDictionary **)dictionary
{
    *dictionary = [NSMutableDictionary dictionary];
    for (;;) {
        id key, value;
        if (![self scanJSONString:&key]) {
            if ([self scanJSONChar: '}']) {
                if ([*dictionary count] == 0)
                    return YES; // empty dict
                else
                    [NSException raise:@"comma"
                                format:@"Trailing comma in dictionary"];
            } else if ([self scanJSONValue:&key])
                [NSException raise:@"enostring"
                            format:@"Dictionary key must be a string"];
            else
                [NSException raise:@"enovalue"
                            format:@"Expected dictionary key"];
        }

        if (![self scanJSONChar: ':'])
            [NSException raise:@"enoseparator"
                        format:@"Expected key-value separator"];

        if (![self scanJSONValue:&value])
            [NSException raise:@"enovalue"
                        format:@"Expected dictionary value"];

        [(NSMutableDictionary *)*dictionary setObject:value forKey:key];

        if ( ! [self scanJSONChar: ',']) {
            if ([self scanJSONChar: '}'])
                return YES;
            else
                [NSException raise:@"enocomma"
                            format:@", or } expected while parsing dictionary"];
        }
    }
    return NO;
}

- (BOOL)scanJSONObject:(NSDictionary **)dictionary
{
    return [self scanJSONChar: '{'] && [self scanRestOfJSONObject: dictionary];
}

- (BOOL)scanJSONValue:(NSObject **)object
{
    unsigned loc = [self scanLocation];    
    unichar nextChar = skipWhitespace(&loc, [self string]);
    switch( nextChar ) {
        case '{':
            [self setScanLocation: loc+1];
            return [self scanRestOfJSONObject:(NSDictionary **)object];
        case '[':
            [self setScanLocation: loc+1];
            return [self scanRestOfJSONArray:(NSArray **)object];
        case '"':
            [self setScanLocation: loc+1];
            return [self scanRestOfJSONString:(NSString **)object];
        case '0'...'9':
        case '-':
        case '+':
            return [self scanJSONNumber:(NSNumber **)object loc: loc firstChar: nextChar];
        case 't':
        case 'f':
            return [self scanJSONBool:(NSNumber **)object];
        case 'n':
            return [self scanJSONNull:(NSNull **)object];
        default:
            return NO;
    }
}

@end
