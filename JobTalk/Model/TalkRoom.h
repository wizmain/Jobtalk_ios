//
//  TalkRoom.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 9..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TalkMessage;

@interface TalkRoom : NSManagedObject

@property (nonatomic, retain) NSNumber * master_uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * user_no;
@property (nonatomic, retain) NSString * last_message;
@property (nonatomic, retain) NSString * last_message_user;
@property (nonatomic, retain) NSDate * last_message_date;
@property (nonatomic, retain) TalkMessage *talkRoom;

@end
