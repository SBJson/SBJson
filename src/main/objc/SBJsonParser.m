/*
 Copyright (C) 2009-2013 Stig Brautaset. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of the author nor the names of its contributors may be used
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

#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif

#import "SBJsonParser.h"
#import "SBJsonStreamParser.h"
#import "SBJsonChunkParser.h"

@implementation SBJsonParser

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 32u;
    return self;
}


#pragma mark Methods

- (id)objectWithData:(NSData *)data {
    return [self objectWithData:data processValuesWithBlock:nil];
}

- (id)objectWithData:(NSData *)data processValuesWithBlock:(SBProcessBlock)processBlock {

    if (!data) {
        self.error = @"Input was 'nil'";
        return nil;
    }

    __block id value = nil;
    SBJsonChunkParser *parser = [[SBJsonChunkParser alloc] initWithBlock:^(id v, BOOL *stop) {
        value = v;
    }
                                                            processBlock:processBlock
                                                           manyDocuments:NO
                                                         outerArrayItems:NO
                                                                maxDepth:self.maxDepth
                                                            errorHandler:^(NSError *err) {
                                                                self.error = err.localizedDescription;
                                                            }];

    switch ([parser parse:data]) {
        case SBJsonParserComplete:
            return value;

        case SBJsonParserWaitingForData:
            self.error = @"Unexpected end of input";
            break;

        case SBJsonParserStopped: // max-depth error
        case SBJsonParserError:
            break;
    }

    return nil;
}

- (id)objectWithString:(NSString *)string {
    return [self objectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] processValuesWithBlock:nil];
}

- (id)objectWithString:(NSString *)string processValuesWithBlock:(id (^)(id, NSString *))processBlock {
    return [self objectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] processValuesWithBlock:processBlock];
}

@end
