//
//  TalkSetReadOperation.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 25..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkSetReadOperation.h"


@implementation TalkSetReadOperation

- (id)initWithTalkID:(NSNumber *)talkID {
    self = [super init];
    if (self != nil) {
        _talkID = [talkID retain];
        _talkDataManager = [[TalkDataManager sharedManager] retain];
    }
    return self;
}
    
- (void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(talkMessageRead:) withObject:_talkID waitUntilDone:YES];
    [pool release];
}

- (void)talkMessageRead:(NSNumber *)talkID {
    
    [_talkDataManager setTalkMessageRead:talkID];
}

- (void)dealloc {
    [_talkID release];
    [_talkDataManager release];
    [super dealloc];
}

@end
