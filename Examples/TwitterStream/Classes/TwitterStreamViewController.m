//
//  TwitterStreamViewController.m
//  TwitterStream
//
//  Created by Stig Brautaset on 05/12/2010.
//  Copyright Stig Brautaset 2010. All rights reserved.
//

#import "TwitterStreamViewController.h"
#import <JSON/JSON.h>

@implementation TwitterStreamViewController

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
	NSLog(@"ArrayTweet: '%@'", array);	
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSString *text = [dict objectForKey:@"text"];
	tweet.text = text;
	NSLog(@"Tweet: '%@'", text);
}

- (IBAction)startStreaming {
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
	parser.multi = YES;
	
	NSString *url = @"http://stream.twitter.com/1/statuses/sample.json";
	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	
	[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}	

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
	
	NSURLCredential *credential = [NSURLCredential credentialWithUser:userName.text password:password.text persistence:NSURLCredentialPersistenceForSession];
	
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	SBJsonStreamParserStatus status = [parser parse:data];
	if (status == SBJsonStreamParserError) {
		NSLog(@"Parser error: %@", parser.error);
	} else if (status == SBJsonStreamParserWaitingForData) {
		NSLog(@"Parser waiting for more data");
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
	[parser release];
	[adapter release];
	parser = nil;
	adapter = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
