//
//  SBJsonBase.h
//  JSON
//
//  Created by Stig Brautaset on 18/03/2009.
//  Copyright 2009 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * SBJSONErrorDomain;


enum {
    EUNSUPPORTED = 1,
    EPARSENUM,
    EPARSE,
    EFRAGMENT,
    ECTRL,
    EUNICODE,
    EDEPTH,
    EESCAPE,
    ETRAILCOMMA,
    ETRAILGARBAGE,
    EEOF,
    EINPUT
};

/**
 Contains methods for reporting errors.
 
 */
@interface SBJsonBase : NSObject {
    NSMutableArray *errorTrace;
}

/// Return an error trace, or nil if there was no errors.
/**
 Note that this method returns the trace of the last method that failed.
 You need to check the return value of the call you're making to figure out
 if the call actually failed, before you know call this method.
 */
 @property(copy,readonly) NSArray* errorTrace;

/// @internal for use in subclasses to add errors to the stack trace
- (void)addErrorWithCode:(NSUInteger)code description:(NSString*)str;

/// @internal for use in subclasess to clear the error before a new parsing attempt
- (void)clearErrorTrace;

@end
