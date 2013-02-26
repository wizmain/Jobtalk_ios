//
//  JobTalkDataManager.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 18..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "TalkDataManager.h"
#import "HTTPRequest.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "TalkRoom.h"
#import "TalkMessage.h"
#import "JSON.h"
#import "Utils.h"

#define kTalkRoomTag        @"talkroom"
#define kTalkMessageTag     @"talkmessage"
#define kChatUserDataTag    @"chatuser"
#define kTalkDataTag        @"talkdata"
#define kSendMessageTag     @"sendmessage"

@interface TalkDataManager ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) HTTPRequest *httpRequest;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;

@end

@implementation TalkDataManager

@synthesize managedObjectContext;
@synthesize httpRequest;
@synthesize fetchRequest;
@synthesize delegate;

/*
+ (TalkDataManager *)sharedManager
{
    static TalkDataManager *sTalkDataManager;
    
    if (sTalkDataManager == nil) {
        @synchronized (self) {
            sTalkDataManager = [[TalkDataManager alloc] init];
            assert(sTalkDataManager != nil);
        }
    }
    
    return sTalkDataManager;
}
*/
- (id)init
{
    self = [super init];
    if(self != nil) {
        //initilize self
        NSLog(@"TalkDataManager init");
        self.managedObjectContext = [[AppDelegate sharedAppDelegate] managedObjectContext];
        self.httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
        self.fetchRequest= [[NSFetchRequest alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    [httpRequest release];
    [fetchRequest release];
    [super dealloc];
}


//서버에서 방 목록을 가져온다
- (void)requestServerTalkRoomList {
    
    NSString *url = [kServerUrl stringByAppendingString:kTalkRoomListUrl];
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:kTalkRoomTag];
}
//서버에 대화참여자데이타
- (void)requestChatUserList:(NSNumber *)masterUid {
    
    NSString *url = [kServerUrl stringByAppendingFormat:@"%@?uid=%d", kTalkParticipantUrl, [masterUid intValue]];
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:kChatUserDataTag];
}
//서버에 대화 데이타
- (void)requestServerChatData:(NSNumber *)masterUid {
    
    NSString *url = [kServerUrl stringByAppendingFormat:@"%@?master_uid=%d", kTalkContentUrl, [masterUid intValue]];
    NSLog(@"requestServerChatData url = %@", url);
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:kTalkDataTag];
}

