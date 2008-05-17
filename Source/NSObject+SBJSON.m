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
#import "SBJSON.h"

@implementation NSObject (NSObject_SBJSON)

- (NSString *)JSONFragment {
    SBJSON *generator = [SBJSON new];
    
    NSError *error;
    NSString *json = [generator stringWithJSON:self error:&error];
    [generator release];
    
    if (!json)
        NSLog(@"%@", error);
    return json;
}

- (NSString *)JSONRepresentation {
    return [self JSONFragment];
}

- (NSString *)JSONRepresentationWithOptions:(NSDictionary *)x {
    SBJSON *generator = [SBJSON new];

    id o;
    if (o = [x objectForKey:@"HumanReadable"]) 
        [generator setHumanReadable:[o boolValue]];

    if (o = [x objectForKey:@"MultiLine"]) 
        [generator setHumanReadable:[o boolValue]];

    if (o = [x objectForKey:@"Pretty"])
        [generator setHumanReadable:[o boolValue]];
    
    NSError *error;
    NSString *json = [generator stringWithJSON:self error:&error];
    [generator release];
    
    if (!json)
        NSLog(@"%@", error);
    return json;
}

@end
