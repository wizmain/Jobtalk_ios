//
//  ActivityIndicator.m
//  mClass
//
//  Created by 김규완 on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProgressIndicator.h"
#import "AppDelegate.h"

@implementation ProgressIndicator

@synthesize backgroundImageView;
@synthesize activityIndicator;
@synthesize progressMessage;
@synthesize appDelegate;

- (id)initWithLabel:(NSString *)text {
	if (self = [super init]) {
		self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progressBackground.png"]];
		backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin);
		[self addSubview:backgroundImageView];
		
		progressMessage = [[UILabel alloc] initWithFrame:CGRectZero];
		progressMessage.textColor = [UIColor whiteColor];
		progressMessage.backgroundColor = [UIColor clearColor];
		progressMessage.font = [UIFont fontWithName:@"Helvetica" size:(14.0)];
		progressMessage.text = text;
		[self addSubview:progressMessage];
		
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
}

- (void)layoutSubviews {
	[progressMessage sizeToFit];
	
	progressMessage.center = [backgroundImageView center];
	activityIndicator.center = backgroundImageView.center;
	
	CGRect textRect = progressMessage.frame;
	textRect.origin.y += 30.0;
	progressMessage.frame = textRect;
	
	CGRect activityRect = activityIndicator.frame;
	activityRect.origin.y -= 10.0;
	activityIndicator.frame = activityRect;
	
	[self bringSubviewToFront:activityIndicator];
	[self bringSubviewToFront:progressMessage];
}

- (void)show {
	[super show];
	CGSize backgroundImageSize = self.backgroundImageView.image.size;
	self.bounds = CGRectMake(0, 0, backgroundImageSize.width, backgroundImageSize.height);
	[self layoutSubviews];
	[self.appDelegate setAlertRunning:YES];
	[self bringSubviewToFront:activityIndicator];
	[self bringSubviewToFront:progressMessage];
}

- (void)dismiss {
	[super dismissWithClickedButtonIndex:0 animated:YES];
	[self.appDelegate setAlertRunning:NO];
}

- (void)realDismissWithArgs:(NSArray *)args {
	NSInteger buttonIndex = [[args objectAtIndex:0] intValue];
	BOOL animated = [[args objectAtIndex:1] boolValue];
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[super performSelectorOnMainThread:@selector(realDismissWithArgs:) 
							withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:buttonIndex],[NSNumber numberWithBool:animated], nil] waitUntilDone:YES];
	[self.appDelegate setAlertRunning:NO];
}

- (void)dealloc {
	[activityIndicator release];
	[progressMessage release];
	[super dealloc];
}

@end