//서버에 받은 대화데이타 삭제/읽음설정
- (void)setServerTalkRead:(NSNumber *)masterUid talkID:(NSNumber *)talkID senderNo:(NSNumber *)senderNo {
    NSString *url = [kServerUrl stringByAppendingFormat:@"%@?master_uid=%d&talk_id=%d&sender=%d", kTalkReadUrl, [masterUid intValue], [talkID intValue], [senderNo integerValue]];
	//[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:nil];
}
/*
- (BOOL)addTalkRoom:(TalkRoom*)talkRoom {
    //(NSString*)roomName masterUid:(NSNumber *)masterUid makeUserNo:(NSNumber *)makeUserNo lastMessage:(NSString *)lastMessage lastMessageUser:(NSString *)lastMessageUser lastMessageDate:(NSDate*)lastMessageDate
    //NSLog(@"addTalkRoom masterUid=%@", masterUid);
    
    TalkRoom *insertTalkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    insertTalkRoom.name = talkRoom.name;
    insertTalkRoom.master_uid = talkRoom.master_uid;
    insertTalkRoom.user_no = talkRoom.user_no;
    insertTalkRoom.last_message = talkRoom.last_message;
    insertTalkRoom.last_message_date = talkRoom.last_message_date;
    insertTalkRoom.last_message_user = talkRoom.last_message_user;
    
    NSError *error = nil;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        return NO;
    } else {
        return YES;
    }

}

- (BOOL)addMessage:(TalkMessage*)talkMessage {
    
    TalkMessage *insertTalkMessage = [NSEntityDescription insertNewObjectForEntityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
    insertTalkMessage.master_uid = talkMessage.master_uid;
    insertTalkMessage.talk_id = talkMessage.talk_id;
    insertTalkMessage.content = talkMessage.content;//addMessageField.text
    insertTalkMessage.write_date = [NSDate date];
    insertTalkMessage.user_name = talkMessage.user_name;//[Utils cookieValue:@"userName"];
    insertTalkMessage.user_no = talkMessage.user_no;//[NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
    insertTalkMessage.read_yn = [NSNumber numberWithBool:YES];
    //talkMessage.receive_user_no = receiveUserNo;//[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[receiver objectForKey:@"uid"]] intValue]];
    
    NSError *error = nil;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    } else {
        return YES;
    }
}
*/
- (void)requestSendMessage:(NSNumber *)masterUid chatUsers:(NSArray*)chatUsers msgContent:(NSString*)msgContent {
    NSLog(@"requestSendMessage");
    NSString *url = [kServerUrl stringByAppendingString:kTalkSendUrl];
    //NSLog(@"url = %@", url);
    
    //POST로 전송할 데이터 설정
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *userListJsonString = [jsonWriter stringWithObject:chatUsers];
    NSLog(@"userListJsonString = %@", userListJsonString);
    NSString *talkUidString = [NSString stringWithFormat:@"%d",[masterUid intValue]];
    NSLog(@"talkUidString=%@", talkUidString);
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:userListJsonString, @"userList", msgContent, @"content", talkUidString, @"uid", nil];
    
    //통신완료 후 호출할 델리게이트 셀렉터 설정
    [httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
    [httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:kSendMessageTag];
    
    [jsonWriter release];
}

- (BOOL)isExistRoom:(NSNumber *)masterUid {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"master_uid==%d",[masterUid intValue]];
    [self.fetchRequest setEntity:entity];
    [self.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    if (array != nil) {
        if(array.count > 0){
            NSLog(@"talkRoom exist");
            return YES;
        } else {
            NSLog(@"talkRoom dose not exist");
            return NO;
        }
    } else {
        NSLog(@"talkRoom does not exist.");
        return NO;
    }
    
}

