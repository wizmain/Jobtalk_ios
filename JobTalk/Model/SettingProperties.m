//
//  SettingProperties.m
//  SmartLMS
//
//  Created by 김규완 on 11. 2. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingProperties.h"


@implementation SettingProperties

@synthesize userName, schoolName, hakbun, majorName;


#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aEncoder{
	[aEncoder encodeObject:userName forKey:kUserNameKey];
	[aEncoder encodeObject:schoolName forKey:kSchoolNameKey];
    [aEncoder encodeObject:hakbun forKey:kHakBunKey];
    [aEncoder encodeObject:majorName forKey:kMajorNameKey];
	
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if(self = [super init]) {
		self.userName = [aDecoder decodeObjectForKey:kUserNameKey];
		self.schoolName = [aDecoder decodeObjectForKey:kSchoolNameKey];
        self.hakbun = [aDecoder decodeObjectForKey:kHakBunKey];
        self.majorName = [aDecoder decodeObjectForKey:kMajorNameKey];

	}
	return self;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	SettingProperties *copy = [[[self class] allocWithZone:zone] init];
	copy.userName = [[self.userName copyWithZone:zone] autorelease];
	copy.schoolName = [[self.schoolName copyWithZone:zone] autorelease];
    copy.hakbun = [[self.hakbun copyWithZone:zone] autorelease];
    copy.majorName = [[self.majorName copyWithZone:zone] autorelease];

	return copy;
}

@end
