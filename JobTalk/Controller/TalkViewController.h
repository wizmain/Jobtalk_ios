//
//  TalkViewController.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 10..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HPGrowingTextView.h"
#import "TalkDataManager.h"

@interface TalkViewController : UIViewController <UITextViewDelegate, HPGrowingTextViewDelegate, NSFetchedResultsControllerDelegate, TalkDataManagerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *chatUsers;
@property (nonatomic, assign) int talkUid;
@end
