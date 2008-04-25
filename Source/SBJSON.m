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

#import "SBJSON.h"

NSString * SBJSONErrorDomain = @"org.brautaset.JSON.ErrorDomain";

@interface SBJSON (Private)

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json error:(NSError**)error;
- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json error:(NSError**)error;
- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json error:(NSError**)error;
- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json error:(NSError**)error;

- (NSString*)colon;
- (NSString*)comma;
- (NSString*)indent;

@end


@implementation SBJSON

#pragma mark Generator

- (NSString*)stringWithJSON:(id)value error:(NSError**)error {
    depth = 0;
    NSMutableString *json = [NSMutableString stringWithCapacity:128];
    if ([self appendValue:value into:json error:error])
        return json;
    return nil;
}

- (NSString*)colon {
    NSString *colon = @":";
    if (spaceAfter && spaceBefore)
        colon = @" : ";
    else if (spaceAfter)
        colon = @": ";
    else if (spaceBefore)
        colon = @" :";
    return colon;
}

- (NSString*)comma {
    return spaceAfter && !multiLine ? @", " : @",";
}

- (NSString*)indent {
    return multiLine
    ? [@"\n" stringByPaddingToLength:1 + 2 * depth withString:@" " startingAtIndex:0]
    : @"";
}

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json error:(NSError**)error {
    if ([fragment isKindOfClass:[NSDictionary class]]) {
        if (![self appendDictionary:fragment into:json error:error])
            return NO;
        
    } else if ([fragment isKindOfClass:[NSArray class]]) {
        if (![self appendArray:fragment into:json error:error])
            return NO;

    } else if ([fragment isKindOfClass:[NSString class]]) {
        if (![self appendString:fragment into:json error:error])
            return NO;

    } else if ([fragment isKindOfClass:[NSNumber class]]) {
        if ('c' == *[fragment objCType])
            [json appendString:[fragment boolValue] ? @"true" : @"false"];
        else
            [json appendString:[fragment stringValue]];

    } else if ([fragment isKindOfClass:[NSNull class]]) {
        [json appendString:@"null"];
        
    } else {
        if (error)
            *error = [NSError errorWithDomain:SBJSONErrorDomain code:ENOSUPPORTED userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json error:(NSError**)error {
    // Empty array? Well that's easy!
    if (![fragment count]) {
        [json appendString:@"[]"];
        return YES;
    }
    
    [json appendString:@"["];
    depth++;
    
    BOOL addComma = NO;    
    NSString *comma = [self comma];
    NSEnumerator *values = [fragment objectEnumerator];
    for (id value; value = [values nextObject]; ) {
        if (!addComma)
            addComma = YES;
        else 
            [json appendString:comma];
        
        if (multiLine)
            [json appendString:[self indent]];
        
        if (![self appendValue:value into:json error:error]) {
            return NO;
        }
    }

    depth--;
    if (multiLine) [json appendString:[self indent]];
    [json appendString:@"]"];
    return YES;
}

- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json error:(NSError**)error {
    // Empty dictionary? Easy peasy!
    if (![fragment count]) {
        [json appendString:@"{}"];
        return YES;
    }
        
    [json appendString:@"{"];
    depth++;

    NSString *comma = [self comma];
    NSString *colon = [self colon];
    BOOL addComma = NO;
    NSEnumerator *values = [fragment keyEnumerator];
    for (id value; value = [values nextObject]; ) {
        
        if (!addComma)
            addComma = YES;
        else 
            [json appendString:comma];

        if (multiLine)
            [json appendString:[self indent]];
        
        if (![value isKindOfClass:[NSString class]]) {
            if (error)
                *error = [NSError errorWithDomain:SBJSONErrorDomain code:ENOSUPPORTED userInfo:nil];
            return NO;
        }
        
        if (![self appendString:value into:json error:error]) {
            return NO;
        }

        [json appendString:colon];
        if (![self appendValue:[fragment objectForKey:value] into:json error:error]) {
            return NO;
        }
    }

    depth--;
    if (multiLine) [json appendString:[self indent]];
    [json appendString:@"}"];
    return YES;    
}

- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json error:(NSError**)error {

    static NSMutableCharacterSet *kEscapeChars;
    if( ! kEscapeChars ) {
        kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
        [kEscapeChars addCharactersInString: @"\"\\"];
    }
    
    [json appendString:@"\""];
    
    NSRange esc = [fragment rangeOfCharacterFromSet:kEscapeChars];
    if ( !esc.length ) {
        // No special chars -- can just add the raw string:
        [json appendString:fragment];
        
    } else {
        for (unsigned i = 0; i < [fragment length]; i++) {
            unichar uc = [fragment characterAtIndex:i];
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
    return YES;
}

#pragma mark Properties

- (BOOL)spaceBefore {
    return spaceBefore;
}

- (void)setSpaceBefore:(BOOL)y {
    spaceBefore = y;
}

- (BOOL)spaceAfter {
    return spaceAfter;
}

- (void)setSpaceAfter:(BOOL)y {
    spaceAfter = y;
}

- (BOOL)multiLine {
    return multiLine;
}

- (void)setMultiLine:(BOOL)y {
    multiLine = y;
}

@end
