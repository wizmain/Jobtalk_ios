//
//  LoginProperties.m
//  mClass
//
//  Created by 김규완 on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginProperties.h"


@implementation LoginProperties

@synthesize userID;
@synthesize autoLogin;
@synthesize saveUserID;
@synthesize password;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aEncoder{
	[aEncoder encodeObject:userID forKey:kUserIDKey];
	[aEncoder encodeObject:autoLogin forKey:kAutoLoginKey];
	[aEncoder encodeObject:saveUserID forKey:kSaveUserIDKey];
	[aEncoder encodeObject:password forKey:kPasswordKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if(self = [super init]) {
		self.userID = [aDecoder decodeObjectForKey:kUserIDKey];
		self.password = [aDecoder decodeObjectForKey:kPasswordKey];
		self.autoLogin = [aDecoder decodeObjectForKey:kAutoLoginKey];
		self.saveUserID = [aDecoder decodeObjectForKey:kSaveUserIDKey];
	}
	return self;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	LoginProperties *copy = [[[self class] allocWithZone:zone] init];
	copy.userID = [[self.userID copyWithZone:zone] autorelease];
	copy.saveUserID = [self.saveUserID copyWithZone:zone];
	copy.autoLogin = [self.autoLogin copyWithZone:zone];
	copy.password = [self.password copyWithZone:zone];
	return copy;
}

@end
