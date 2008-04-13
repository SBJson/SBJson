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

#import "NSObject+SBJSON.h"


@implementation NSObject (NSObject_SBJSON)
- (NSString *)JSONString
{
    [NSException raise:@"unsupported"
                format:@"-JSONString not implemented for objects of type '%@'", [self class]];
}
@end

@implementation NSNull (NSObject_SBJSON)
- (NSString *)JSONString
{
    return @"null";
}
@end

@implementation NSNumber (NSObject_SBJSON)
- (NSString *)JSONString
{
    if ('c' != *[self objCType])
        return [self description];
    return [self boolValue] ? @"true" : @"false";
}
@end

@implementation NSString (NSObject_SBJSON)
- (NSString *)JSONString
{
    NSMutableString *s = [NSMutableString stringWithString:@"\""];
    for (unsigned i = 0; i < [self length]; i++) {
        unichar uc = [self characterAtIndex:i];
        switch (uc) {
            case '"':   [s appendString:@"\\\""];       break;
            case '\\':  [s appendString:@"\\\\"];       break;
            case '\t':  [s appendString:@"\\t"];        break;
            case '\n':  [s appendString:@"\\n"];        break;
            case '\r':  [s appendString:@"\\r"];        break;
            case '\b':  [s appendString:@"\\b"];        break;
            case '\f':  [s appendString:@"\\f"];        break;
            default:    [s appendFormat:@"%C", uc];     break;
        }
    }
    return [s stringByAppendingString:@"\""];
}
@end

@implementation NSArray (NSObject_SBJSON)
- (NSString *)JSONString
{
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[self count]];
    for (int i = 0; i < [self count]; i++)
        [tmp addObject:[[self objectAtIndex:i] JSONString]];
    return [NSString stringWithFormat:@"[%@]", [tmp componentsJoinedByString:@","]];
}
@end

@implementation NSDictionary (NSObject_SBJSON)
- (NSString *)JSONString
{
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[self count]];
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        [tmp addObject:[NSString stringWithFormat:@"%@:%@",
            [key JSONString], [[self objectForKey:key] JSONString]]];
    }
    return [NSString stringWithFormat:@"{%@}", [tmp componentsJoinedByString:@","]];
}
@end
