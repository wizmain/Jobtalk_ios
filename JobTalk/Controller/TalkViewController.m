//
//  TalkViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 10..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "HTTPRequest.h"
#import "TalkRoom.h"
#import "TalkMessage.h"
#import "JSON.h"
#import "Utils.h"
#import "TalkSetReadOperation.h"

#define kCellImageViewTag		1000
#define kCellLabelViewTag		1001
#define kBallonViewTag          1002
#define kLabelIndentedRect	CGRectMake(40.0, 12.0, 275.0, 20.0)
#define kLabelRect			CGRectMake(15.0, 12.0, 275.0, 20.0)
#define kChatUserDataTag        @"chatUser"
#define kTalkDataTag            @"talkData"
#define kNotiName               @"receivePush"

@interface TalkViewController ()

@property (nonatomic, retain) IBOutlet UITableView *talkTable;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) HPGrowingTextView *addMessageField;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) UIBarButtonItem *talkOutButton;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) TalkDataManager *talkDataManager;
@property (nonatomic, retain) NSOperationQueue *messageReadQueue;


- (void)sendMessage:(id)sender;
@end

@implementation TalkViewController

@synthesize talkTable, toolbar;
@synthesize sendButton, backButton, talkOutButton;
@synthesize addMessageField;
@synthesize chatUsers, talkUid;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize messageReadQueue = _messageReadQueue;
@synthesize talkDataManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"viewDidLaod talkUid=%d", talkUid);
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.talkTable addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    self.navigationItem.title = @"대화";
    
    self.managedObjectContext = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSError *error;
    
    
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"닫기"
                                                     style:UIBarButtonItemStyleBordered
                                                    target:self
                                                    action:@selector(closeTalk:)];
	talkOutButton = [[UIBarButtonItem alloc] initWithTitle:@"나가기"
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(talkOut:)];
	
	self.navigationItem.leftBarButtonItem = backButton;
	self.navigationItem.rightBarButtonItem = talkOutButton;
    
    talkTable.backgroundColor = RGB(121, 121, 121);
	
	
	addMessageField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, 250, 32)];
	addMessageField.delegate = self;
    addMessageField.layer.cornerRadius = 10;
    addMessageField.clipsToBounds = YES;
    
	UIBarButtonItem *textField = [[UIBarButtonItem alloc] initWithCustomView:addMessageField];
	
	sendButton = [[UIBarButtonItem alloc] initWithTitle:@"전송" style:UIBarButtonItemStyleBordered
                                                 target:self
                                                 action:@selector(sendMessage:)];
	
	toolbar.items = [[NSArray alloc] initWithObjects:textField, sendButton, nil];
    
    self.talkDataManager = [TalkDataManager sharedManager];
    [self.talkDataManager setDelegate:self];

    //기존 대화방 입장이면 대화대상자 정보 가져온다.
    if(talkUid > 0){
        //[self bindChatUsers];
        //[self requestServerChatData];
        [self.talkDataManager requestChatUserList:[NSNumber numberWithInt:talkUid]];
        [self.talkDataManager requestServerChatData:[NSNumber numberWithInt:talkUid]];
    } else {
        if(self.chatUsers == nil){
            NSLog(@"chatUser nil");
        } else {
            NSLog(@"chatUser not nil");
        }
    }

    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageFieldDidChange:)
												 name:@"textViewDidChange" object:addMessageField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePush:) name:kNotiName object:nil];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.talkDataManager.delegate = nil;
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.talkTable = nil;
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    self.talkDataManager = nil;
    [[[AppDelegate sharedAppDelegate] httpRequest] cancel];
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        // Will be removed from window, similar to -viewDidUnload.
        // Unsubscribe from any notifications here.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
