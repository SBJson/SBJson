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

#import <Foundation/Foundation.h>


@interface SBJsonObjectPath : NSObject {
}

// The json result is a NSDictionary / NSArray tree. 
// This Method will do a NSLog for every item and display its path.
// You can use one of the path items to directly select an item using the findInObject method.
+(void)logObjectPaths:(NSObject*)data forPath:(NSString*)path;

// Return the object value of one json item using a path valiable.
// Sample path: carId=audi/cars/type=a4/components/0/componentId
// This path will return:
//		array item for the index where the inner dictionary object for the key carId is audi, 
//		dictionary item for key cars, 
//		aray item for the index where the inner dictionary object for key type is a4, 
//		dictionary item for key components, 
//		array item for index 0
//		dictionary item for key componentId
+(NSObject*)findInObject:(NSObject*)data forPath:(NSString*)path;
@end
