//
//  AlertUtils.m
//  mClass
//
//  Created by 김규완 on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlertUtils.h"


void AlertWithError(NSError *error)
{
    NSString *message = [NSString stringWithFormat:@"Error! %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	
	AlertWithMessage (message);
}


void AlertWithMessage(NSString *message)
{
	/* open an alert with an OK button */
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:message
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


void AlertWithMessageAndDelegate(NSString *message, id delegate)
{
	/* open an alert with OK and Cancel buttons */
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:message
												   delegate:delegate 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles: @"OK", nil];
	[alert show];
	[alert release];
}

void AlertWithMessageAndIndicator(NSString *title, id delegate)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													 message:nil 
													delegate:delegate 
										   cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:nil];
						  
	[alert show];
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
										  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicator.center = CGPointMake(alert.bounds.size.width/2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
	[alert release];
}