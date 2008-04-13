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

- (BOOL)scanJSONString:(NSString **)x
{
    unsigned loc = [self scanLocation];
    NSString *str = [self string];
    
    if (![str length] || '"' != [str characterAtIndex:loc])
        return NO;
    
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
            case '"':   c = @"\"";  break;
            case 'b':   c = @"\b";  break;
            case 'n':   c = @"\n";  break;
            case 'r':   c = @"\r";  break;
            case 't':   c = @"\t";  break;
            case 'f':   c = @"\f";  break;
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
        if (![self scanJSONObject:&o])
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
            if ([self scanJSONObject:&key])
                [NSException raise:@"enostring"
                            format:@"Dictionary key must be a string"];
            [NSException raise:@"enovalue"
                        format:@"Expected dictionary key"];
        }

        if (![self scanString:@":" intoString:nil])
            [NSException raise:@"enoseparator"
                        format:@"Expected key-value separator"];

        if (![self scanJSONObject:&value])
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

- (BOOL)scanJSONObject:(NSObject **)object
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
