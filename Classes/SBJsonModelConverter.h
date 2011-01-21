//
//  SBJsonModelConverter.h
//
//  Created by Shairon Toledo on 1/19/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <unistd.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "JSON.h"


@interface SBJsonModelConverter : NSObject {

    
}

-(NSMutableArray *) scanArray:(NSMutableArray *) original;
-(NSMutableDictionary *) scanDictionary:(NSMutableDictionary *) original;
-(NSMutableDictionary *) scanObject:(NSObject *) original;

@end
