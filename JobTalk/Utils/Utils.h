//
//  Utils.h
//  mClass
//
//  Created by 김규완 on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFilename					@"data.plist"
#define kLoginPropertiesFilename	@"loginProperties.plist"
#define kLoginPropertiesKey			@"loginProperties"
#define kSettingPropertiesKey		@"settingProperties"
#define kSettingPropertiesFilename	@"settingProperties.plist"

@class LoginProperties;
@class SettingProperties;

@interface Utils : NSObject {

}

+ (NSString *)dataFilePath:(NSString *)filename;
+ (void)saveLoginProperties:(LoginProperties *)loginProperties;
+ (void)saveSettingProperties:(SettingProperties *)settingProperties;
+ (LoginProperties *)loginProperties;
+ (SettingProperties *)settingProperties;
+ (NSString *)convertDateString:(NSNumber *)dateNumber formatString:(NSString *)format;
+ (NSString *)applicationDocumentsDirectory;
+ (NSString *)cookieValue:(NSString *)cookieName;
+ (bool)isNullString:(NSString *)checkString;
+ (BOOL)isNumbericString:(NSString *)s;
+ (BOOL) isNetworkReachable;
+ (BOOL)isCellNetwork;
@end
