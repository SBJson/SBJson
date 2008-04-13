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

- (BOOL)scanJSONString:(NSString **)x
{
    if (![self scanString:@"\"" intoString:nil])
        return NO;

    unsigned loc = [self scanLocation]-1;
    NSString *str = [self string];
    
    *x = [NSMutableString stringWithCapacity:[str length]-loc];
    while (++loc < [str length]) {
        unichar uc = [str characterAtIndex:loc];
        
        if ('"' == uc) {
            // End of the string.
            [self setScanLocation:loc+1];
            return TRUE;
        }
        
        if ('\\' != uc) {
            // Normal character. 
            [(NSMutableString *)*x appendFormat:@"%C", uc];
            continue;
        }
        
        // Grab the next char after this one.
        uc = [str characterAtIndex:++loc];
        id c;
        switch (uc) {
            case '\\':  c = @"\\";  break;
            case '/':   c = @"/";  break;
            case '"':   c = @"\"";  break;
            case 'b':   c = @"\b";  break;
            case 'n':   c = @"\n";  break;
            case 'r':   c = @"\r";  break;
            case 't':   c = @"\t";  break;
            case 'f':   c = @"\f";  break;
            case 'u':   
                {
                    unichar u;
                    [self setScanLocation:loc+1];
                    if ([self scanJSONUnicodeChar:&u]) {
                        c = [NSString stringWithFormat:@"%C", u];
                        loc = [self scanLocation]-1;
                    }
                }
                break;
            default:    [NSException raise:@"malformed"
                                    format:@"Found character '%C' in %@", uc, str];
        }
        [(NSMutableString *)*x appendString:c];
    }

    [NSException raise:@"enojson"
                format:@"Malformed JSON string (no close quote)"];
}

- (BOOL)scanJSONNumber:(NSNumber **)x
{
    NSDecimal decimal;
    if ([self scanDecimal:&decimal]) {
        *x = [NSDecimalNumber decimalNumberWithDecimal:decimal];
        return YES;
    }
    return NO;
}

- (BOOL)scanJSONArray:(NSArray **)array
{
    if (![self scanString:@"[" intoString:nil])
        return NO;

    *array = [NSMutableArray array];
    if ([self scanString:@"]" intoString:nil])
        return YES;
        
    for (;;) {
        id o;
        if (![self scanJSONValue:&o])
            [NSException raise:@"enovalue" format:@"Expected array element"];

        [(NSMutableArray *)*array addObject:o];

        if ([self scanString:@"]" intoString:nil])
            return YES;

        if ([self scanString:@"," intoString:nil]) {
            if ([self scanString:@"]" intoString:nil])
                [NSException raise:@"comma"
                            format:@"Trailing comma in array"];
        } else {
            [NSException raise:@"enocomma"
                        format:@", or ] expected while parsing array"];
        }
    }
    return NO;
}

- (BOOL)scanJSONDictionary:(NSDictionary **)dictionary
{
    if (![self scanString:@"{" intoString:nil])
        return NO;
    
    *dictionary = [NSMutableDictionary dictionary];
    if ([self scanString:@"}" intoString:nil])
        return YES;

    for (;;) {
        id key, value;
        if (![self scanJSONString:&key]) {
            if ([self scanJSONValue:&key])
                [NSException raise:@"enostring"
                            format:@"Dictionary key must be a string"];
            [NSException raise:@"enovalue"
                        format:@"Expected dictionary key"];
        }

        if (![self scanString:@":" intoString:nil])
            [NSException raise:@"enoseparator"
                        format:@"Expected key-value separator"];

        if (![self scanJSONValue:&value])
            [NSException raise:@"enovalue"
                        format:@"Expected dictionary value"];

        [(NSMutableDictionary *)*dictionary setObject:value forKey:key];

        if ([self scanString:@"}" intoString:nil])
            return YES;

        if ([self scanString:@"," intoString:nil]) {
            if ([self scanString:@"}" intoString:nil])
                [NSException raise:@"comma"
                            format:@"Trailing comma in dictionary"];
        } else {
            [NSException raise:@"enocomma"
                        format:@", or } expected while parsing dictionary"];
        }
    }
    return NO;
}

- (BOOL)scanJSONValue:(NSObject **)object
{
    if ([self scanJSONNull:(NSNull **)object])
        return YES;
    if ([self scanJSONBool:(NSNumber **)object])
        return YES;
    if ([self scanJSONString:(NSString **)object])
        return YES;
    if ([self scanJSONNumber:(NSNumber **)object])
        return YES;
    if ([self scanJSONArray:(NSArray **)object])
        return YES;
    if ([self scanJSONDictionary:(NSDictionary **)object])
        return YES;
    return NO;
}

@end
