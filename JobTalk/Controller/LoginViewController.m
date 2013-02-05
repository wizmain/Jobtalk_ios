//
//  LoginViewController.m
//  interview
//
//  Created by 김규완 on 12. 7. 31..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import "LoginViewController.h"
#import "HTTPRequest.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Constant.h"
#import "AlertUtils.h"
#import "LoginProperties.h"
#import "NSString+Helpers.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtUserID;
@synthesize txtPassword;
@synthesize swSaveID;
@synthesize swAutoLogin;
@synthesize loginButton;
@synthesize loginProperties;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    loginProperties = [Utils loginProperties];
    
    if (loginProperties != nil) {
		NSLog(@"not nil");
		if ([loginProperties userID] != nil) {
			NSLog(@"%@",[loginProperties userID]);
			[txtUserID setText:[loginProperties userID]];
		}
		if ([loginProperties password] != nil) {
			[txtPassword setText:[loginProperties password]];
		}
		if ([loginProperties autoLogin]  != nil) {
			if ([[loginProperties autoLogin] isEqualToString:@"YES"]) {
				[swAutoLogin setOn:YES];
			} else {
				[swAutoLogin setOn:NO];
			}
		}
		if ([loginProperties saveUserID] != nil) {
			if ([[loginProperties saveUserID] isEqualToString:@"YES"]) {
				[swSaveID setOn:YES];
			} else {
				[swSaveID setOn:NO];
			}
		}
		
	} else {
		NSLog(@"nil");
		loginProperties = [[LoginProperties alloc] init];
	}
	
	[self.txtUserID setReturnKeyType:UIReturnKeyDone];
	[self.txtUserID setDelegate:self];//<UITextFieldDelegate> 구현객체에서 사용
	[self.txtPassword setReturnKeyType:UIReturnKeyDone];
	[self.txtPassword setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.txtUserID = nil;
	self.txtPassword = nil;
	self.swSaveID = nil;
	self.swAutoLogin = nil;
	self.loginProperties = nil;
	spinner = nil;
}

