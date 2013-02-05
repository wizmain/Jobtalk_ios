//
//  LoginProperties.h
//  mClass
//
//  Created by 김규완 on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUserIDKey		@"userID"
#define kAutoLoginKey	@"autoLogin"
#define kSaveUserIDKey	@"saveUserID"
#define kPasswordKey	@"password"

@interface LoginProperties : NSObject<NSCoding, NSCopying> {
	//NSString *autoLogin;
	//NSString *saveUserID;
	//NSString *userID;
	//NSString *password;
}

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *autoLogin;
@property (nonatomic, retain) NSString *saveUserID;
@property (nonatomic, retain) NSString *password;

@end
