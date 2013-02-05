//
//  JobTalkDataManager.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 18..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"
@class TalkRoom;
@class TalkMessage;

@protocol TalkDataManagerDelegate <NSObject>

@required

@optional
- (void)bindTalkRoom:(NSMutableArray*)talkRoomData;
- (void)bindChatUser:(NSMutableArray*)chatUserData;
- (void)bindTalkData:(NSMutableArray*)talkData;
- (void)sendMessageResult:(TalkMessage *)talkMessage;
@end

@interface TalkDataManager : NSObject {
    id<TalkDataManagerDelegate> delegate;
}

@property (nonatomic, assign) id delegate;

+ (TalkDataManager *)sharedManager;
- (void)requestServerTalkRoomList;
- (void)requestChatUserList:(NSNumber *)masterUid;
- (void)requestServerChatData:(NSNumber *)masterUid;
- (void)setServerTalkRead:(NSNumber *)masterUid talkID:(NSNumber *)talkID senderNo:(NSNumber *)senderNo;
//- (BOOL)addTalkRoom:(TalkRoom*)talkRoom;
//- (BOOL)addMessage:(TalkMessage*)talkMessage;
- (void)requestSendMessage:(NSNumber *)masterUid chatUsers:(NSArray*)chatUsers msgContent:(NSString*)msgContent;
- (BOOL)isExistRoom:(NSNumber *)masterUid;
- (void)setTalkMessageRead:(NSNumber *)talkID;
- (int)talkMessageCount:(NSNumber *)masterUid;
- (int)unreadMessageCnt:(NSNumber *)masterUid;
- (void)deleteTalkRoom:(NSNumber *)masterUid;
- (void)deleteTalkMessage:(NSNumber *)talkID;
- (void)deleteTalkMessageByMasterUid:(NSNumber *)masterUid;
@end
