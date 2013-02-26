//
//  AppDelegate.m
//  JobTalk
//
//  Created by 김규완 on 13. 1. 7..
//  Copyright (c) 2013년 coelsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "Constant.h"
#import "HTTPRequest.h"
#import "LoginProperties.h"
#import "JSON.h"
#import "AlertUtils.h"
#import "TalkDataManager.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    [version release];
    [httpRequest release];
    [mainViewController release];
    [deviceToken release];
    [httpRequest release];
    [authUserID release];
    [talkDataManager release];
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize loginViewController;
@synthesize httpRequest;
@synthesize authUserID, authGroup, authUserNo;
@synthesize alertRunning, isAuthenticated;
@synthesize mainViewController;
@synthesize version;
@synthesize deviceToken;
@synthesize talkDataManager;

SystemSoundID receiveSound4;

+ (AppDelegate *)sharedAppDelegate {
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog( @"launchOptions Desc: %@", [launchOptions description] );
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Add registration for remote notifications
	[[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
	// Clear application badge when app launches
	//application.applicationIconBadgeNumber = 0;
    TalkDataManager *talkManager = [[TalkDataManager alloc] init];
    NSInteger unreadCnt = [talkManager unreadMessageCnt];
    application.applicationIconBadgeNumber = unreadCnt;
    self.talkDataManager = talkManager;
    [talkManager release];
    
    // 알림을 통한 진입인지 확인
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(localNotif){
        // 알림으로 인해 앱이 실행된 경우라면..
        // localNotif.userInfo 등을 이용하여
        // 알림과 관계된 화면을 보여주는 등의 코드를 진행할 수 있음.
    }

    
    version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    httpRequest = [[HTTPRequest alloc] init];
    
    if([Utils isNullString:version]){
        version = @"0.0.0";
    }
	
	if (self.mainViewController.view.superview == nil) {
		if (self.mainViewController == nil) {
			MainViewController *mainView = [[MainViewController alloc]
											initWithNibName:@"MainViewController"
											bundle:nil];
			self.mainViewController = mainView;
			//CGRect newFrame = self.window.frame;
			//self.mainViewController.view.frame = CGRectMake(0, 20, 320, 460);
			[mainView release];
		}
	}
    
    if (self.loginViewController == nil) {
		LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		self.loginViewController = login;
		[login release];
        
		//self.loginViewController.view.frame = CGRectMake(0, 20, 320, 460);
        //CGRect rect = [[UIScreen mainScreen] bounds];
        
        //self.loginViewController.view.frame = CGRectMake(rect.origin.x, rect.origin.y+20, rect.size.width, rect.size.height);
	}
    
	[self.window addSubview:self.loginViewController.view];
    
    [self loginProcess];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)initMainView {
    self.mainViewController = nil;
    MainViewController *main = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.mainViewController = main;
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.mainViewController.view.frame = CGRectMake(rect.origin.x, rect.origin.y+20, rect.size.width, rect.size.height);
    [main release];
}

- (void)switchMainView {
    NSLog(@"switchMainView");
	if (self.mainViewController == nil) {
		MainViewController *main = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        
		self.mainViewController = main;
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.mainViewController.view.frame = CGRectMake(rect.origin.x, rect.origin.y+20, rect.size.width, rect.size.height);
        
        
		[main release];
        
	}
    
    [self.window addSubview:self.mainViewController.view];
    //[self.window bringSubviewToFront:self.mainViewController.view];
	
}

- (void)switchLoginView {
    
	if (self.loginViewController == nil) {
		LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		self.loginViewController = login;
		[login release];
        
		//self.loginViewController.view.frame = CGRectMake(0, 20, 320, 460);
        CGRect rect = [[UIScreen mainScreen] bounds];
        
        self.loginViewController.view.frame = CGRectMake(rect.origin.x, rect.origin.y+20, rect.size.width, rect.size.height);
	}
	[self.window addSubview:self.loginViewController.view];
}

-(BOOL) isNetworkReachable
{
	struct sockaddr_in zeroAddr;
    bzero(&zeroAddr, sizeof(zeroAddr));
    zeroAddr.sin_len = sizeof(zeroAddr);
    zeroAddr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
    SCNetworkReachabilityFlags flag;
    SCNetworkReachabilityGetFlags(target, &flag);
	
    if(flag & kSCNetworkFlagsReachable){
        return YES;
    }else {
        return NO;
    }
}

-(BOOL)isCellNetwork{
    struct sockaddr_in zeroAddr;
    bzero(&zeroAddr, sizeof(zeroAddr));
    zeroAddr.sin_len = sizeof(zeroAddr);
    zeroAddr.sin_family = AF_INET;
	
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
	
    SCNetworkReachabilityFlags flag;
    SCNetworkReachabilityGetFlags(target, &flag);
	
    if(flag & kSCNetworkReachabilityFlagsIsWWAN){
        return YES;
    }else {
        return NO;
    }
}

- (NSString *)deviceUuid {
    UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid;
	if ([dev respondsToSelector:@selector(uniqueIdentifier)])
		deviceUuid = dev.uniqueIdentifier;
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		id uuid = [defaults objectForKey:@"deviceUuid"];
		if (uuid)
			deviceUuid = (NSString *)uuid;
		else {
			CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
			deviceUuid = (NSString *)cfUuid;
			CFRelease(cfUuid);
			[defaults setObject:deviceUuid forKey:@"deviceUuid"];
		}
	}
    
    return deviceUuid;
}

- (void)loginProcess {
    // 로그인 설정정보 확인
	LoginProperties *loginProperties = [Utils loginProperties];
	
	if (loginProperties == nil) {
		NSLog(@"loginProperties nil");
		//[self switchLoginView];
		
	} else {
		
		//자동 로그인 셋팅이면
        NSLog(@"autologin %@", [loginProperties autoLogin]);
		if ([[loginProperties autoLogin] isEqualToString:@"YES"]) {
			NSLog(@"loginProperties autologin YES");
			//로그인 주소 설정
			//NSString *url = [serverUrl stringByAppendingString:loginUrl];
			NSString *url = [kServerUrl stringByAppendingString:kLoginUrl];
			NSLog(@"%@",url);
			
			//POST로 전송할 데이터 설정
            if([Utils isNullString:self.deviceToken]){
                self.deviceToken = @"";
            }
            NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
            NSString *deviceUuid = [self deviceUuid];
			NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:[loginProperties userID],@"userid", [loginProperties password],@"passwd", @"iOS", @"mobile_os", systemVersion, @"mobile_version", deviceUuid, @"device_id", self.deviceToken, @"device_token", nil];
            NSLog(@"bodyObject=%@",bodyObject);
			/*
             //통신완료 후 호출할 델리게이트 셀렉터 설정
             [httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
             
             //페이지 호출
             [httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" connectionDelegate:self];
             */
            
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            NSData *responseData = [httpRequest requestUrlSync:url bodyObject:bodyObject httpMethod:@"POST" error:error response:response];
            NSString *resultData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            [self didReceiveFinished:resultData];
			
            
		} else {
			NSLog(@"LoginProperties autologin NO");
			//[self switchLoginView];
		}
	}
}

