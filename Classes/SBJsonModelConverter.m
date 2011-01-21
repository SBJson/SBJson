//
//  SBJsonModelConverter.m
//  Created by Shairon Toledo on 1/19/11.
//  Copyright 2011 none. All rights reserved.
//

#import "SBJsonModelConverter.h"
#import "JSON.h"

@implementation SBJsonModelConverter

-(NSMutableArray *) scanArray:(NSMutableArray *) original{
  
  NSMutableArray *ret = [[NSMutableArray alloc]init ];
  if (!original) return ret;
  for (id elem in original){
    if (elem){
      if ([elem isKindOfClass:[NSString class ]] || [elem isKindOfClass:[NSNumber class ]]){
        [ret addObject:elem];
      }else if ([elem isKindOfClass:[NSArray class]] ){
        [ret addObject:[self scanArray:elem]];
      }else if ([elem isKindOfClass:[NSDictionary class]] ){
        [ret addObject:[self scanDictionary:elem]];
      }else {
        [ret addObject:[self scanObject:elem]];
      }
    }
  }
  
  return ret;
}


-(NSMutableDictionary *) scanDictionary:(NSMutableDictionary *) original{
    
  NSMutableDictionary *ret = [[NSMutableDictionary alloc]init];
  if (!original) return ret;  
  for (id key in original){
    
    id elem = [original objectForKey:key];
    if (elem){
      if ([elem isKindOfClass:[NSString class ]] || [elem isKindOfClass:[NSNumber class ]]){
        [ret setObject:elem forKey:key];
      }else if ([elem isKindOfClass:[NSArray class]] ){
        [ret setObject:[self scanArray:elem] forKey:key];
      }else if ([elem isKindOfClass:[NSDictionary class]] ){
        [ret setObject:[self scanDictionary:elem] forKey:key];
      }else {
        [ret setObject:[self scanObject:elem] forKey:key];
      }
    }
    
  }
  return ret;
  
}

-(NSMutableDictionary *) scanObject:(NSObject *)obj{
  
  NSMutableDictionary *ret = [[NSMutableDictionary alloc]init ];
  if(!obj) return ret;
  @try {
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    
    for(i = 0; i < outCount; i++){  
      
      objc_property_t property = properties[i];
      const char *propName = property_getName(property);
      
      if(propName) {
        
        NSString *propertyName = [NSString stringWithUTF8String:propName];
        NSObject *value = [obj valueForKey:propertyName];
        
        if (value){
          if ([value isKindOfClass:[NSString class ]] || [value isKindOfClass:[NSNumber class ]]){
            
            [ret setObject:value forKey:propertyName];
          }else if ([value isKindOfClass:[NSArray class]] ){
            [ret setObject:[self scanArray:(NSMutableArray *)value] forKey:propertyName];
          }else if ([value isKindOfClass:[NSDictionary class]] ){
            [ret setObject:[self scanDictionary:(NSMutableDictionary *)value] forKey:propertyName];
          }else {
            [ret setObject:[self scanObject:value] forKey:propertyName];
          }
        } 
        
      }
    }
    
    free(properties);
  }
  @catch (NSException *exception) {
    NSLog(@"Exception %@",exception );
  }
  @finally {
    return ret;
  }
  
}



@end
