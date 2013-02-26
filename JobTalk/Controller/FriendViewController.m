//
//  FriendViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 8..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "FriendViewController.h"
#import "AppDelegate.h"
#import "AlertUtils.h"
#import "Constant.h"
#import "JSON.h"
#import "TalkViewController.h"
#import "Utils.h"
#import "FriendListCell.h"

#define kFriendListTag  @"friendlist"
#define kMakeTalkTag   @"maketalk"
#define kFriendDelTag   @"frienddel"

@interface FriendViewController ()
@property (nonatomic, retain) IBOutlet UITableView *friendTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableArray *friendList;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation FriendViewController

@synthesize friendTable;
@synthesize friendList;
@synthesize selectedIndex;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //네비게이션 타이틀 설정
	self.navigationItem.title = @"친구";
    
    self.navigationItem.hidesBackButton = YES;
    
    //UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[editButton setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    //editButton.frame = CGRectMake(0, 0, 48, 30);
    
    /*
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(friendEdit) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, 48, 30);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
    [editButton release];
    */
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[addButton setBackgroundImage:[UIImage imageNamed:@"105-AddUser"] forState:UIControlStateNormal];
    //addButton.frame = CGRectMake(0, 0, 50, 30);
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[addButton setTitle:@"추가" forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"105-AddUserBlack"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(friendAdd) forControlEvents:UIControlEventTouchUpInside];
    addButton.frame = CGRectMake(0, 0, 50, 30);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    [addButton release];
	//[self bindFriendList];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self bindFriendList];
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
	self.friendList = nil;
    self.friendTable = nil;
    self.spinner = nil;
    [[[AppDelegate sharedAppDelegate] httpRequest] cancel];
}



