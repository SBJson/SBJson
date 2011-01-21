//
//  ObjectSerialization.m
//  JSON
//
//  Created by Shairon Toledo on 1/21/11.
//  Copyright 2011 OfficeDrop. All rights reserved.
//

#import "ObjectSerialization.h"
#import "JSON.h"
#import "SBJsonModelConverter.h"
#pragma mark PersonClass

@interface Person : NSObject {
  NSString *name;
  float code;
  NSInteger thenumber;
  BOOL active;
  NSDate *created_at;
  NSDate *updated_at;
  NSMutableArray *messages;    
}
@property(retain, nonatomic) NSString *name;
@property float code;
@property NSInteger thenumber;
@property BOOL active;
@property(retain, nonatomic) NSDate *created_at;
@property(retain, nonatomic) NSDate *updated_at;
@property(retain, nonatomic) NSMutableArray *messages;  
@end

@implementation Person
@synthesize name, code, thenumber, active, created_at, updated_at, messages;
@end

#pragma mark MessageClass
@interface Message : NSObject {
  NSString *subject;
  NSString *body;
  BOOL read;    
}
@property(retain, nonatomic) NSString *subject;
@property(retain, nonatomic) NSString *body;
@property BOOL read;  
@end

@implementation Message
@synthesize subject, body, read;
@end

@implementation ObjectSerialization

-(void) testConvertModelToDictionary{
  
  Person *person = [[Person alloc]init];
  person.active = YES;
  person.code = 1.2;
  person.name = @"Joe Bill";
  person.thenumber = 500;

  Message *msg1 =[[Message alloc]init];
  msg1.body=@"Hi I'm a body";
  msg1.subject = @"The subject of message";
  msg1.read = NO;
  
  Message *msg2 =[[Message alloc]init];
  msg2.body=@"Hi I'm a body2";
  msg2.subject = @"The subject of message2";
  msg2.read = YES;
  
  person.messages = [[NSMutableArray alloc]initWithObjects:msg1,msg2, nil];
  NSMutableDictionary *result = [[[SBJsonModelConverter alloc]init] scanObject:person];
  
  SBJsonWriter *sw = [[SBJsonWriter alloc]init];

  NSLog(@"testing\n\n%@\n\n\n",[sw stringWithObject:result]);
  
  STAssertEqualObjects([result objectForKey:@"active"],  [[NSNumber alloc]initWithBool:YES]  , @"should get result as BOOL",nil);
  STAssertEqualObjects([result objectForKey:@"code"], [[NSNumber alloc]initWithFloat:1.2] , @"should get result as float",nil);
  STAssertEqualObjects([result objectForKey:@"name"], person.name , @"should get result as string",nil);
  STAssertEqualObjects([result objectForKey:@"thenumber"], [[NSNumber alloc]initWithInt:500] , @"should get result as int",nil); 
  
  NSMutableDictionary *resultMsg1 =[[result objectForKey:@"messages"] objectAtIndex:0];
  NSMutableDictionary *resultMsg2 =[[result objectForKey:@"messages"] objectAtIndex:1];

  //For msg1
  STAssertEqualObjects([resultMsg1 objectForKey:@"body"], msg1.body , @"should get result as string",nil);
  STAssertEqualObjects([resultMsg1 objectForKey:@"subject"], msg1.subject , @"should get result as string",nil);
  STAssertEqualObjects([resultMsg1 objectForKey:@"read"],  [[NSNumber alloc]initWithBool:NO]  , @"should get result as BOOL",nil);  

  //For msg2
  STAssertEqualObjects([resultMsg2 objectForKey:@"body"], msg2.body , @"should get result as string",nil);
  STAssertEqualObjects([resultMsg2 objectForKey:@"subject"], msg2.subject , @"should get result as string",nil);
  STAssertEqualObjects([resultMsg2 objectForKey:@"read"],  [[NSNumber alloc]initWithBool:YES]  , @"should get result as BOOL",nil);  

  NSString *json = @"{\"code\":1.2,\"messages\":[{\"subject\":\"The subject of message\",\"read\":0,\"body\":\"Hi I'm a body\"},{\"subject\":\"The subject of message2\",\"read\":1,\"body\":\"Hi I'm a body2\"}],\"active\":1,\"name\":\"Joe Bill\",\"thenumber\":500}";
  
  //STAssertEqualObjects(json, [sw stringWithObject:result], @"json string should be same of result after serialization", nil);
} 
@end
