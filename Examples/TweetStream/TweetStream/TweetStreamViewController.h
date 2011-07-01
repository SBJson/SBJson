//
//  TweetStreamViewController.h
//  TweetStream
//
//  Created by Stig Brautaset on 24/05/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SBJson/SBJson.h>
 
@interface TweetStreamViewController : UIViewController <SBJsonStreamParserDelegate> {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UITextView *tweet;
    
    NSURLConnection *theConnection;
    SBJsonStreamParser *parser;
}

- (IBAction)go;

@end