- (BOOL)isExistTalk:(NSNumber *)masterUid {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"talk_id==%d",[masterUid intValue]];
    [self.fetchRequest setEntity:entity];
    [self.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:&error];
    if (array != nil) {
        if(array.count > 0) {
            NSLog(@"talk exist");
            return YES;
        } else {
            NSLog(@"talk does not exist");
            return NO;
        }
        
    } else {
        NSLog(@"talk does not exist.");
        return NO;
    }
    
}


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
        
        
        
        if([tag isEqualToString:kTalkRoomTag]) {
            
            //받아온 방 목록
            NSMutableArray *talkList = (NSMutableArray *)[resultData objectForKey:@"result"];
            
            if (talkList) {
                
                for (int i=0; i<talkList.count; i++) {
                    
                    NSDictionary *item = (NSDictionary *)[talkList objectAtIndex:i];
                    //NSLog(@"talkRoom = %@", item);
                    NSNumber *masterUid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"master_uid"]] intValue]];
                    //로컬에 등록되어 있지 않으면 로컬coredata에 추가한다.
                    if(![self isExistRoom:masterUid]){
                        NSString *sendUserName = [NSString stringWithFormat:@"%@", [item objectForKey:@"sendUserName"]];
                        NSNumber *makeUserID = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [item objectForKey:@"makeUserID"]] intValue]];
                        NSString *msgContent = [NSString stringWithFormat:@"%@", [item objectForKey:@"content"]];
                        //NSNumber *sendUserID = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [item objectForKey:@"talkUserID"]] intValue]];
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
                        NSDate *writeDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%@", [item objectForKey:@"write_date"]]];
                        [dateFormat release];
                        
                        TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                        talkRoom.name = sendUserName;
                        talkRoom.master_uid = masterUid;
                        talkRoom.user_no = makeUserID;
                        talkRoom.last_message = msgContent;
                        talkRoom.last_message_user = sendUserName;
                        talkRoom.last_message_date = writeDate;
                        
                        NSError *error = nil;
                        if(![self.managedObjectContext save:&error]){
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                            
                        } else {
                            
                        }
                        
                    }
                }
                [self.delegate bindTalkRoom:talkList];
            }
            
        } else if([tag isEqualToString:kChatUserDataTag]) {
            NSMutableArray *chatUsers = (NSMutableArray *)[resultData objectForKey:@"result"];
            [self.delegate bindChatUser:chatUsers];
            
        } else if([tag isEqualToString:kTalkDataTag]) {
            NSMutableArray *serverChatData = (NSMutableArray *)[resultData objectForKey:@"result"];
            if(serverChatData){
                
                if(serverChatData.count > 0){
                    
                    for (int i=0; i<serverChatData.count; i++) {
                        NSDictionary *talkMessage = [serverChatData objectAtIndex:i];
                        
                        //로컬에 저장되어 있지 않으면 로컬에 대화저장
                        if(![self isExistTalk:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]]]){
                            
                            NSLog(@"not exist");
                            TalkMessage *newTalkMessage = [NSEntityDescription insertNewObjectForEntityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
                            
                            newTalkMessage.master_uid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"master_uid"]] intValue]];
                            newTalkMessage.talk_id = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]];
                            newTalkMessage.content = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"content"]];
                            newTalkMessage.user_name = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"name"]];
                            newTalkMessage.user_no = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"mbrid"]] intValue]];
                            newTalkMessage.read_count = 0;
                            newTalkMessage.read_yn = [NSNumber numberWithBool:NO];
                            
                            NSError *error = nil;
                            if(![self.managedObjectContext save:&error]){
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                abort();
                                
                            } else {
                                //서버에서 읽음처리
                                //[self setServerTalkRead:newTalkMessage.master_uid talkID:newTalkMessage.talk_id senderNo:newTalkMessage.user_no];
                                
                                if ([self isExistRoom:newTalkMessage.master_uid]) {
                                    NSLog(@"talkRoom exist");
                                    //TalkRoom 최근 메시지 업데이트
                                    NSFetchRequest * request = [[NSFetchRequest alloc] init];
                                    [request setEntity:[NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext]];
                                    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[newTalkMessage.master_uid intValue]]];
                                    NSLog(@"TalkRoom Update master_uid=%d", [newTalkMessage.master_uid intValue]);
                                    NSError *error = nil;
                                    TalkRoom *updateTalkRoom = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
                                    [request release];
                                    
                                    if(updateTalkRoom){
                                        NSLog(@"TalkRoom Update Exist");
                                        updateTalkRoom.last_message = newTalkMessage.content;
                                        updateTalkRoom.last_message_date = newTalkMessage.write_date;
                                        updateTalkRoom.last_message_user = newTalkMessage.user_name;
                                        error = nil;
                                        if(![self.managedObjectContext save:&error]){
                                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                            abort();
                                        }
                                    }
                                } else {//존재하지 않으면 등록
                                    NSLog(@"talkRoom not exist");
                                    TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                                    talkRoom.name = newTalkMessage.user_name;
                                    talkRoom.master_uid = newTalkMessage.master_uid;
                                    talkRoom.user_no = newTalkMessage.user_no;
                                    talkRoom.last_message = newTalkMessage.content;
                                    talkRoom.last_message_user = newTalkMessage.user_name;
                                    talkRoom.last_message_date = newTalkMessage.write_date;
                                    
                                    NSError *error = nil;
                                    if(![self.managedObjectContext save:&error]){
                                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                        abort();
                                        
                                    } else {
                                        
                                    }
                                }
                            }
                            
                        } else {
                            NSLog(@"exist");
                        }
                    }
                }
            }
            if(self.delegate) {
                [self.delegate bindTalkData:serverChatData];
            }

        } else if([tag isEqualToString:kSendMessageTag]) {
            NSDictionary *jsonData = (NSDictionary *)[resultData objectForKey:@"result"];
            
            int masterUid = [[NSString stringWithFormat:@"%@",[jsonData objectForKey:@"master_uid"]] intValue];
            int talkId = [[NSString stringWithFormat:@"%@",[jsonData objectForKey:@"talk_id"]] intValue];
            NSArray* chatUsers = (NSArray*)[jsonData objectForKey:@"user_list"];
            NSString* message = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"message"]];
            NSLog(@"jsonData = %@", jsonData);
            NSLog(@"message = %@",[jsonData objectForKey:@"message"]);
            //NSDictionary *receiver = [chatUsers objectAtIndex:0];
            
            if(talkId > 0){
                //기존의 대화방 없으면 추가
                if(masterUid > 0){
                    NSString *talkRoomName = nil;
                    if(![self isExistRoom:[NSNumber numberWithInt:masterUid]]){
                        
                        //대화방 없으면 등록
                        if(chatUsers){
                            if (chatUsers.count > 1) {
                                talkRoomName = [NSString stringWithFormat:@"%@외 %d명", [[chatUsers objectAtIndex:0] valueForKey:@"name"], chatUsers.count-1];
                            } else if(chatUsers.count == 1){
                                talkRoomName = [NSString stringWithFormat:@"%@", [[chatUsers objectAtIndex:0] valueForKey:@"name"]];
                            }
                        } else {
                            talkRoomName = [NSString stringWithFormat:@"%@", [Utils cookieValue:@"userName"]];
                        }
                        
                        
                        TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                        talkRoom.name = talkRoomName;
                        talkRoom.master_uid = [NSNumber numberWithInt:masterUid];
                        talkRoom.user_no = [NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
                        talkRoom.last_message = message;
                        talkRoom.last_message_date = [NSDate date];
                        talkRoom.last_message_user = [Utils cookieValue:@"userName"];
                        NSError *error = nil;
                        if(![self.managedObjectContext save:&error]){
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        
                        
                    }
                } else if(masterUid == 0){ //공지사항이면
                    NSString *talkRoomName = @"공지사항";
                    if(![self isExistRoom:[NSNumber numberWithInt:masterUid]]){
                        
                        //대화방 없으면 등록
                        TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                        talkRoom.name = talkRoomName;
                        talkRoom.master_uid = [NSNumber numberWithInt:masterUid];
                        talkRoom.user_no = [NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
                        talkRoom.last_message = message;
                        talkRoom.last_message_date = [NSDate date];
                        talkRoom.last_message_user = [Utils cookieValue:@"userName"];
                        NSError *error = nil;
                        if(![self.managedObjectContext save:&error]){
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        
                        
                    }
                }
                
                TalkMessage *talkMessage = [NSEntityDescription insertNewObjectForEntityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
                talkMessage.master_uid = [NSNumber numberWithInt:masterUid];
                talkMessage.user_no = [NSNumber numberWithInt:[[AppDelegate sharedAppDelegate] authUserNo]];
                talkMessage.talk_id = [NSNumber numberWithInt:talkId];
                talkMessage.content = message;
                talkMessage.user_name = [Utils cookieValue:@"userName"];
                talkMessage.write_date = [NSDate date];
                
                NSError *error = nil;
                if(![self.managedObjectContext save:&error]){
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                } else {
                    //최근 메시지 업데이트
                    NSFetchRequest * request = [[NSFetchRequest alloc] init];
                    [request setEntity:[NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext]];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[talkMessage.master_uid intValue]]];
                    error = nil;
                    TalkRoom *updateTalkRoom = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
                    [request release];
                    
                    if(updateTalkRoom){
                        
                        updateTalkRoom.last_message = talkMessage.content;
                        updateTalkRoom.last_message_date = talkMessage.write_date;
                        updateTalkRoom.last_message_user = talkMessage.user_name;
                        error = nil;
                        if(![self.managedObjectContext save:&error]){
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                    }
                }
                if(self.delegate)
                    [self.delegate sendMessageResult:talkMessage];
            } else {
                if(self.delegate)
                    [self.delegate sendMessageResult:nil];
            }
        
        }
        
    
    
	[jsonParser release];
	
}

- (void)setTalkMessageRead:(NSNumber *)talkID {
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"talk_id=%d",[talkID intValue]]];
    NSError *error = nil;
    TalkMessage *updateTalkMessage = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
    [request release];
    
    if(updateTalkMessage){
        
        
        updateTalkMessage.read_yn = [NSNumber numberWithBool:YES];
        error = nil;
        if(![self.managedObjectContext save:&error]){
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            //서버도 읽음처리//:(NSNumber *)masterUid talkID:(NSNumber *)talkID senderNo:(NSNumber *)senderNo
            [self setServerTalkRead:updateTalkMessage.master_uid talkID:updateTalkMessage.talk_id senderNo:updateTalkMessage.user_no];
        }
    }
    
}

