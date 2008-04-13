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
- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json;
@end

@implementation NSObject (NSObject_SBJSON)

- (NSString *)JSONFragment
{
    opts_t args = defaults(nil);
    return [self JSONFragmentWithOptions:&args];
}

- (NSString *)JSONFragmentWithOptions:(opts_t *)x
{
    NSMutableString *json = [[NSMutableString alloc] initWithCapacity: 256];
    [self JSONFragmentWithOptions:x into: json];

    if( [json length] < 240 ) {
        // If the result is shorter than the capacity, copy it to avoid wasting the empty space:
        NSString *result = [[json copy] autorelease];
        [json release];
        return result;
    } else
        return [json autorelease];
}

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    [NSException raise:@"unsupported"
                format:@"-JSONFragment not implemented for objects of type '%@'", [self class]];
}

@end


@implementation NSNull (NSObject_SBJSON)

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    [json appendString: @"null"];
}

@end


@implementation NSNumber (NSObject_SBJSON)

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    if ('c' != *[self objCType])
        [json appendString: [self description]];
    else
        [json appendString: [self boolValue] ? @"true" : @"false"];
}

@end


@implementation NSString (NSObject_SBJSON)

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    static NSMutableCharacterSet *kEscapeChars;
    if( ! kEscapeChars ) {
        kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
        [kEscapeChars addCharactersInString: @"\"\\"];
    }
    
    [json appendString: @"\""];
    
    NSRange esc = [self rangeOfCharacterFromSet: kEscapeChars];
    if( esc.length==0 ) {
        // No special chars -- can just add the raw string:
        [json appendString: self];
    } else {
        for (unsigned i = 0; i < [self length]; i++) {
            unichar uc = [self characterAtIndex:i];
            switch (uc) {
                case '"':   [json appendString:@"\\\""];       break;
                case '\\':  [json appendString:@"\\\\"];       break;
                case '\t':  [json appendString:@"\\t"];        break;
                case '\n':  [json appendString:@"\\n"];        break;
                case '\r':  [json appendString:@"\\r"];        break;
                case '\b':  [json appendString:@"\\b"];        break;
                case '\f':  [json appendString:@"\\f"];        break;
                default:    
                    if (uc < 0x20) {
                        [json appendFormat:@"\\u%04x", uc];
                    } else {
                        [json appendFormat:@"%C", uc];
                    }
                    break;

            }
        }
    }
    
    [json appendString:@"\""];
}

@end


@implementation NSArray (NSArray_SBJSON)

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    NSString *open = @"";
    NSString *close = @"";
    NSString *sep = x->after ? @", " : @",";
    if (x->indent) {
        NSString *indent = [@"" stringByPaddingToLength:x->depth*2 withString:@" " startingAtIndex:0];
        open = [@"\n  " stringByAppendingString:indent];
        close = [@"\n" stringByAppendingString:indent];
        sep = [@",\n  " stringByAppendingString:indent];
    }
    
    [json appendString: @"["];
    if( x->indent ) [json appendString: open];
    x->depth++;
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5
    unsigned n = [self count];
    for (int i = 0; i < n; i++) {
        id item = [self objectAtIndex:i];
#else
    int i=-1;
    for( id item in self ) {
        i++;
#endif
        if( i>0 ) [json appendString: sep];
        [item JSONFragmentWithOptions:x into: json];
    }
    x->depth--;
    if( x->indent ) [json appendString: close];
    [json appendString: @"]"];
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

- (void)JSONFragmentWithOptions:(opts_t *)x into: (NSMutableString *)json
{
    NSString *open = @"";
    NSString *close = @"";
    NSString *sep = x->after ? @", " : @",";
    if (x->indent) {
        NSString *indent = [@"" stringByPaddingToLength:x->depth*2 withString:@" " startingAtIndex:0];
        open = [@"\n  " stringByAppendingString:indent];
        close = [@"\n" stringByAppendingString:indent];
        sep = [@",\n  " stringByAppendingString:indent];
    }
    
    [json appendString: @"{"];
    if( x->indent ) [json appendString: open];

    x->depth++;
    NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5
    unsigned n = [keys count];
    for (int i = 0; i < n; i++) {
        NSString *key = [keys objectAtIndex:i];
#else
    int i=-1;
    for( NSString *key in keys ) {
        i++;
#endif
        if( i>0 ) [json appendString: sep];
        if (![key isKindOfClass:[NSString class]])
            [NSException raise:@"enostring"
                        format:@"JSON dictionary keys *must* be strings."];
        [key JSONFragmentWithOptions: x into: json];
        if( x->before ) [json appendString: @" "];
        [json appendString: @":"];
        if( x->after ) [json appendString: @" "];
        [[self objectForKey:key] JSONFragmentWithOptions:x into: json];
    }
    x->depth--;
    
    if( x->indent ) [json appendString: close];
    [json appendString: @"}"];
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