/*
- (void)didMoveToWindow {
    if (self.window) {
        // Added to a window, similar to -viewDidLoad.
        // Subscribe to notifications here.
    }
}
*/
- (void)dealloc {
    [talkTable release];
    [_fetchedResultsController release];
    [_messageReadQueue release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (NSOperationQueue *)messageReadQueue {
    if(_messageReadQueue == nil){
        _messageReadQueue = [[NSOperationQueue alloc] init];
        [_messageReadQueue setMaxConcurrentOperationCount:5];
    }
    return _messageReadQueue;
}


#pragma mark -
#pragma mark TalkDataManager Delegate
//대화상대 데이타
- (void)bindChatUser:(NSMutableArray*)chatUserData {
    NSLog(@"delegate bindChatUser");
    self.chatUsers = chatUserData;
}

- (void)bindTalkData:(NSMutableArray*)talkData {
    NSLog(@"delegate bindChatData");
    if(self.talkTable){
        [self.talkTable reloadData];
    }
    [self adjustTableScroll];
}

- (void)sendMessageResult:(TalkMessage *)talkMessage {
    NSLog(@"delegate sendMessageResult %@", talkMessage);
    if(self.talkTable){
        [self.talkTable reloadData];
    }
    [self adjustTableScroll];
    addMessageField.text = @"";
    
}


#pragma mark -
#pragma mark Custom Method

- (void)receivePush:(NSNotification *)notif {
    //NSLog(@"notif userInfo=%@", [notif userInfo]);
    NSDictionary *userInfo = [notif userInfo];
    //NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    int masterUid = [[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"master_uid"]] integerValue];
    //NSLog(@"masterUid=%d", masterUid);
    if(talkUid == masterUid){
        if(self.talkDataManager) {
            [self.talkDataManager requestServerChatData:[NSNumber numberWithInt:talkUid]];
        }
    }
}

- (void)talkMessageRead:(NSNumber *)talkID {
    
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"talkMessageRead talkID=%@", talkID);
    if(self.talkDataManager) {
        [self.talkDataManager setTalkMessageRead:talkID];
    }
    //[pool release];
}

- (void)closeTalk:(id)sender {
    NSLog(@"closeTalk");
    /*
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    for (int i=0; i<results.count; i++) {
        TalkMessage *talkMessage = [results objectAtIndex:i];
        talkMessage.master_uid = [NSNumber numberWithInt:22];
        talkMessage.user_no =[NSNumber numberWithInt:3];
        talkMessage.user_name = @"홍길동";
    }
    
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    //[[[AppDelegate sharedAppDelegate] mainViewController] switchTabView:1];
}

- (void)talkOut:(id)sender {
    NSLog(@"talkOut");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isExistTalk:(NSNumber *)talkID {
    
    NSArray *sections = self.fetchedResultsController.sections;
    
    if (sections) {
        
        if(sections.count > 0)
        {
            //NSLog(@"section count=%d", sections.count);
            for (int i=0; i<sections.count; i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
                
                NSArray *dataArray = [sectionInfo objects];
                TalkMessage *talkMessage = (TalkMessage*)[dataArray objectAtIndex:0];
                //NSLog(@"talkRoom.name=%@",talkRoom.name);
                if([talkMessage.talk_id isEqualToNumber:talkID]){
                    return YES;
                    
                }
            }
        }
    }
    
    return NO;
}

- (void)adjustTableSize:(NSValue *)frameValue {
	self.talkTable.frame = [frameValue CGRectValue];
	[self adjustTableScroll];
}


- (void)adjustTableScroll {
    
	if(self.fetchedResultsController.fetchedObjects.count > 0)
	{
        //NSUInteger index = self.fetchedResultsController.fetchedObjects.count - 1;
        NSArray *sections = self.fetchedResultsController.sections;
        NSInteger sectionCnt = [[self.fetchedResultsController sections] count];
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionCnt-1];
        NSInteger numberOfRows = [sectionInfo numberOfObjects]-1;
		[self.talkTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows inSection:sectionCnt-1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

- (void)sendMessage:(id)sender {
    
	if(![addMessageField.text isEqualToString:@""])
	{
		NSString *msgContent = addMessageField.text;
		NSLog(@"msgContent=%@", msgContent);
        
        [self.talkDataManager requestSendMessage:[NSNumber numberWithInt:talkUid] chatUsers:chatUsers msgContent:msgContent];
	}
    
}

#pragma mark -
#pragma mark textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"textFieldShouldReturn");
	/*
     [textField resignFirstResponder];
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:0.3];
     
     toolbar.frame = CGRectMake(0, 372, 320, 44);
     table.frame = CGRectMake(0, 0, 320, 372);
     [UIView commitAnimations];
     */
	return YES;
}

#pragma mark -
#pragma mark Keyboard delegate

- (void)keyboardWillHide:(NSNotification *)notif{
    // get keyboard size and location
	CGRect keyboardBounds;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	
	// get a rect for the textView frame
	//CGRect tableFrame = table.frame;
	//tableFrame.origin.y += kbSizeH;
	self.talkTable.frame = CGRectMake(self.talkTable.frame.origin.x, self.talkTable.frame.origin.y, self.talkTable.frame.size.width, self.talkTable.frame.size.height+kbSizeH);
	//table.frame = tableFrame;
	CGRect toolbarFrame = toolbar.frame;
	toolbarFrame.origin.y += kbSizeH;
	// set views with new info
	toolbar.frame = toolbarFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif {
	
	// get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
	
	NSLog(@"keyboardWillShow");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
	
	CGRect toolbarFrame = toolbar.frame;
	toolbarFrame.origin.y -= kbSizeH;
	toolbar.frame = toolbarFrame;
	
	//먼저 늘어난 사이즈만큼 위로 올리고 스크롤을 위해 다시 사이즈 조정
	CGRect changeFrame = self.talkTable.frame;
	changeFrame.size.height -=kbSizeH;
	NSValue *chageFrameValue = [NSValue valueWithCGRect:changeFrame];
	
	CGRect tableFrame = self.talkTable.frame;
	//float originY = tableFrame.origin.y;
	tableFrame.origin.y -= kbSizeH;
	self.talkTable.frame = tableFrame;
	
	[UIView commitAnimations];
	
	//table.frame = CGRectMake(table.frame.origin.x, originY, table.frame.size.width, table.frame.size.height-kbSizeH);
	[self performSelector:@selector(adjustTableSize:) withObject:chageFrameValue afterDelay:0.3];
	
	[self adjustTableScroll];
}

#pragma mark -
#pragma mark HPGrowingTextView delegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
	
	
	float diff = (growingTextView.frame.size.height - height);
	
	NSLog(@"growingTextView height=%f diff=%f", height, diff);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
	
	CGRect toolbarFrame = toolbar.frame;
	toolbarFrame.origin.y += diff;
	toolbarFrame.size.height -= diff;
	toolbar.frame = toolbarFrame;
	
	//먼저 늘어난 사이즈만큼 위로 올리고 스크롤을 위해 다시 사이즈 조정
	CGRect changeFrame = self.talkTable.frame;
	changeFrame.size.height +=diff;
	NSValue *chageFrameValue = [NSValue valueWithCGRect:changeFrame];
	
	CGRect tableFrame = self.talkTable.frame;
	//float originY = tableFrame.origin.y;
	tableFrame.origin.y += diff;
	self.talkTable.frame = tableFrame;
	
	//table.frame = CGRectMake(table.frame.origin.x, originY, table.frame.size.width, table.frame.size.height+diff);
	[self performSelector:@selector(adjustTableSize:) withObject:chageFrameValue afterDelay:0.3];
	
	//toolbar.frame = CGRectMake(0, 156, 320, 44);
	//table.frame = CGRectMake(0, 0, 320, 156);
	[UIView commitAnimations];
}




#pragma mark -
#pragma mark HTTPRequest delegate
/*
- (void)didReceiveFinished:(NSString*) result {
    // JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
    NSDictionary *jsonObj = [jsonParser objectWithString:result];
    NSDictionary *resultData = [jsonObj objectForKey:@"resultData"];
    
    NSString *tag = [resultData valueForKey:@"tag"];
    NSLog(@"resultData =%@", resultData);
    NSLog(@"tag==%@",tag);
    NSDictionary *resultObj = [resultData objectForKey:@"result"];
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    NSString *resultString = [jsonWriter stringWithObject:resultObj];
    NSLog(@"tag=%@ resultString=%@", tag, resultString);
    
    if([tag isEqualToString:kChatUserDataTag]) {
        self.chatUsers = (NSMutableArray *)[resultData objectForKey:@"result"];
    } else if([tag isEqualToString:kTalkDataTag]) {
        NSArray *serverChatData = (NSArray *)[resultData objectForKey:@"result"];
        if(serverChatData){
            
            if(serverChatData.count > 0){
                
                for (int i=0; i<serverChatData.count; i++) {
                    NSDictionary *talkMessage = [serverChatData objectAtIndex:i];
                    
                    //로컬에 저장되어 있지 않으면 로컬에 대화저장
                    if(![self isExistTalk:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]]]){
                        
                        NSLog(@"not exist");
                        
                        //NSNumber *masterUid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"master_uid"]] intValue]];
                        //NSNumber *talkID = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]];
                        //NSString *message = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"content"]];
                        //NSString *sendUserName = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"name"]];
                        //NSNumber *sendUserNo = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"mbrid"]] intValue]];
                        
                        //로컬에 등록
                        //if([self addMessage:masterUid talkID:talkID message:message sendUserName:sendUserName sendUserNo:sendUserNo]){
                            //서버에서 삭제
                        //    [self setServerTalkRead:talkID senderNo:sendUserNo];
                        //}
                        
                    } else {
                        NSLog(@"exist");
                    }
                }
            }
        }
    }
}

- (void)didSendMessageFinished:(NSString *)result {
	
	NSLog(@"receiveData : %@", result);
	
	// JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	
	NSDictionary *jsonData = [jsonParser objectWithString:result];
	
    NSNumber *talkId = [[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[jsonData objectForKey:@"talk_id"]] intValue]];
    
    NSDictionary *receiver = [chatUsers objectAtIndex:0];
    
    if(talkId > 0){
        //기존의 대화방 없으면 추가
        if(talkUid < 1){
            talkUid = [[NSString stringWithFormat:@"%@",[jsonData objectForKey:@"master_uid"]] intValue];
            NSFetchRequest *request= [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
            NSPredicate *predicate =[NSPredicate predicateWithFormat:@"master_uid==%d",talkUid];
            [request setEntity:entity];
            [request setPredicate:predicate];
            
            NSError *error = nil;
            
            NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (array != nil) {
                NSLog(@"talkRoom exist");
            } else {
                NSLog(@"talkRoom does not exist.");
                //대화방 없으면 등록
                TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                talkRoom.name = [NSString stringWithFormat:@"%@", [receiver objectForKey:@"name"]];
                talkRoom.master_uid = [[NSNumber alloc] initWithInt:talkUid];
                talkRoom.user_no = [NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
                talkRoom.last_message = addMessageField.text;
                talkRoom.last_message_date = [NSDate date];
                talkRoom.last_message_user = [Utils cookieValue:@"userName"];
                NSError *error = nil;
                if(![self.managedObjectContext save:&error]){
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
        
        //로컬에 등록
        //[self addMessage:[NSNumber numberWithInt:talkUid] talkID:talkId message:addMessageField.text sendUserName:[Utils cookieValue:@"userName"] sendUserNo:[NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]]];
        
    }
	addMessageField.text = @"";

}
*/
#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    /*
    NSArray *sections = self.fetchedResultsController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    */
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	static NSString *CellIdentifier = @"MessageCell";
	
	UIImageView *balloonView;
	UILabel *label;
	//NSInteger row = [indexPath row];
	//float w = 0.0;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = kBallonViewTag;
		
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.tag = kCellLabelViewTag;
		label.numberOfLines = 0;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.font = [UIFont systemFontOfSize:14.0];
		
		UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		message.tag = 0;
		[message addSubview:balloonView];
		[message addSubview:label];
		[cell.contentView addSubview:message];
		
		[balloonView release];
		[label release];
		[message release];
		
	}

	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TalkMessage *talkMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
	NSString *body = (NSString *)talkMessage.content;
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    int userNo = [[AppDelegate sharedAppDelegate] authUserNo];
    // Configure the cell to show the book's title
    TalkMessage *talkMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //읽음설정
    if([talkMessage.read_yn compare:[NSNumber numberWithBool:NO]] == NSOrderedSame){
        //[NSThread detachNewThreadSelector:@selector(talkMessageRead:) toTarget:self withObject:talkMessage.talk_id];
        //[self.talkDataManager setTalkMessageRead:talkMessage.talk_id];
        //[self talkMessageRead:talkMessage.talk_id];
        TalkSetReadOperation *op = [[[TalkSetReadOperation alloc] initWithTalkID:talkMessage.talk_id] autorelease];
        [[self messageReadQueue] addOperation:op];
    }
    
    
    UIImageView *balloonView = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:kBallonViewTag];
    UILabel *label = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:kCellLabelViewTag];
        
	NSString *text = talkMessage.content;
    
	
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	NSLog(@"talkMessage = %@", talkMessage);
	NSLog(@"userNo=%d talkMessage.userNo=%@", userNo, talkMessage.user_no);
	if( userNo == [talkMessage.user_no intValue])
	{
        balloonView.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
		balloonView.image = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
		
	}
	else
	{
		balloonView.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);
		balloonView.image = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(16, 8, size.width + 5, size.height);
	}
	
	label.text = talkMessage.content;
    
    
}

