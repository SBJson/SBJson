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

#import "NSScanner+SBJSON.h"


@implementation NSScanner (NSScanner_SBJSON)

- (BOOL)scanJSONNull:(NSNull **)x
{
    if ([self scanString:@"null" intoString:nil]) {
        *x = [NSNull null];
        return YES;
    }
    return NO;
}

- (BOOL)scanJSONBool:(NSNumber **)x
{
    if ([self scanString:@"true" intoString:nil]) {
        *x = [NSNumber numberWithBool:YES];
        return YES;
    }
    if ([self scanString:@"false" intoString:nil]) {
        *x = [NSNumber numberWithBool:NO];
        return YES;
    }
    return NO;
}

- (BOOL)scanJSONString:(NSString **)x
{
    // XXX - this is not good enough. We need to deal with escaping.
    if ([self scanString:@"\"" intoString:nil])
        if ([self scanUpToString:@"\"" intoString:x])
            if ([self scanString:@"\"" intoString:nil])
                return YES;
    return NO;
}


@end