- (void)didReceiveFinished:(NSString *)result {
	NSLog(@"receiveData : %@", result);

	// JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSDictionary *results = [jsonParser objectWithString:result];
	[jsonParser release];
    
    NSDictionary *userSession = [results objectForKey:@"userSession"];
	
	//[self switchTabView];
	NSString *resultStr = (NSString *)[userSession valueForKey:@"result"];
    NSLog(@"resultStr = %@", resultStr);
	if ( [resultStr isEqualToString:@"success"]) {
        
		self.isAuthenticated = YES;
        self.authGroup = [userSession valueForKey:@"userRole"];
        
        [self switchMainView];
	} else {
        //[self switchLoginView];
    }
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//에러가 발생하였을 경우 호출되는 메소드
	NSLog(@"AppDelegate Error: %@", [error localizedDescription]);
	AlertWithError(error);
    [self switchLoginView];
}


#pragma mark - APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
#if !TARGET_IPHONE_SIMULATOR
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
    
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [self deviceUuid];
	
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
    
	// Prepare the Device Token for Registration (remove spaces and < >)
	self.deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"deviceToken=%@", self.deviceToken);
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"www.smartinterview.co.kr";
    
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
	// !!! ( MUST START WITH / AND END WITH ? ).
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/reg_apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, self.deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
    
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
	NSLog(@"Return Data: %@", returnData);
    
    
	
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"Error in registration. Error: %@", error);
	
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
    
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	//application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    //NSLog(@"apsInfo = %@",apsInfo);
    
    //application.applicationIconBadgeNumber = [self.talkDataManager unreadMessageCnt];
    //NSLog(@"badgeNumber = %d", application.applicationIconBadgeNumber);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePush" object:nil userInfo:userInfo];
    
    
    UIApplicationState state = [application applicationState];
    //postNoti
    
    if (state == UIApplicationStateActive) {
        
        /*
        NSString *cancelTitle = @"닫기";
        NSString *showTitle = @"보기";
        
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알리미"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles:showTitle, nil];
        [alertView show];
        [alertView release];
        */
        //TalkDataManager *talkDataManager = [TalkDataManager sharedManager];
        
        
        
    } else {
        //Do stuff that you would do if the application was not active
        //NSLog(@"apsInfo = %@",apsInfo);
    }
	
#endif
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JobTalk" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"JobTalk.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
