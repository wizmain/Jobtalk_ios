//
//  NSDictionary-MutableDeepCopy.m
//  SmartLMS
//
//  Created by 김 규완 on 11. 8. 11..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary-MutableDeepCopy.h"

@implementation NSDictionary (NSDictionary_MutableDeepCopy)

- (NSMutableDictionary *)mutableDeepCopy {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys = [self allKeys];
    
    for(id key in keys) {
        id oneValue = [self valueForKey:key];
        id oneCopy = nil;
        
        if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        } else if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        }
        if (oneCopy == nil) {
            oneCopy = [oneValue copy];
        }
        
        [ret setValue:oneCopy forKey:key];
    }
    
    return ret;
}

@end
