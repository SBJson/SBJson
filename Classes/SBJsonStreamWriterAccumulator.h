//
//  SBJsonStreamWriterAccumulator.h
//  JSON
//
//  Created by Stig Brautaset on 10/05/2011.
//  Copyright 2011 Morgan Stanley. All rights reserved.
//

#import "SBJsonStreamWriter.h"

@interface SBJsonStreamWriterAccumulator : NSObject <SBJsonStreamWriterDelegate> {
@private
    NSMutableData *data;
}

@property (readonly, copy) NSData* data;

@end