- (int)talkMessageCount:(NSNumber *)masterUid {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[masterUid intValue]]];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    
    [request release];
    
    return count;
}

- (int)unreadMessageCnt:(NSNumber *)masterUid {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d and read_yn = %@",[masterUid intValue], [NSNumber numberWithBool:NO]]];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        
    }
    
    [request release];
    
    return count;
}

- (int)unreadMessageCnt {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@" read_yn = %@", [NSNumber numberWithBool:NO]]];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        
    }
    
    [request release];
    
    return count;
}

- (NSArray *)unreadMessageList {
    NSLog(@"TalkDataManager unreadMessageList");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@" read_yn = %@", [NSNumber numberWithBool:NO]]];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    return items;
}

- (void)deleteTalkRoom:(NSNumber *)masterUid {
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entiryDescription = [NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entiryDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[masterUid intValue]]];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];

    [request release];
    
    for(NSManagedObject *item in items) {

        NSLog(@"delete talkRoom=%@", item);
        [self.managedObjectContext deleteObject:item];
    }
    
}

- (void)deleteTalkMessage:(NSNumber *)talkID {
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entiryDescription = [NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entiryDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"talk_id=%d",[talkID intValue]]];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    for(NSManagedObject *item in items) {
        
        NSLog(@"delete talkMessage=%@", item);
        [self.managedObjectContext deleteObject:item];
    }
}

