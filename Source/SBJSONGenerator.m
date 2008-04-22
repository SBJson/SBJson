//
//  SBJSONGenerator.m
//  JSON
//
//  Created by Stig Brautaset on 20/04/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBJSONGenerator.h"

@interface SBJSONGenerator (Private)

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json;
- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json;
- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json;
- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json;

@end


@implementation SBJSONGenerator

- (NSString*)serializeValue:(id)value {
    NSMutableString *json = [NSMutableString stringWithCapacity:128];
    if ([self appendValue:value into:json])
        return json;
    return nil;
}

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json {
    if ([fragment isKindOfClass:[NSDictionary class]]) {
        if (![self appendDictionary:fragment into:json])
            return NO;
        
    } else if ([fragment isKindOfClass:[NSArray class]]) {
        if (![self appendArray:fragment into:json])
            return NO;

    } else if ([fragment isKindOfClass:[NSString class]]) {
        if (![self appendString:fragment into:json])
            return NO;

    } else if ([fragment isKindOfClass:[NSNumber class]]) {
        if ('c' == *[fragment objCType])
            [json appendString:[fragment boolValue] ? @"true" : @"false"];
        else
            [json appendString:[fragment stringValue]];

    } else if ([fragment isKindOfClass:[NSNull class]]) {
        [json appendString:@"null"];
        
    } else {
        NSLog(@"Not able to convert object to JSON: %@", fragment);
        return NO;
    }
    return YES;
}

- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json {
    [json appendString:@"["];
    
    BOOL addComma = NO;    
    NSString *comma = spaceAfter && !multiLine ? @", " : @",";
    NSEnumerator *values = [fragment objectEnumerator];
    for (id value; value = [values nextObject]; ) {
        if (!addComma)
            addComma = YES;
        else 
            [json appendString:comma];
        
        if (![self appendValue:value into:json]) {
            NSLog(@"Failed converting array value to JSON: %@", value);
            return NO;
        }
    }

    [json appendString:@"]"];
    return YES;
}

- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json {
    [json appendString:@"{"];
    
    BOOL addComma = NO;
    NSString *comma = spaceAfter && !multiLine ? @", " : @",";
    NSString *colon = spaceAfter && spaceBefore ? @" : " : spaceAfter ? @": " : spaceBefore ? @" :" : @":";
    NSEnumerator *values = [fragment keyEnumerator];
    for (id value; value = [values nextObject]; ) {
        
        if (!addComma)
            addComma = YES;
        else 
            [json appendString:comma];
        
        if (![value isKindOfClass:[NSString class]]) {
            NSLog(@"JSON Object keys must be strings");
            return NO;
        }
        
        if (![self appendString:value into:json]) {
            NSLog(@"Failed converting dictionary key to JSON");
            return NO;
        }

        [json appendString:colon];
        if (![self appendValue:[fragment objectForKey:value] into:json]) {
            NSLog(@"Failed converting dictionary value to JSON");
            return NO;
        }
    }

    [json appendString:@"}"];
    return YES;    
}

- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json {

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

- (void)setSpaceBefore:(BOOL)y {
    spaceBefore = y;
}

- (void)setSpaceAfter:(BOOL)y {
    spaceAfter = y;
}

- (void)setMultiLine:(BOOL)y {
    multiLine = y;
}

@end
