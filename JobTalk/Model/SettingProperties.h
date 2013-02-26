//
//  SettingProperties.h
//  SmartLMS
//
//  Created by 김규완 on 11. 2. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUserNameKey	@"userName"
#define kSchoolNameKey	@"schoolName"
#define kMajorNameKey	@"majorName"
#define kHakBunKey      @"hakbun"

@interface SettingProperties : NSObject<NSCoding, NSCopying> {

}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *schoolName;
@property (nonatomic, retain) NSString *majorName;
@property (nonatomic, retain) NSString *hakbun;

@end
