//
//  TalkListViewController.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 8..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkListViewController.h"
#import "AppDelegate.h"
#import "AlertUtils.h"
#import "Constant.h"
#import "JSON.h"
#import "TalkRoom.h"
#import "TalkViewController.h"
#import "TalkRoomCell.h"

#define kCacheName  @"cache"
#define kTalkRoomCellHeight 80
#define kNotiName   @"receivePush"
#define kCellShiftWidth     32

@interface TalkListViewController ()

@property (nonatomic, retain) NSMutableArray *talkList;
@property (nonatomic, retain) IBOutlet UITableView *talkTable;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) TalkDataManager *talkDataManager;
@property (nonatomic, retain) TalkViewController *talkViewController;
@property (nonatomic, assign) BOOL isEditMode;

@end

@implementation TalkListViewController

@synthesize talkList;
@synthesize talkTable;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize talkDataManager;

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
    self.isEditMode = NO;
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[addButton setTitle:@"추가" forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"105-AddUserBlack"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
    addButton.frame = CGRectMake(0, 0, 50, 30);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    [addButton release];
    
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"편집"
    //                                              style:UIBarButtonItemStyleBordered
    //                                             target:self
    //                                             action:@selector(editTalkRoom:)];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //[backButton release];

    //로컬데이타 가져온다.
    self.managedObjectContext = [[AppDelegate sharedAppDelegate] managedObjectContext];
    //fetch
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
     
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    //서버에 방 데이타를 가져온다.
    self.talkDataManager = [TalkDataManager sharedManager];
    
    
    
    
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
	self.talkList = nil;
    self.talkTable = nil;
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    self.talkDataManager = nil;
    [[[AppDelegate sharedAppDelegate] httpRequest] cancel];
    
}

- (void)dealloc {
	[talkList release];
    [talkTable release];
    [_fetchedResultsController release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName object:nil];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePush:) name:kNotiName object:nil];
    [self.talkDataManager setDelegate:self];//싱글톤이라 델리게이트 사용 신중히 항상 새로 셋팅해야함 다른데서 델리게이트 설정했을지 모르니
    [self.talkDataManager requestServerTalkRoomList];
    

}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiName object:nil];
    
}


#pragma mark -
#pragma mark Custom Method

- (void)reloadFetchController {
    NSLog(@"reloadFetchController");
    
    //_fetchedResultsController = nil;
    
    //[NSFetchedResultsController deleteCacheWithName:kCacheName];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.talkTable reloadData];
}

- (void)receivePush:(NSNotification*)notif {
    NSLog(@"receivePush");
    NSDictionary *userInfo = [notif userInfo];
    int masterUid = [[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"master_uid"]] integerValue];
    [self.talkDataManager requestServerChatData:[NSNumber numberWithInt:masterUid]];
    
}

- (void)editTalkRoom:(id)sender {
    self.talkTable.editing = YES;
}

- (void)deleteAll:(id)sender {
    
    NSLog(@"deletaAll");
    
    TalkRoom *insertTalkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    insertTalkRoom.name = @"test";
    insertTalkRoom.master_uid = [NSNumber numberWithInt:999];
    insertTalkRoom.user_no = [NSNumber numberWithInt:999];
    insertTalkRoom.last_message = @"test";
    insertTalkRoom.last_message_date = [NSDate new];
    insertTalkRoom.last_message_user = [NSString stringWithFormat:@"홍길동"];
    
    NSError *error = nil;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        [self.talkTable reloadData];
    } else {
        
    }
    
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entiryDescription = [NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entiryDescription];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"items count=%d", items.count);
    [fetchRequest release];
    
    for(NSManagedObject *item in items) {
        //TalkRoom *talkRoom = (TalkRoom*)item;
        NSLog(@"master_uid=%@", item);
        [self.managedObjectContext deleteObject:item];
    }
    
    [self reloadFetchController];
    */
    
}


#pragma mark -
#pragma mark TalkDataManager Delegate
- (void)bindTalkRoom:(NSMutableArray*)talkRoomData {
    self.talkList = talkRoomData;
    [self reloadFetchController];
}

- (void)bindTalkData:(NSMutableArray *)talkData {
    NSLog(@"bindTalkData");
    if(talkData){
        for (NSDictionary *item in talkData) {
            
        }
    }
    
    [self reloadFetchController];
}

#pragma mark -
#pragma mark Connection Result Delegate


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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"last_message_date" ascending:NO];
    //NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:dateDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"master_uid" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    // Memory management.
    
    [fetchRequest release];
    [dateDescriptor release];
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
    
    //[self.talkTable reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;
}

