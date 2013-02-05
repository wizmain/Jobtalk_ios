//
//  URLConnectionWithTag.m
//  SmartLMS
//
//  Created by 김 규완 on 11. 10. 11..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import "URLConnectionWithTag.h"

@implementation URLConnectionWithTag

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)withTag {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    
    if(self){
        self.tag = withTag;
    }
    
    return self;
}


- (void)dealloc {
    [tag release];
    [super dealloc];
}

@end
