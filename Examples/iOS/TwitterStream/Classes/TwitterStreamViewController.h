//
//  TwitterStreamViewController.h
//  TwitterStream
//
//  Created by Stig Brautaset on 05/12/2010.
//  Copyright Stig Brautaset 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <JSON/JSON.h>

@interface TwitterStreamViewController : UIViewController <SBJsonStreamParserAdapterDelegate> {
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	
	IBOutlet UITextField *userName;
	IBOutlet UITextField *password;
	IBOutlet UITextView *tweet;
}

- (IBAction)startStreaming;

@end