- (void)dealloc {
	[txtUserID release];
	[txtPassword release];
	[swSaveID release];
	[swAutoLogin release];
	[loginProperties release];
	[spinner release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark 메소드 구현

- (IBAction)loginButtonPressed:(id)sender {
	[txtUserID resignFirstResponder];
    [txtPassword resignFirstResponder];
	[self loginProcess];
}

//로그인 처리
- (void)loginProcess {
	/*request생성*/
	//접속할 주소 설정
	//NSString *url = [[[mClassAppDelegate sharedAppDelegate] serverUrl] stringByAppendingString:[[mClassAppDelegate sharedAppDelegate] loginUrl]];
	//NSString serverUrl = [[NSString alloc] initWithString:kServerUrl];
	//loginUrl = [[NSString alloc] initWithString:kLoginUrl];
	NSString *url = [kServerUrl stringByAppendingString:kLoginUrl];
    NSLog(@"url = %@", url);
	
	HTTPRequest *httpRequest = [[AppDelegate sharedAppDelegate] httpRequest];
	NSString *userID = self.txtUserID.text;
	NSString *password = self.txtPassword.text;
	
	//로그인 인디케이터 시작
	spinner = [[ProgressIndicator alloc] initWithLabel:@"로그인중..."];
	[spinner show];
	
	//POST로 전송할 데이터 설정
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceUuid = [[AppDelegate sharedAppDelegate] deviceUuid];
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userid", password,@"passwd", @"iOS", @"mobile_os", systemVersion, @"mobile_version", deviceUuid, @"device_id", [[AppDelegate sharedAppDelegate] deviceToken], @"device_token", nil];
    NSLog(@"bodyObject=%@",bodyObject);
	//NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"userid", password, @"passwd", nil];
	
    
	//통신완료 후 호출할 델리게이트 셀렉터 설정
	[httpRequest setDelegate:self selector:@selector(didReceiveFinished:)];
	
	//페이지 호출
	[httpRequest requestUrl:url bodyObject:bodyObject httpMethod:@"POST" withTag:nil];
    
    
    /* sync방식
     NSError *error = nil;
     NSHTTPURLResponse *response = nil;
     NSData *responseData = [httpRequest requestUrlSync:url bodyObject:bodyObject httpMethod:@"POST" error:error response:response];
     NSString *resultData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
     [self didReceiveFinished:resultData];
     */
    
	
	[spinner dismissWithClickedButtonIndex:0 animated:YES];
	
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:txtUserID]) {
		[txtPassword becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
		[self loginProcess];
	}
	return YES;
}

#pragma mark -
#pragma mark Connection Result Delegate
- (void)didReceiveFinished:(NSString *)result {
	NSLog(@"receiveData : %@", result);
	
	// JSON형식 문자열로 Dictionary생성
	SBJsonParser *jsonParser = [SBJsonParser new];
	//NSError *error = [[NSError alloc] init];
	NSDictionary *jsonData = [jsonParser objectWithString:result];
	NSDictionary *userSession = (NSDictionary *)[jsonData objectForKey:@"userSession"];
	//NSLog(@"error = %@", error);
     NSString *key;
     for (key in jsonData){
     NSLog(@"Key: %@, Value: %@", key, [jsonData valueForKey:key]);
     }
     for (key in userSession){
     NSLog(@"Key: %@, Value: %@", key, [userSession valueForKey:key]);
     }
    
	//[error release];
	[jsonParser release];
	
	
	NSString *message = (NSString *)[userSession objectForKey:@"message"];
	NSString *resultStr = (NSString *)[userSession objectForKey:@"result"];
    int userNo = [[NSString stringWithFormat:@"%@",[userSession objectForKey:@"userNo"]] intValue];
	//NSLog(@"message = %@", message);
	NSLog(@"result = %@", resultStr);
	
	//로그인 성공이면
	if ([resultStr isEqualToString:@"success"]) {
        
		//이제 로그인 완료 후 설정데이타 저장
		LoginProperties *loginProp = [[LoginProperties alloc] init];
		
		[loginProp setUserID:txtUserID.text];
		[loginProp setPassword:txtPassword.text];
		
		if (swAutoLogin.on) {
			[loginProp setAutoLogin:@"YES"];
		} else {
			[loginProp setAutoLogin:@"NO"];
		}
		
		if (swSaveID.on) {
			[loginProp setSaveUserID:@"YES"];
		} else {
			[loginProp setSaveUserID:@"NO"];
		}
		//로그인 설정 저장
		[Utils saveLoginProperties:loginProp];
        
        [[AppDelegate sharedAppDelegate] setIsAuthenticated:YES];
        [[AppDelegate sharedAppDelegate] setAuthGroup:[jsonData valueForKey:@"userKind"]];
        [[AppDelegate sharedAppDelegate] setAuthUserID:txtUserID.text];
        [[AppDelegate sharedAppDelegate] setAuthUserNo:userNo];
        
        /*
        NSString *utf8String = (NSString*)[userSession objectForKey:@"userKName"];
        NSLog(@"utf8String=%@",utf8String);
        NSString *correctString = [NSString stringWithCString:[utf8String cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
        NSLog(@"userName = %@",correctString);
        */
        
        //NSString *userName = [Utils cookieValue:@"userName"];
        NSString *userName = @"%EB%B0%95%EC%B4%88%ED%9D%AC";
        NSLog(@"userName=%@", userName);
        NSLog(@"userName=%@", [userName stringByUrlDecoding]);
		//페이지 전환
		[[AppDelegate sharedAppDelegate] switchMainView];
        
        
        
	} else {
		
		AlertWithMessage(message);
	}
    
	
	//spinner stop 없애기
	[spinner dismissWithClickedButtonIndex:0 animated:YES];
	
	//[self dismissModalViewControllerAnimated:YES];
	//NSLog(@"dismissModalViewController");
}

@end
