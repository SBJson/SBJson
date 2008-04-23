//
//  SBJSONGenerator.h
//  JSON
//
//  Created by Stig Brautaset on 20/04/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBJSONGenerator : NSObject {
    unsigned spaceBefore;
    unsigned spaceAfter;
    unsigned multiLine;
    unsigned depth;
}

- (void)setSpaceBefore:(BOOL)y;
- (void)setSpaceAfter:(BOOL)y;
- (void)setMultiLine:(BOOL)y;

- (NSString*)serializeValue:(id)value;

@end
