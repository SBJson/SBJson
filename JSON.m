/*
Copyright (c) 2007, Stig Brautaset. All rights reserved.

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

#import "JSON.h"

@interface JSON (JSONPrivate)
- (id)fromJSONWithScanner:(NSScanner *)scanner;
- (id)arrayFromJSONWithScanner:(NSScanner *)scanner;
- (id)dictionaryFromJSONWithScanner:(NSScanner *)scanner;
@end

@implementation JSON

- (id)arrayFromJSONWithScanner:(NSScanner *)scanner
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (![scanner scanString:@"]" intoString:nil]) {
        for (;;) {
            id o = [self fromJSONWithScanner:scanner];
            if (!o)
                [NSException raise:@"no-element" format:@"Expected array element"];

            [array addObject:o];

            if ([scanner scanString:@"]" intoString:nil])
                break;

            if (![scanner scanString:@"," intoString:nil])
                [NSException raise:@"expected-comma"
                            format:@", or ] expected while parsing array: %@ (%@)",
                                [scanner string], array];
        }
    }

    return array;
}

- (id)dictionaryFromJSONWithScanner:(NSScanner *)scanner
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (![scanner scanString:@"}" intoString:nil]) {
        for (;;) {
            id key = [self fromJSONWithScanner:scanner];
            if (!key)
                [NSException raise:@"no-key" format:@"Expected dictionary key"];

            if (![scanner scanString:@":" intoString:nil])
                [NSException raise:@"no-separator" format:@"Expected key-value separator"];

            id value = [self fromJSONWithScanner:scanner];
            if (!value)
                [NSException raise:@"no-value" format:@"Expected dictionary value"];

            [dictionary setObject:value forKey:key];

            if ([scanner scanString:@"}" intoString:nil])
                break;

            if (![scanner scanString:@"," intoString:nil])
                [NSException raise:@"expected-comma"
                            format:@", or } expected while parsing dictionary: %@ (%@)",
                                [scanner string], dictionary];
        }
    }

    return dictionary;
}


- (id)fromJSONWithScanner:(NSScanner *)scanner
{
    NSDecimal decimal;
    if ([scanner scanString:@"null" intoString:nil])
        return [NSNull null];
    if ([scanner scanString:@"true" intoString:nil])
        return [NSNumber numberWithBool:YES];
    if ([scanner scanString:@"false" intoString:nil])
        return [NSNumber numberWithBool:NO];
    if ([scanner scanDecimal:&decimal])
        return [NSDecimalNumber decimalNumberWithDecimal:decimal];

    // Strings. XXX - this is not quite good enough.
    // We need to deal with escaping.
    if ([scanner scanString:@"\"" intoString:nil]) {
        id s;
        [scanner scanUpToString:@"\"" intoString:&s];
        [scanner scanString:@"\"" intoString:nil];
        return s;
    }

    // Composites.
    if ([scanner scanString:@"[" intoString:nil])
        return [self arrayFromJSONWithScanner:scanner];
    if ([scanner scanString:@"{" intoString:nil])
        return [self dictionaryFromJSONWithScanner:scanner];

    return @"I suck";
}

- (id)fromJSONString:(NSString *)js
{
    return [self fromJSONWithScanner:[NSScanner scannerWithString:js]];
}

- (NSString *)escapedStringWithScanner:(NSScanner *)scanner
{
    NSCharacterSet *ctrl = [NSCharacterSet controlCharacterSet];
    NSCharacterSet *slashanddquote = [NSCharacterSet characterSetWithCharactersInString:@"\\\""];
    NSMutableCharacterSet *escapees = [ctrl mutableCopy];
    [escapees formUnionWithCharacterSet:slashanddquote];
    
    NSString *tmp;
    if ([scanner scanUpToCharactersFromSet:escapees intoString:&tmp] && [scanner isAtEnd])
        return tmp;

    // Scan control characters until we're passed them.
    NSString *s = [scanner string];
    unsigned idx = [scanner scanLocation];
    while (![scanner isAtEnd] && [escapees characterIsMember:[s characterAtIndex:idx]]) {
        tmp = [tmp stringByAppendingFormat:@"\\%@", [s substringWithRange:NSMakeRange(idx, 1)]];
        [scanner setScanLocation:++idx];
    }
    if ([scanner isAtEnd])
        return tmp;

//    NSLog(@"%@ => '%@' -> '%@'", [scanner string], tmp, [[scanner string] substringFromIndex:idx]);
    return [tmp stringByAppendingString:[self escapedStringWithScanner:scanner]];
}

- (NSString *)toJSONString:(id)x
{
    if (!x || [x isKindOfClass:[NSNull class]])
        return @"null";
    if ([x isKindOfClass:[NSNumber class]])
        return [x stringValue];
    if ([x isKindOfClass:[NSString class]]) {
        NSCharacterSet *skipSet = [NSCharacterSet new];
        NSScanner *scanner = [NSScanner scannerWithString:x];
        [scanner setCharactersToBeSkipped:skipSet];
        return [NSString stringWithFormat:@"\"%@\"", [self escapedStringWithScanner:scanner]];
    }
    if ([x isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[x count]];
        for (int i = 0; i < [x count]; i++)
            [tmp addObject:[self toJSONString:[x objectAtIndex:i]]];
        return [NSString stringWithFormat:@"[%@]", [tmp componentsJoinedByString:@","]];
    }
    if ([x isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[x count]];
        NSArray *keys = [[x allKeys] sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i < [keys count]; i++) {
            NSString *key = [keys objectAtIndex:i];
            [tmp addObject:[NSString stringWithFormat:@"%@:%@",
                [self toJSONString:key], [self toJSONString:[x objectForKey:key]]]];
        }
        return [NSString stringWithFormat:@"{%@}", [tmp componentsJoinedByString:@","]];
    }
    
    [NSException raise:@"unsupported-type"
                format:@"I don't know about the type of %@", x];
}

@end
