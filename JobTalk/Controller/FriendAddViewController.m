//
//  FriendAddViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 8..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "FriendAddViewController.h"
#import "HTTPRequest.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "Constant.h"
#import "AlertUtils.h"
#import "CustomTableCell1.h"
#import "NSString+Helpers.h"

@interface FriendAddViewController ()

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *userList;
@property (nonatomic, retain) NSMutableArray *copiedUserList;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL isSelectRow;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation FriendAddViewController

@synthesize searchBar, userList, copiedUserList, searching, isSelectRow;
@synthesize table, searchDisplayController;


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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self
											  action:@selector(closeWindow:)];
	self.navigationItem.title = @"친구찾기";
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
    self.searchBar = nil;
    self.userList = nil;
    self.copiedUserList = nil;
    self.table = nil;
    self.copiedUserList = nil;
    self.searchDisplayController = nil;
}


- (void)dealloc {
	[searchBar release];
	[userList release];
	[copiedUserList release];
    [table release];
    [copiedUserList release];
    [searchDisplayController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Method
- (void)searchUser {
	
	NSString *url = [kServerUrl stringByAppendingString:kUserSearchUrl];
	//NSString *query = [NSString stringWithFormat:@"/%@/1", searchBar.text];
	//url = [url stringByAppendingString:query];
	
	HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
	NSLog(@"url = %@", url);
	
	//POST로 전송할 데이터 설정
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:searchBar.text, @"memberid", searchBar.text, @"membername", nil];
	//통신완료 후 호출할 델리게이트 셀렉터 설정
	[httpRequest setDelegate:self selector:@selector(didSearchUserReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:nil];
	
}
- (void)closeWindow:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)friendAdd:(id)sender {
    UIButton *addButton = (UIButton *)sender;
    NSLog(@"friendUid=%d",addButton.tag);
    
    NSString *friendUid = [NSString stringWithFormat:@"%d",addButton.tag];
    NSString *url = [kServerUrl stringByAppendingString:kFriendAddUrl];
	//NSString *query = [NSString stringWithFormat:@"/%@/1", searchBar.text];
	//url = [url stringByAppendingString:query];
	
	HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
	NSLog(@"url = %@", url);
	NSLog(@"friendUid = %@", friendUid);
	//POST로 전송할 데이터 설정
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:friendUid, @"friend", nil];
	//통신완료 후 호출할 델리게이트 셀렉터 설정
	[httpRequest setDelegate:self selector:@selector(didFriendAddReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:nil];
}


#pragma mark -
#pragma mark HTTPRequest delegate
- (void)didFriendAddReceiveFinished:(NSString *)result {
    // JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	
	NSDictionary *resultObj = (NSDictionary *)[jsonParser objectWithString:result];
    int uid = [[NSString stringWithFormat:@"%@", [resultObj objectForKey:@"uid"]] intValue];
    NSString *message = [resultObj objectForKey:@"message"];
    
    if(uid > 0){
        AlertWithMessage(@"추가되었습니다");
    } else {
        AlertWithMessage(message);
    }
}

- (void)didSearchUserReceiveFinished:(NSString *)result {
	NSLog(@"result = %@", result);
	
	// JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	
	self.userList = (NSMutableArray *)[jsonParser objectWithString:result];
    
    [self.searchDisplayController.searchResultsTableView reloadData];
	
    /* 여러데이타 태그로 구분하여 받을때 샘플
    SBJsonParser *jsonParser = [SBJsonParser new];
    NSDictionary *jsonObj = [jsonParser objectWithString:result];
    NSDictionary *resultData = [jsonObj objectForKey:@"resultData"];
    
    
    NSString *tag = [resultData valueForKey:@"tag"];
    NSDictionary *resultObj = [resultData objectForKey:@"result"];
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    NSString *resultString = [jsonWriter stringWithObject:resultObj];
    NSLog(@"tag = %@, resultString = %@", tag, resultString);
    
    //NSDictionary받을때
    //NSLog(@"receiveDic :%@", result);
    //NSString *tag = [result objectForKey:@"tag"];
    //NSString *resultString = [result objectForKey:@"result"];
    
    
    if ([tag isEqualToString:kLectureInfoTag]) {
        
        [self didLectureInfoReceiveFinished:resultString];
    } else if([tag isEqualToString:kLectureStatTag]) {
        [self didLectureStatReceiveFinished:resultString];
    } else if ([tag isEqualToString:kStudentAttendInfoTag]) {
        [self didStudentAttendInfoReceiveFinished:resultString];
    }
    */
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection = %d", [self.userList count]);
	//return [self.userList count];
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        // NSLog(@"count is %d", [self.filteredListContent count]);
        return [self.userList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: Double-check for performance drain later
	
    static NSString *normalCellIdentifier = @"CustomTableCell1";
    
    CustomTableCell1 *cell = (CustomTableCell1*)[tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCellIdentifier] autorelease];
        //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableCell1" owner:self options:nil];
        //cell = [nib objectAtIndex:0];
        cell = [CustomTableCell1 cellWithNib];
	}
	
	NSUInteger row = [indexPath row];
	
	if (self.userList != nil) {
		
		if(self.userList.count > 0){
			
			if (tableView == self.searchDisplayController.searchResultsTableView) {
				
				NSDictionary *userInfo = [self.userList objectAtIndex:row];

                NSInteger friendUid = [[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"uid"]] intValue];
				NSString *name = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]];
				NSString *userid = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"id"]];
				cell.titleLabel.text = name;
                cell.infoLabel.text = userid;
                cell.button1.tag = friendUid;
				[cell.button1 addTarget:self action:@selector(friendAdd:) forControlEvents:UIControlEventTouchUpInside];
			} else {
				
			}
			
			
		}
	}
	
	return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		//NSDictionary *user = [userList objectAtIndex:[indexPath row]];
		/*
		MessageReadController *messageReadController = [[MessageReadController alloc]
														initWithNibName:@"MessageReadController"
														bundle:[NSBundle mainBundle]];
        
        
        NSLog(@"receiveUserID=%@, receiveUserName=%@", [user objectForKey:@"userID"],[user objectForKey:@"userKName"]);
        messageReadController.sendUserID = [user objectForKey:@"userID"];
		messageReadController.receiveUserID = [[AppDelegate sharedAppDelegate] authUserID];
		messageReadController.receiveUserName = [user objectForKey:@"userKName"];
		
		[self.navigationController pushViewController:messageReadController animated:YES];
		[user release];
		[messageReadController release];
		*/
    } else {
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark -
#pragma mark SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searching = YES;
	isSelectRow = NO;
	self.table.scrollEnabled = NO;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	[copiedUserList removeAllObjects];
	
	if ([searchText length] > 0) {
		searching = YES;
		isSelectRow = YES;
		self.table.scrollEnabled = YES;
		[self searchUser];
	} else {
		searching = NO;
		isSelectRow = NO;
		self.table.scrollEnabled = NO;
	}
	
	//[self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	NSLog(@"searchBarSearchButtonClicked");
	[self searchUser];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	//searchDisplayController.searchBar.hidden = YES;
	[searchDisplayController setActive:NO animated:YES];
}

#pragma mark -
#pragma mark SearchDisplayDelegate
//검색창이 닫아지는 때에 호출
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
	[self searchBarCancelButtonClicked:controller.searchBar];
}
//검색창에 키워드 등록시 호출
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
	return YES;
}


@end