#pragma mark -
#pragma mark Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
    //NSNumber *master_uid = [NSNumber numberWithInt:talkUid];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"master_uid == %d", talkUid];
    NSLog(@"fetchResultsController talkUid=%d", talkUid);
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *uidDescriptor = [[NSSortDescriptor alloc] initWithKey:@"talk_id" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:uidDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"talk_id" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    // Memory management.
    [fetchRequest release];
    [sortDescriptors release];
    
    return _fetchedResultsController;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.talkTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.talkTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.talkTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            NSString *sectionKeyPath = [controller sectionNameKeyPath];
            if (sectionKeyPath == nil)
                break;
            NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
            NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
            id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
            for (int i = 0; i < [keyParts count] - 1; i++) {
                NSString *onePart = [keyParts objectAtIndex:i];
                changedObject = [changedObject valueForKey:onePart];
            }
            sectionKeyPath = [keyParts lastObject];
            NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
            
            if ([[committedValues valueForKeyPath:sectionKeyPath] isEqual:currentKeyValue])
                break;
            
            NSUInteger tableSectionCount = [self.talkTable numberOfSections];
            NSUInteger frcSectionCount = [[controller sections] count];
            if (tableSectionCount != frcSectionCount) {
                // Need to insert a section
                NSArray *sections = controller.sections;
                NSInteger newSectionLocation = -1;
                for (id oneSection in sections) {
                    NSString *sectionName = [oneSection name];
                    if ([currentKeyValue isEqual:sectionName]) {
                        newSectionLocation = [sections indexOfObject:oneSection];
                        break;
                    }
                }
                if (newSectionLocation == -1)
                    return; // uh oh
                
                if (!((newSectionLocation == 0) && (tableSectionCount == 1) && ([self.talkTable numberOfRowsInSection:0] == 0)))
                    [self.talkTable insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation] withRowAnimation:UITableViewRowAnimationFade];
                NSUInteger indices[2] = {newSectionLocation, 0};
                newIndexPath = [[[NSIndexPath alloc] initWithIndexes:indices length:2] autorelease];
            }
        }
        case NSFetchedResultsChangeMove:
            if (newIndexPath != nil) {
                
                NSUInteger tableSectionCount = [self.talkTable numberOfSections];
                NSUInteger frcSectionCount = [[controller sections] count];
                if (frcSectionCount > tableSectionCount)
                    [self.talkTable insertSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                else if (frcSectionCount < tableSectionCount && tableSectionCount > 1)
                    [self.talkTable deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                
                
                [self.talkTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.talkTable insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationRight];
                
            }
            else {
                [self.talkTable reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if (!((sectionIndex == 0) && ([self.talkTable numberOfSections] == 1)))
                [self.talkTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            if (!((sectionIndex == 0) && ([self.talkTable numberOfSections] == 1) ))
                [self.talkTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.talkTable endUpdates];
}

- (void)hideKeyboard
{
    //[self.view endEditing:YES];
    [addMessageField resignFirstResponder];
}
@end
