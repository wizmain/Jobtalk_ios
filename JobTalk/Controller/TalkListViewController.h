//
//  TalkListViewController.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 8..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkDataManager.h"

@interface TalkListViewController : UIViewController <NSFetchedResultsControllerDelegate, TalkDataManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
