/*
 Copyright (c) 2010, Edwin Vermeer.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 Neither the name of the the author nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SBJsonObjectPath.h"


@implementation SBJsonObjectPath

+(void)logObjectPaths:(NSObject*)data forPath:(NSString*)path {
	if ([data isKindOfClass:[NSDictionary class]]) {
		for (NSString* key in (NSDictionary*)data) {
			[SBJsonObjectPath logObjectPaths:[((NSDictionary*)data) objectForKey:key] forPath:[NSString stringWithFormat:@"%@/%@",path, key]];
		}
	} else 	if ([data isKindOfClass:[NSArray class]]) {
		int i = 0;
		for (NSObject* innerData in (NSArray*)data) {
			[SBJsonObjectPath logObjectPaths:innerData forPath:[NSString stringWithFormat:@"%@/%i",path, i]];
			i++;
		}
	} else {
		if (path != nil && data != nil) {
			NSLog(@"%@ = %@", [path substringFromIndex:1] , data);
		}
	}
}

+(NSObject*)findInObject:(NSObject*)data forPath:(NSString*)path {
	if (data==nil) { return nil; }
	if ([path length] == 0) { return data; }
	NSString *key = (NSString*)[[path componentsSeparatedByString:@"/"] objectAtIndex:0];
	NSString *newPath = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", key] withString:@""];
	if ([key isEqualToString:path]) { newPath = @""; }
	if ([data isKindOfClass:[NSDictionary class]]) {
		return [SBJsonObjectPath findInObject:[((NSDictionary*)data) objectForKey:key] forPath:newPath ];
	} else 	if ([data isKindOfClass:[NSArray class]]) {
		if ([key rangeOfString:@"="].location == NSNotFound) {
			return [SBJsonObjectPath findInObject:[((NSArray*)data) objectAtIndex:[key intValue]] forPath:newPath];
		} else {
			NSString *field = (NSString*)[[key componentsSeparatedByString:@"="] objectAtIndex:0];
			NSString *value = (NSString*)[[key componentsSeparatedByString:@"="] objectAtIndex:1];
			int i = 0;
			for (NSDictionary* innerData in (NSArray*)data) {
				if ([(NSString*)[innerData objectForKey:field] isEqualToString:value]) {
					return [SBJsonObjectPath findInObject:[((NSArray*)data) objectAtIndex:i] forPath:newPath];
				}
				i++;
			}			
		}
	} else if ([newPath length] == 0) { return data; }
	return nil;
}

@end
