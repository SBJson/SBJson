//
//  SBJsonStreamParserAccumulator.h
//  JSON
//
//  Created by Stig Brautaset on 08/05/2011.
//  Copyright 2011 Morgan Stanley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonStreamParserAdapter.h"

@interface SBJsonStreamParserAccumulator : NSObject <SBJsonStreamParserAdapterDelegate> {
@private
    id value;    
}

@property (readonly, copy) id value;

@end
