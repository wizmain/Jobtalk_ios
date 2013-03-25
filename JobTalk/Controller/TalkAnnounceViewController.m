//
//  TalkAnnounceViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 2. 19..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkAnnounceViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "HTTPRequest.h"
#import "TalkRoom.h"
#import "TalkMessage.h"
#import "JSON.h"
#import "Utils.h"
#import "TalkSetReadOperation.h"
#import "TalkDataManager.h"
#import "AlertUtils.h"

@interface TalkAnnounceViewController ()

@property (nonatomic, retain) IBOutlet UITextView *announceText;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) TalkDataManager *talkDataManager;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)sendMessage:(id)sender;

@end

@implementation TalkAnnounceViewController

@synthesize announceText, sendButton;
@synthesize talkDataManager;
@synthesize indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"공지보내기";
    self.talkDataManager = [[TalkDataManager alloc] init];

    announceText.layer.cornerRadius = 5;
    announceText.layer.borderColor = [[UIColor grayColor] CGColor];
    announceText.clipsToBounds = YES;
    announceText.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.announceText = nil;
    self.sendButton = nil;
    self.indicator = nil;
    self.talkDataManager = nil;
    [[[AppDelegate sharedAppDelegate] httpRequest] cancel];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.talkDataManager setDelegate:self];
    [super viewWillAppear:animated];
    
}

- (void)dealloc {
    [announceText release];
    [sendButton release];
    [indicator release];
    [talkDataManager release];
    [super dealloc];
}



- (IBAction)sendMessage:(id)sender {
    
    [self.indicator startAnimating];
	NSString *msgContent = announceText.text;
    NSLog(@"msgContent=%@", msgContent);
    
    [self.talkDataManager sendAnnounce:msgContent];
    
}

- (void)sendMessageResult:(TalkMessage *)talkMessage {
    NSLog(@"delegate sendMessageResult %@", talkMessage);
    [self.indicator stopAnimating];
    if([talkMessage.talk_id intValue] > 0){
        NSString *cancelTitle = @"닫기";
        
        NSString *message = @"전송되었습니다";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"공지전송"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    
}

- (void)hideKeyboard
{
    //[self.view endEditing:YES];
    [announceText resignFirstResponder];
}

@end
