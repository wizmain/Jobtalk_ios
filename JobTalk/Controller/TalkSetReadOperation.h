//
//  TalkSetReadOperation.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 25..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TalkDataManager.h"

@interface TalkSetReadOperation : NSOperation {
    NSNumber * _talkID;
    TalkDataManager * _talkDataManager;
}

- (id)initWithTalkID:(NSNumber *)talkID;

@end
