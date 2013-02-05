//
//  Utils.m
//  mClass
//
//  Created by 김규완 on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "JSON.h"
#import "NSString+Helpers.h"
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation Utils

+ (NSString *)dataFilePath:(NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

+ (void)saveLoginProperties:(LoginProperties *)loginProperties
{
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:loginProperties forKey:kLoginPropertiesKey];
	[archiver finishEncoding];
	[data writeToFile:[self dataFilePath:kLoginPropertiesFilename] atomically:YES];
	[loginProperties release];
	[archiver release];
	[data release];
}

+ (LoginProperties *)loginProperties
{
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self dataFilePath:kLoginPropertiesFilename]];
	LoginProperties *loginProperties = nil;
	if (data == nil) {
		
	} else {
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		loginProperties = [unarchiver decodeObjectForKey:kLoginPropertiesKey];
		[unarchiver finishDecoding];
		
		[unarchiver release];
		[data release];	
	}

	return loginProperties;
}

+ (void)saveSettingProperties:(SettingProperties *)settingProperties
{
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:settingProperties forKey:kSettingPropertiesKey];
	[archiver finishEncoding];
	[data writeToFile:[self dataFilePath:kSettingPropertiesFilename] atomically:YES];
	[settingProperties release];
	[archiver release];
	[data release];
}

+ (SettingProperties *)settingProperties
{
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self dataFilePath:kSettingPropertiesFilename]];
	SettingProperties *settingProperties = nil;
	if (data == nil) {
		
	} else {
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		settingProperties = [unarchiver decodeObjectForKey:kSettingPropertiesKey];
		[unarchiver finishDecoding];
		
		[unarchiver release];
		[data release];	
	}
	
	return settingProperties;
}

+ (NSString *)convertDateString:(NSNumber *)dateNumber formatString:(NSString *)format {

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    long long time = [dateNumber longLongValue];
    time = time / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];

    return [dateFormat stringFromDate:date];
}


+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cookieValue:(NSString *)cookieName {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    if(cookieJar != nil){
        for (cookie in [cookieJar cookies]) {
            //NSLog(@"Cookie name : %@ : value : %@", cookieName, cookie.value);
            if([cookie.name isEqualToString:cookieName]){
                //if ([cookieName isEqualToString:@"userName"]) {
                    return [cookie.value stringByUrlDecoding];
                //} else {
                //    return cookie.value;
                //}
            }
        }
    }
    return nil;
}

+ (bool)isNullString:(NSString *)checkString {
    if( checkString == (id)[NSNull null] || checkString.length == 0 ){
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isNumbericString:(NSString *)s {
    
    NSUInteger len = [s length];
    NSUInteger i;
    BOOL status = NO;
    
    for(i=0; i < len; i++)
    {
        unichar singlechar = [s characterAtIndex: i];
        if ( (singlechar == ' ') && (!status) )
        {
            continue;
        }
        if ( ( singlechar == '+' ||
              singlechar == '-' ) && (!status) ) { status=YES; continue; }
        if ( ( singlechar >= '0' ) &&
            ( singlechar <= '9' ) )
        {
            status = YES;
        } else {
            return NO;
        }
    }
    return (i == len) && status;
    
}

+ (BOOL) isNetworkReachable
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

+ (BOOL)isCellNetwork{
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


@end
