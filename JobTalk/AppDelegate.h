//
//  AppDelegate.h
//  JobTalk
//
//  Created by 김규완 on 13. 1. 7..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"
#import "MainViewController.h"
#import "LoginViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, getter = isAlertRunning) BOOL alertRunning;
@property (nonatomic, retain, readonly) HTTPRequest *httpRequest;
@property (nonatomic, retain, readonly) NSString *version;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, assign) BOOL isAuthenticated;
@property (nonatomic, retain) NSString *authUserID;
@property (nonatomic, assign) int authUserNo;
@property (nonatomic, retain) NSString *authGroup;
@property (nonatomic, retain) NSString *deviceToken;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


+ (AppDelegate *)sharedAppDelegate;
- (void)switchMainView;
- (void)switchLoginView;
- (BOOL)isCellNetwork;
- (BOOL)isNetworkReachable;
- (void)initMainView;
- (NSString *)deviceUuid;

@end