#pragma mark -
#pragma mark Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: Double-check for performance drain later
	
    static NSString *normalCellIdentifier = @"방목록";
    TalkRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];

	if (cell == nil) {
        cell = [TalkRoomCell cellWithNib];
	}
	
	//NSUInteger row = [indexPath row];

    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell to show the book's title
    TalkRoom *talkRoom = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //NSLog(@"configureCell %@", talkRoom);
    //cell.textLabel.text = talkRoom.name;
    int unreadCount = [self.talkDataManager unreadMessageCnt:talkRoom.master_uid];
    
    TalkRoomCell *talkRoomCell = (TalkRoomCell *)cell;
    talkRoomCell.titleLabel.text = talkRoom.name;
    if(talkRoom.last_message_date){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *messageDate = [formatter stringFromDate:talkRoom.last_message_date];
        talkRoomCell.lastMessageDateLabel.text = messageDate;
        [formatter release];
    }
    NSLog(@"unreadCount=%d", unreadCount);
    if (unreadCount > 0) {
        [talkRoomCell.unreadMessageCntButton setTitle:[NSString stringWithFormat:@"%d", unreadCount] forState:UIControlStateNormal];
        [talkRoomCell.unreadMessageCntButton setHidden:NO];
    } else {
        [talkRoomCell.unreadMessageCntButton setHidden:YES];
    }
    talkRoomCell.lastMessageLabel.text = talkRoom.last_message;
    
    /*
    if (self.talkTable.editing) {
        [UIView beginAnimations:@"cell shift" context:nil];
        
        CGRect titleLabelRect = talkRoomCell.titleLabel.frame;
        titleLabelRect.size.width = titleLabelRect.size.width - kCellShiftWidth;
        talkRoomCell.titleLabel.frame = titleLabelRect;
        
        CGRect lastMessageRect = talkRoomCell.lastMessageLabel.frame;
        lastMessageRect.size.width = lastMessageRect.size.width - kCellShiftWidth;
        talkRoomCell.lastMessageLabel.frame = lastMessageRect;
        
        CGRect lastDateRect = talkRoomCell.lastMessageDateLabel.frame;
        NSLog(@"rect x = %f", lastDateRect.origin.x);
        lastDateRect.origin.x = lastDateRect.origin.x - kCellShiftWidth;
        NSLog(@"rect x = %f", lastDateRect.origin.x);
        talkRoomCell.lastMessageDateLabel.frame = lastDateRect;
        
        [UIView commitAnimations];
    }
    */

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    

    
    
    NSLog(@"setEditing");
    //[self.talkTable reloadData];
    if(editing == YES){
        
        
        
        
        for (UITableViewCell *cell in [self.talkTable visibleCells]) {
            //NSIndexPath *path = [self.talkTable indexPathForCell:cell];
            //cell.selectionStyle = (self.editing && (path.row > 1 || path.section == 0)) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
            
            [UIView beginAnimations:@"cell shift" context:nil];
            TalkRoomCell *talkRoomCell = (TalkRoomCell *)cell;
            CGRect titleLabelRect = talkRoomCell.titleLabel.frame;
            titleLabelRect.size.width = titleLabelRect.size.width - kCellShiftWidth;
            talkRoomCell.titleLabel.frame = titleLabelRect;
            
            CGRect lastMessageRect = talkRoomCell.lastMessageLabel.frame;
            lastMessageRect.size.width = lastMessageRect.size.width - kCellShiftWidth;
            talkRoomCell.lastMessageLabel.frame = lastMessageRect;
            
            CGRect lastDateRect = talkRoomCell.lastMessageDateLabel.frame;
            lastDateRect.origin.x = lastDateRect.origin.x - kCellShiftWidth;
            talkRoomCell.lastMessageDateLabel.frame = lastDateRect;
            
            [UIView commitAnimations];
            

        }
    
    } else {
        for (UITableViewCell *cell in [self.talkTable visibleCells]) {
            //NSIndexPath *path = [self.talkTable indexPathForCell:cell];
            //cell.selectionStyle = (self.editing && (path.row > 1 || path.section == 0)) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
            
            [UIView beginAnimations:@"cell shift" context:nil];
            TalkRoomCell *talkRoomCell = (TalkRoomCell *)cell;
            CGRect titleLabelRect = talkRoomCell.titleLabel.frame;
            titleLabelRect.size.width = titleLabelRect.size.width + kCellShiftWidth;
            talkRoomCell.titleLabel.frame = titleLabelRect;
            
            //CGRect thumbImageRect = talkRoomCell.thumbnailImageView.frame;
            //thumbImageRect.origin.x = thumbImageRect.origin.x + 20;
            //talkRoomCell.thumbnailImageView.frame = thumbImageRect;
            //CGRect unreadMessageRect = talkRoomCell.unreadMessageCntButton.frame;
            //unreadMessageRect.origin.x = unreadMessageRect.origin.x + 20;
            //talkRoomCell.unreadMessageCntButton.frame = unreadMessageRect;
            CGRect lastMessageRect = talkRoomCell.lastMessageLabel.frame;
            lastMessageRect.size.width = lastMessageRect.size.width + kCellShiftWidth;
            talkRoomCell.lastMessageLabel.frame = lastMessageRect;
            
            CGRect lastDateRect = talkRoomCell.lastMessageDateLabel.frame;
            lastDateRect.origin.x = lastDateRect.origin.x + kCellShiftWidth;
            talkRoomCell.lastMessageDateLabel.frame = lastDateRect;
            
            [UIView commitAnimations];
        }
    }
    [super setEditing:editing animated:animated];
    [self.talkTable setEditing:editing animated:YES];

}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSLog(@"TalkListController didSelectedRow");
	//NSUInteger row = [indexPath row];
    
    TalkRoom *talkRoom = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    TalkViewController *talkViewController = [[TalkViewController alloc] initWithNibName:@"TalkViewController" bundle:nil];
    //talkController.chatUsers = chatUsers;
    talkViewController.talkUid = [talkRoom.master_uid integerValue];
    [self.navigationController pushViewController:talkViewController animated:YES];
    [talkViewController release];
    //UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:self.talkViewController];
    //[[[AppDelegate sharedAppDelegate] mainViewController] addChildViewController:talkViewController];
    //[self presentModalViewController:naviCon animated:YES];
	//[naviCon release];
    
    //[[[AppDelegate sharedAppDelegate] mainViewController] switchTalkView:[talkRoom.master_uid integerValue]];
	
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTalkRoomCellHeight;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // remove the row here.
        NSLog(@"Delete Click");
        
        self.talkDataManager 
        
        self.talkTable.editing = NO;
        
    }
}

@end