- (void)deleteTalkMessageByMasterUid:(NSNumber *)masterUid {
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entiryDescription = [NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entiryDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[masterUid intValue]]];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    for(NSManagedObject *item in items) {
        
        //NSLog(@"delete talkMessageByMasterUid=%@", item);
        [self.managedObjectContext deleteObject:item];
    }
}

- (void)sendAnnounce:(NSString *)msgContent {
    NSLog(@"sendAnnounce");
    NSString *url = [kServerUrl stringByAppendingString:kTalkAnnounceUrl];
    //NSLog(@"url = %@", url);
    
    //POST로 전송할 데이터 설정
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *talkUidString = @"0";
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:msgContent, @"content", talkUidString, @"uid", nil];
    
    //통신완료 후 호출할 델리게이트 셀렉터 설정
    [httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
    [httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:kSendMessageTag];
    
    [jsonWriter release];
}


- (void)requestAnnounce {
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"talk_id" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=0"]];
    [request setFetchLimit:1];
    NSError *error = nil;
    TalkMessage *annMessage = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
    [request release];
    int lastAnnID = 0;
    if(annMessage){
        lastAnnID = [annMessage.talk_id intValue];
    }

    NSString *url = [kServerUrl stringByAppendingFormat:@"%@?annid=%d", kTalkAnnounceReceiveUrl, lastAnnID];
    NSLog(@"requestAnnounce url = %@", url);
	[httpRequest setDelegate:self selector:@selector(didReceiveAnnounce:)];
	[httpRequest requestUrl:url bodyObject:nil httpMethod:@"GET" withTag:nil];
}