- (void)dealloc {
	[friendList release];
    [friendTable release];
    [spinner release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Method

- (void)friendAdd {
    
}

- (void)friendEdit {
    self.friendTable.editing = !self.friendTable.editing;
}

- (void)bindFriendList {
    
    [self.spinner startAnimating];
    
    NSString *url = [kServerUrl stringByAppendingFormat:@"%@",kFriendListUrl];
	NSLog(@"url = %@", url);
    
    //request생성
	HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
    
	//통신완료 후 호출할 델리게이트 셀렉터 설정
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	//페이지 호출
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:kFriendListTag];
    
    /*
     NSError *error = nil;
     NSHTTPURLResponse *response = nil;
     NSData *responseData = [httpRequest requestUrlSync:url bodyObject:nil httpMethod:@"GET" error:error response:response];
     NSString *resultData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
     [self didReceiveFinished:resultData];
     */
}

- (void)deleteFriend:(NSInteger)friendID{
    [self.spinner startAnimating];
    HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
    NSString *friendIDString = [NSString stringWithFormat:@"%d", friendID];
    NSLog(@"deleteFriend friendID=%@", friendIDString);
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:friendIDString,@"uid", nil];
    
    
    [httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	NSString *url = [kServerUrl stringByAppendingFormat:@"%@",kFriendDelUrl];
	//페이지 호출
	[httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:kFriendDelTag];

}

#pragma mark -
#pragma mark Connection Result Delegate
- (void)didReceiveFinished:(NSString *)result {
	NSLog(@"receiveData : %@", result);
	
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
    
    if([tag isEqualToString:kFriendListTag]) {
        self.friendList = (NSMutableArray *)[resultData objectForKey:@"result"];
        
        if (friendList) {
            
            for (int i=0; i<friendList.count; i++) {
                //NSDictionary *item = (NSDictionary *)[lectureItemList objectAtIndex:i];
                //NSLog(@"ItemName = %@", [item objectForKey:@"itemNm"]);
            }
        }
        
        [self.friendTable reloadData];
    } else if([tag isEqualToString:kMakeTalkTag]) {
        
        NSArray *makeResult = (NSArray *)[resultData objectForKey:@"result"];
        
        int talkUid = -1;
        if(makeResult){
            if([makeResult count] > 0){
                NSDictionary *m = [makeResult objectAtIndex:0];
                talkUid = [[NSString stringWithFormat:@"%@",[m objectForKey:@"master_uid"]] intValue];
            }
        }
        //int talkUid = [[NSString stringWithFormat:@"%@",[makeResult objectForKey:@"master_uid"]] intValue];
        NSLog(@"talkUid=%d", talkUid);
        
        NSDictionary *item = [self.friendList objectAtIndex:self.selectedIndex];
        NSNumber *friendUid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"by_mbrid"]] intValue]];
        NSString *friendName = [NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
        NSString *friendID = [NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
        NSDictionary *user1 = [[NSDictionary alloc] initWithObjectsAndKeys:friendUid, @"mbrid", friendID, @"id", friendName, @"name", nil];
        NSLog(@"user1=%@",user1);
        
        NSMutableArray *chatUsers = [[NSMutableArray alloc] initWithObjects:user1, nil];
        
        TalkViewController *talkController = [[TalkViewController alloc] initWithNibName:@"TalkViewController" bundle:nil];
        talkController.chatUsers = chatUsers;
        talkController.talkUid = talkUid;
        UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:talkController];
        
        [self presentModalViewController:naviCon animated:YES];
        
    } else if([tag isEqualToString:kFriendDelTag]) {
        int deleteUid = [[NSString stringWithFormat:@"%@",[resultData objectForKey:@"friendUid"]] intValue];
        for (int i=0; i<self.friendList.count; i++) {
            
            NSDictionary *item = [self.friendList objectAtIndex:i];
            int friendID = [[NSString stringWithFormat:@"%@",[item objectForKey:@"by_mbrid"]] intValue];
            NSLog(@"friendID=%d deleteUid=%d", friendID, deleteUid);
            if (friendID == deleteUid) {
                [self.friendList removeObjectAtIndex:i];
            }
        }
        //[self.friendTable reloadData];
    }

	
	//[jsonWriter release];
	//[jsonParser release];
	
	
	[self.spinner stopAnimating];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.friendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: Double-check for performance drain later
	
    static NSString *normalCellIdentifier = @"친구목록";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
    
	if (cell == nil) {
        cell = [FriendListCell cellWithNib];
	}

	/*
	if (cell == nil) {
		UIImage *img = [UIImage imageNamed:@"103-Person2"];
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:normalCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		[cell.imageView setImage:img];
        cell.textLabel.textColor = UIColorFromRGB(0x0b6ad4);
	}
	*/
	NSUInteger row = [indexPath row];
	
	if (self.friendList != nil) {
		
		if(self.friendList.count > 0){
			NSDictionary *item = [self.friendList objectAtIndex:row];
			//cell.textLabel.text = [item objectForKey:@"name"];
            cell.titleLabel.text = [item objectForKey:@"name"];
            /*
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
            
            long long attendStartTime = [[NSString stringWithFormat:@"%@",[item objectForKey:@"attendStartDt"]] longLongValue];
			
			attendStartTime = attendStartTime / 1000;
			NSDate *attendStartDate = [NSDate dateWithTimeIntervalSince1970:attendStartTime];
			
            NSString *attendStartDateString = [dateFormat stringFromDate:attendStartDate];
            
            long long attendCloseTime = [[NSString stringWithFormat:@"%@",[item objectForKey:@"attendCloseDt"]] longLongValue];
			
			attendCloseTime = attendCloseTime / 1000;
			NSDate *attendCloseDate = [NSDate dateWithTimeIntervalSince1970:attendCloseTime];
			
            NSString *attendCloseDateString = [dateFormat stringFromDate:attendCloseDate];
            
			cell.detailTextLabel.text = [attendStartDateString stringByAppendingFormat:@" ~ %@", attendCloseDateString];
            */
			//NSString *imageUrl = [kServerUrl stringByAppendingString:@"/images/mobile/icon1.png"];
			//NSLog(@"image url = %@",imageUrl);
			//cell.imageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
		}
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"FriendViewController didSelectedRow");
	self.selectedIndex = [indexPath row];
    
	NSUInteger row = [indexPath row];
    
	NSDictionary *item = [self.friendList objectAtIndex:row];
	/*
    NSNumber *friendUid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"by_mbrid"]] intValue]];
    
    NSString *friendName = [NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
    NSString *friendID = [NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
    NSDictionary *user1 = [[NSDictionary alloc] initWithObjectsAndKeys:friendUid, @"mbrid", friendID, @"id", friendName, @"name", nil];
    NSLog(@"user1=%@",user1);
    
    //NSNumber *myUserNo = [NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
    //NSString *myUserID = [[AppDelegate sharedAppDelegate] authUserID];
    //NSString *myName = [Utils cookieValue:@"userName"];
    //NSDictionary *me = [[NSDictionary alloc] initWithObjectsAndKeys:myUserNo, @"uid", myUserID, @"id", myName, @"name", nil];
    NSMutableArray *chatUsers = [[NSMutableArray alloc] initWithObjects:user1, nil];
    
    [user1 release];
    //[me release];
    [chatUsers release];
    [naviCon release];
    */
    
    NSString *url = [kServerUrl stringByAppendingFormat:@"%@?search_uid=%@",kTalkRoomListByUrl, [item objectForKey:@"by_mbrid"]];
	NSLog(@"url = %@", url);
    
    //request생성
	HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
    
	//통신완료 후 호출할 델리게이트 셀렉터 설정
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	//페이지 호출
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:kMakeTalkTag];
    
    
}

- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	//NSUInteger row = [indexPath row];
	
	//NSDictionary *item = [self.friendList objectAtIndex:row];
	//NSInteger friendUid = [[NSString stringWithFormat:@"%@",[item objectForKey:@"uid"]] intValue];
	/*
	LectureItemDetailController *itemDetail = [[LectureItemDetailController alloc] initWithNibName:@"LectureItemDetailController" bundle:[NSBundle mainBundle]];
	itemDetail.lectureNo = lectureNo;
	itemDetail.itemNo = itemNo;
	itemDetail.itemName = [item objectForKey:@"itemNm"];
	[self.navigationController pushViewController:itemDetail animated:YES];
	[itemDetail release];
	itemDetail = nil;
    */
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    
    
    
    NSLog(@"setEditing");
    //[self.talkTable reloadData];
    if(editing == YES){
        
        
                
    } else {
        
    }
    [super setEditing:editing animated:animated];
    
    [self.friendTable setEditing:editing animated:YES];
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // remove the row here.
        NSLog(@"Delete Click");
        NSUInteger row = [indexPath row];
        
        NSDictionary *item = [self.friendList objectAtIndex:row];
        NSLog(@"delete item = %@", item);
        
        //서버 에서 삭제 호출
        [self deleteFriend:[[NSString stringWithFormat:@"%@",[item objectForKey:@"uid"]] intValue]];
        //서버 결과 관계 없이 일단 목록에서 먼저 삭제
        [self.friendList removeObjectAtIndex:row];
        
        [self.friendTable reloadData];
        
    }
}



@end
