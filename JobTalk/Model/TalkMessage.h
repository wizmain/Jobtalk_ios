//
//  TalkMessage.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 10..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TalkRoom;

@interface TalkMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * read_count;
@property (nonatomic, retain) NSNumber * read_yn;
@property (nonatomic, retain) NSNumber * receive_user_no;
@property (nonatomic, retain) NSNumber * talk_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSNumber * user_no;
@property (nonatomic, retain) NSNumber * master_uid;
@property (nonatomic, retain) NSDate * write_date;
@property (nonatomic, retain) NSSet *talkMessage;
@end

@interface TalkMessage (CoreDataGeneratedAccessors)

- (void)addTalkMessageObject:(TalkRoom *)value;
- (void)removeTalkMessageObject:(TalkRoom *)value;
- (void)addTalkMessage:(NSSet *)values;
- (void)removeTalkMessage:(NSSet *)values;

@end
