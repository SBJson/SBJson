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

typedef struct {
    unsigned before, after, indent, depth, maxdepth;
} opts_t;

#define setOpt(x,y,z) if (y && [y objectForKey:z]) x = [[y objectForKey:z] intValue]

static opts_t defaults(NSDictionary *x)
{
    opts_t y = {0,};
    y.maxdepth = 512;
    setOpt(y.before, x, @"SpaceBefore");
    setOpt(y.after, x, @"SpaceAfter");
    setOpt(y.indent, x, @"MultiLine");
    setOpt(y.before = y.after = y.indent, x, @"Pretty");
    return y;
}

@interface NSObject (NSObject_SBJSON_Private)
- (NSString *)JSONFragmentWithOptions:(opts_t *)x;
@end

@implementation NSObject (NSObject_SBJSON)

- (NSString *)JSONFragment
{
    opts_t args = defaults(nil);
    [self JSONFragmentWithOptions:&args];
}

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    [NSException raise:@"unsupported"
                format:@"-JSONFragment not implemented for objects of type '%@'", [self class]];
}

@end


@implementation NSNull (NSObject_SBJSON)

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    return @"null";
}

@end


@implementation NSNumber (NSObject_SBJSON)

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    if ('c' != *[self objCType])
        return [self description];
    return [self boolValue] ? @"true" : @"false";
}

@end


@implementation NSString (NSObject_SBJSON)

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    NSMutableString *s = [NSMutableString stringWithString:@"\""];
    for (unsigned i = 0; i < [self length]; i++) {
        unichar uc = [self characterAtIndex:i];
        switch (uc) {
            case '"':   [s appendString:@"\\\""];       break;
            case '\\':  [s appendString:@"\\\\"];       break;
            case '/':   [s appendString:@"\\/"];        break;
            case '\t':  [s appendString:@"\\t"];        break;
            case '\n':  [s appendString:@"\\n"];        break;
            case '\r':  [s appendString:@"\\r"];        break;
            case '\b':  [s appendString:@"\\b"];        break;
            case '\f':  [s appendString:@"\\f"];        break;
            default:    
                if (uc < 0x20) {
                    [s appendFormat:@"\\u%04x", uc];
                } else {
                    [s appendFormat:@"%C", uc];
                }
                break;

        }
    }
    return [s stringByAppendingString:@"\""];
}

@end


@implementation NSArray (NSArray_SBJSON)

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    x->depth++;
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[self count]];
    for (int i = 0; i < [self count]; i++)
        [tmp addObject:[[self objectAtIndex:i] JSONFragmentWithOptions:x]];
    x->depth--;

    NSString *open = @"";
    NSString *close = @"";
    NSString *sep = x->after ? @", " : @",";
    if (x->indent) {
        NSString *indent = [@"" stringByPaddingToLength:x->depth*2 withString:@" " startingAtIndex:0];
        open = [@"\n  " stringByAppendingString:indent];
        close = [@"\n" stringByAppendingString:indent];
        sep = [@",\n  " stringByAppendingString:indent];
    }
    return [NSString stringWithFormat:@"[%@%@%@]", open, [tmp componentsJoinedByString:sep], close];
}

- (NSString *)JSONRepresentation
{
    opts_t args = defaults(nil);
    return [self JSONFragmentWithOptions:&args];
}

- (NSString *)JSONRepresentationWithOptions:(NSDictionary *)x
{
    opts_t args = defaults(x);
    return [self JSONFragmentWithOptions:&args];
}

@end


@implementation NSDictionary (NSDictionary_SBJSON)

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    x->depth++;
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[self count]];
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        if (![key isKindOfClass:[NSString class]])
            [NSException raise:@"enostring"
                        format:@"JSON dictionary keys *must* be strings."];
        [tmp addObject:[NSString stringWithFormat:@"%@%s:%s%@",
            [key JSONFragmentWithOptions:x],
            x->before ? " " : "",
            x->after ? " " : "",
            [[self objectForKey:key] JSONFragmentWithOptions:x]]];
    }
    x->depth--;
    
    NSString *open = @"";
    NSString *close = @"";
    NSString *sep = x->after ? @", " : @",";
    if (x->indent) {
        NSString *indent = [@"" stringByPaddingToLength:x->depth*2 withString:@" " startingAtIndex:0];
        open = [@"\n  " stringByAppendingString:indent];
        close = [@"\n" stringByAppendingString:indent];
        sep = [@",\n  " stringByAppendingString:indent];
    }
    return [NSString stringWithFormat:@"{%@%@%@}", open, [tmp componentsJoinedByString:sep], close];
}

- (NSString *)JSONRepresentation
{
    opts_t args = defaults(nil);
    return [self JSONFragmentWithOptions:&args];
}

- (NSString *)JSONRepresentationWithOptions:(NSDictionary *)x
{
    opts_t args = defaults(x);
    return [self JSONFragmentWithOptions:&args];
}

@end