- (void)didReceiveAnnounce:(NSString*)result {
    NSLog(@"didReceiveAnnounce : %@", result);
	
	// JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSMutableArray *serverChatData = nil;
    @try {
    
        serverChatData = (NSMutableArray *)[jsonParser objectWithString:result];
        if(serverChatData){
            
            if(serverChatData.count > 0){
                
                for (int i=0; i<serverChatData.count; i++) {
                    NSDictionary *talkMessage = [serverChatData objectAtIndex:i];
                    
                    //로컬에 저장되어 있지 않으면 로컬에 대화저장
                    if(![self isExistTalk:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]]]){
                        
                        NSLog(@"not exist");
                        TalkMessage *newTalkMessage = [NSEntityDescription insertNewObjectForEntityForName:@"TalkMessage" inManagedObjectContext:self.managedObjectContext];
                        
                        newTalkMessage.master_uid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"master_uid"]] intValue]];
                        newTalkMessage.talk_id = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"talk_id"]] intValue]];
                        newTalkMessage.content = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"content"]];
                        newTalkMessage.user_name = [NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"name"]];
                        newTalkMessage.user_no = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [talkMessage objectForKey:@"mbrid"]] intValue]];
                        newTalkMessage.read_count = 0;
                        newTalkMessage.read_yn = [NSNumber numberWithBool:NO];
                        
                        NSError *error = nil;
                        if(![self.managedObjectContext save:&error]){
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                            
                        } else {
                            //서버에서 읽음처리
                            //[self setServerTalkRead:newTalkMessage.master_uid talkID:newTalkMessage.talk_id senderNo:newTalkMessage.user_no];
                            
                            if ([self isExistRoom:newTalkMessage.master_uid]) {
                                NSLog(@"talkRoom exist");
                                //TalkRoom 최근 메시지 업데이트
                                NSFetchRequest * request = [[NSFetchRequest alloc] init];
                                [request setEntity:[NSEntityDescription entityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext]];
                                [request setPredicate:[NSPredicate predicateWithFormat:@"master_uid=%d",[newTalkMessage.master_uid intValue]]];
                                NSLog(@"TalkRoom Update master_uid=%d", [newTalkMessage.master_uid intValue]);
                                NSError *error = nil;
                                TalkRoom *updateTalkRoom = [[self.managedObjectContext executeFetchRequest:request error:&error] lastObject];
                                [request release];
                                
                                if(updateTalkRoom){
                                    NSLog(@"TalkRoom Update Exist");
                                    updateTalkRoom.last_message = newTalkMessage.content;
                                    updateTalkRoom.last_message_date = newTalkMessage.write_date;
                                    updateTalkRoom.last_message_user = newTalkMessage.user_name;
                                    error = nil;
                                    if(![self.managedObjectContext save:&error]){
                                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                        abort();
                                    }
                                }
                            } else {//존재하지 않으면 등록
                                NSLog(@"talkRoom not exist");
                                TalkRoom *talkRoom = [NSEntityDescription insertNewObjectForEntityForName:@"TalkRoom" inManagedObjectContext:self.managedObjectContext];
                                talkRoom.name = newTalkMessage.user_name;
                                talkRoom.master_uid = newTalkMessage.master_uid;
                                talkRoom.user_no = newTalkMessage.user_no;
                                talkRoom.last_message = newTalkMessage.content;
                                talkRoom.last_message_user = newTalkMessage.user_name;
                                talkRoom.last_message_date = newTalkMessage.write_date;
                                
                                NSError *error = nil;
                                if(![self.managedObjectContext save:&error]){
                                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                    abort();
                                    
                                } else {
                                    
                                }
                            }
                        }
                        
                    } else {
                        NSLog(@"exist");
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        
    }
    
    if(self.delegate) {
        [self.delegate bindTalkData:serverChatData];
    }
}
@end
